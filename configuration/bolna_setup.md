# Bolna Agent Setup

Step-by-step configuration of the Mahima Palm Springs agent in **Bolna Agent Studio** (dashboard), with no custom code. Settings come from Bolna's official `create-agent` skill guidance in [.agents/skills/create-agent/](../.agents/skills/create-agent/).

> **Safety:** creating the agent and running web tests is free or low-cost. **Do not** buy phone numbers, top up credits or place phone calls without the account owner's explicit approval. API keys are entered only into the Bolna and Cal.com dashboards and are never stored in this repository.

## 0. Prerequisites

| Item | Notes |
|---|---|
| Bolna account | Sign up at platform.bolna.ai. Note the trial credit balance in the dashboard |
| Cal.com set up | Finish [booking_setup.md](booking_setup.md) **before** step 5 |
| Test identity | A dummy customer name and a test email inbox you control |

## 1. Create the agent

Dashboard → **Agents** → **Create agent** → choose a blank or custom agent (not a template), so no template prompt leaks in.

| Field | Value |
|---|---|
| Agent name | `Mahima Palm Springs - Neha (Outbound)` |

## 2. Agent tab

| Field | Value |
|---|---|
| Agent Welcome Message | `नमस्ते, क्या मेरी बात {customer_name} जी से हो रही है?` (Section 3 of the prompt, word for word) |
| Agent Prompt | Everything between `===== BEGIN PROMPT =====` and `===== END PROMPT =====` in [prompts/system_prompt.md](../prompts/system_prompt.md), excluding the marker lines |

Variables used: `{customer_name}` and `{customer_email}` are passed per call. `{current_date}` and `{current_time}` are Bolna system variables.

## 3. LLM tab

| Setting | Value | Why |
|---|---|---|
| Provider | OpenAI | Bolna default |
| Model | `gpt-4.1-mini` | Bolna's recommended latency and quality balance; the prompt is written for it |
| Temperature | `0.2` | Keeps the agent close to the scripted lines |
| Max tokens | `150` | Enforces short turns; Devanagari uses more tokens, so raise to 200 if replies are cut off |

**Fallback:** if `gpt-4.1-mini` is unavailable in the workspace, use `gpt-4o-mini` and log the change in the prompt change log.

## 4. Audio tab

| Setting | Value | Why |
|---|---|---|
| Transcriber provider | Deepgram | |
| Transcriber model | `nova-3` | |
| Transcriber language | `multi-hi` (Hindi and English code-switching) | Customers mix Hindi and English |
| Endpointing | `700` ms | Hindi speakers pause longer mid-sentence |
| Synthesizer provider | Sarvam | Native Hindi pronunciation |
| Synthesizer model | `bulbul:v3` if listed, otherwise `bulbul:v2` | |
| Voice | A **female** Hindi voice; preview and pick the warmest | Neha is female, so verb forms in the prompt are feminine |
| Language | Hindi (`hi`) | Hinglish runs inside the Hindi entry; a separate English entry is not needed |

Preview the voice with this line before choosing:
`आपका site visit रविवार को सुबह ग्यारह बजे के लिए book हो गया है।` Check that "site visit", "book" and the numbers sound natural.

**Fallbacks:** if Sarvam is not available, use ElevenLabs `eleven_multilingual_v2` with a Hindi female voice. If `multi-hi` is not available, use Sarvam STT with Hindi. Record any fallback in the prompt change log.

## 5. Tools tab (calendar)

Add both built-in Cal.com functions, configured as in [booking_setup.md](booking_setup.md):
1. **Check slot availability (using Cal.com)**. The function name must be `fetch_calendar_slots`.
2. **Book appointment (using Cal.com)**. The function name must be `book_calendar_slot`.

If the dashboard assigns fixed names that cannot be changed, update the two names in the prompt's Section 6 to match, and log the change.

## 6. Engine and call tab (conversation controls)

| Setting | Value | Why |
|---|---|---|
| `number_of_words_for_interruption` | `2` | Lets the customer interrupt quickly |
| `incremental_delay` | `350` ms | Fast turn-taking without the agent cutting itself off |
| `hangup_after_silence` | `20` s | Indian callers often pause to think |
| `trigger_user_online_message_after` | `10` s | Must be less than `hangup_after_silence` |
| `check_user_online_message` | `Hello, क्या आप मुझे सुन पा रहे हैं?` | Same line as the prompt's silence handler, so the wording stays consistent |
| `call_terminate` (max duration) | `480` s (8 min) | Enough for pitch plus booking; caps cost |
| `call_hangup_message` | leave empty | The closing lines in Section 7 already end the call |
| LLM-based call hangup ("hang up when the conversation ends") | `on` | The prompt's `# Ending the Call` rule tells the model to end after any Section 7 closing; this setting lets Bolna actually disconnect |
| Voicemail detection | `on` | Avoids pitching to voicemail |
| `use_fillers` | `off` | The prompt controls acknowledgements |
| `backchanneling` | `off` | Avoids "mhm" being spoken over Hindi pauses |
| Ambient noise | `off` | Not supported on every provider; not needed |
| Calling guardrails | start `10`, end `19` (IST) | Respectful calling hours |
| Timezone | `Asia/Kolkata` | Needed so `{current_date}` resolves dates like "kal" and "Sunday" correctly |

## 7. Analytics and extraction tab

Configure the extractions in [post_call_extraction.md](post_call_extraction.md). Turn on the transcript and the call summary.

## 8. Testing order (cheapest first)

| Step | How | Cost |
|---|---|---|
| 1 | **Web call or playground** in the dashboard, with `customer_name` = `Rahul` and `customer_email` = a test inbox | No telephony cost |
| 2 | Run all P1 cases from [tests/test_cases.csv](../tests/test_cases.csv), and fix the prompt where they fail | No telephony cost |
| 3 | **One** phone call to the developer's own number (TC-01) for the recorded demo, **only after explicit approval** | Telephony credit |

**Phone call settings:** recipient is the developer's own number in E.164 format (`+91XXXXXXXXXX`); `user_data` = `{"customer_name": "<dummy>", "customer_email": "<test inbox>", "timezone": "Asia/Kolkata"}`.

## 9. Getting the evidence

After a call, open **Call History** in the dashboard or use the API (see the `get-executions` skill):

| Need | Where |
|---|---|
| Transcript | `GET /executions/{execution_id}` → `transcript` |
| Recording URL | `telephony_data.recording_url` |
| Tool calls | `GET /executions/{execution_id}/log` (raw logs) |
| Extractions | `extracted_data` |
| Cost | `total_cost`, `cost_breakdown` |

The webhook `completed` event can arrive before the transcript is ready. Always re-fetch the execution by ID; this was the pattern observed in the EstateFlow reference.

Copy the results into [evidence/](../evidence/) using the redaction rules there. Never commit raw audio.

## 10. Compliance note

Commercial outbound calls to Indian numbers require DLT-registered numbers: 140-series through Vobiz for promotional calls (see [.agents/references/india-compliance.md](../.agents/references/india-compliance.md)). This demo calls only the developer's own phone. A production rollout would need DLT registration, consent records from the Facebook lead form, and a do-not-call list fed by the `Opted Out` extraction.

## 11. Configuration record (fill in after setup)

| Item | Value used |
|---|---|
| Bolna agent ID (first 8 characters) | PENDING |
| LLM model | PENDING |
| STT model and language | PENDING |
| TTS model and voice | PENDING |
| Calendar function names | PENDING |
| Fallbacks used | PENDING |
| Screenshots | [evidence/screenshots/](../evidence/screenshots/) |
