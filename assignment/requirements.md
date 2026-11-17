# Assignment Requirements and Deliverable Map

This file shows how each instruction in the assignment brief, plus the implementation constraints adopted for this build, maps to a concrete deliverable in this repository. Status values are only updated when evidence exists.

## 1. Task summary (from the assignment brief)

Create a voice AI agent for **Mahima Palm Springs** that calls a customer who enquired through a Facebook ad, pitches the project in Hinglish and books a site visit.

**Ask**
1. Build the entire agent, test it, write down the list of test cases, and include one call recording or audio URL.
2. Submit the prompt that was used.
3. Submit a five-minute Loom covering setup, design choices, prompt style and learnings.

## 2. Requirement-to-deliverable checklist

| ID | Requirement | Source | Deliverable / evidence | Status |
|---|---|---|---|---|
| R1 | Build the entire agent | Brief: Ask | Bolna agent configured per [configuration/bolna_setup.md](../configuration/bolna_setup.md); screenshots in [evidence/screenshots/](../evidence/screenshots/) | Config guide written; agent not yet built |
| R2 | Test it and write down test cases | Brief: Ask | [tests/test_cases.csv](../tests/test_cases.csv), [tests/evaluation_rubric.md](../tests/evaluation_rubric.md), [tests/test_results.md](../tests/test_results.md) | Cases and rubric written; not yet run |
| R3 | One call recording or audio URL | Brief: Ask | [evidence/recording_url.md](../evidence/recording_url.md), [evidence/transcript.md](../evidence/transcript.md) | Pending (needs approved call) |
| R4 | Submit the prompt used | Brief: Ask | [prompts/system_prompt.md](../prompts/system_prompt.md) is the exact text pasted into Bolna | Done (v0.2) |
| R5 | Five-minute Loom | Brief: Ask | [evidence/loom_url.md](../evidence/loom_url.md) | Outline ready; not recorded |
| R6 | Script order: Greeting, Introduction with context and good-time check, Main Pitch, Site Visit Booking, Conclusion | Brief: Guidelines | `system_prompt.md` Sections 3 to 7 | Done |
| R7 | Prompt also contains AI Agent Background, Global Rules, Guardrails, FAQs | Brief: Guidelines | `system_prompt.md` Sections 1, 2, 8, 9 | Done |
| R8 | Use the supplied key facts where necessary | Brief: Guidelines | [knowledge/mahima_project_facts.md](../knowledge/mahima_project_facts.md) and the facts block in `system_prompt.md` | Done |
| R9 | All agent dialogue in Hinglish; common English words kept; no formal Hindi | Brief: Guidelines | Every `Agent:` line; Hinglish review in Phase E | Done; to verify by ear |
| R10 | `Instructions:` after every dialogue | Brief: Guidelines | Every `Agent:` line is followed by `Instructions:`; checked automatically in Phase E | Done (39 of 39, lint) |
| R11 | Branches for interested, busy, not interested, wrong number, price and configuration questions, unknown questions, objections, senior-expert requests, site-visit requests, unavailable slots, booking errors, opt-outs | Build constraints | Branches in `system_prompt.md`; one or more test cases each | Done in prompt; not yet tested |
| R12 | Real availability check and booking through Cal.com; requested, pending and booked states kept distinct | Build constraints | `system_prompt.md` Section 6; [configuration/booking_setup.md](../configuration/booking_setup.md) | Done in prompt and config; not yet tested |
| R13 | No invented facts and no computed total price | Build constraints | `system_prompt.md` Section 8; anti-hallucination test cases | Done in prompt; not yet tested |
| R14 | Honest when asked whether the caller is an AI | Build constraints | `system_prompt.md` Section 8 and FAQ; test case | Done in prompt; not yet tested |
| R15 | No secrets or personal data in the repository | Build constraints | [.gitignore](../.gitignore); redaction rules in `evidence/` | Done |
| R16 | Licences of reference repositories respected | Build constraints | Attribution section in [README.md](../README.md) | Done |
| R17 | Structured post-call outcome | Build constraints | [configuration/post_call_extraction.md](../configuration/post_call_extraction.md) | Config guide written; not yet configured |

## 3. Confirmed design decisions

| Decision | Choice | Reason |
|---|---|---|
| Voice platform | Bolna | Built-in Cal.com tools, Indian voice stack, outbound calling |
| LLM | gpt-4.1-mini | Bolna's recommended latency and quality balance |
| Speech to text | Deepgram nova-3, language `multi-hi` | Handles Hindi and English code-switching |
| Text to speech | Sarvam (female Hindi voice) | Native Hindi pronunciation |
| Script of dialogue | Devanagari Hindi with common English words kept in Roman | Sarvam TTS and Bolna's guidance both favour native script. A Roman-transliterated copy is in [prompts/conversation_flow.md](../prompts/conversation_flow.md) for readability |
| Persona | Neha, female | Hindi verb forms stay feminine throughout |
| Name and email for booking | Preloaded from the Facebook lead form as `{customer_name}` and `{customer_email}`, confirmed on the call | Capturing an email by voice is the most error-prone step |
| Pricing answers | Rate per sq. ft. and size range only; no totals | Area basis and extra charges are not verified |
| Visit states | `not_requested`, `pending_confirmation`, `confirmed` | A false booking confirmation is a critical failure |
| Qualification | One question: 3 BHK or 4 BHK; purpose only noted if volunteered | Qualifies without interrogating |
| Unknown questions | One standard verification line plus a sales team confirmation offer | Consistent and honest |
| Testing | Four rounds: static, voice call, booking call, regression; acceptance ≥85 percent with zero critical failures | Fits a $5 Bolna credit budget |
| Senior expert or customer care | Callback promise, not a live transfer | Matches the example in the brief and needs no transfer number |

## 4. Assumptions

1. Neha is an AI calling assistant speaking on behalf of the Mahima Palm Springs sales team.
2. The only preloaded variables are `{customer_name}` and `{customer_email}`. Bolna system variables `{current_date}` and `{current_time}` are used with timezone `Asia/Kolkata`.
3. The Cal.com calendar is a demonstration calendar. Its slots do not represent the real site office's schedule.
4. The calling window is 10 AM to 7 PM IST.
5. Flat sizes are stated as a range only. Which size belongs to which configuration is not known.

## 5. Open items that need the account owner

| Item | Needed for |
|---|---|
| Bolna account and trial credit | Agent build, testing, recording |
| Confirmation that the trial number can call the owner's own phone | One demonstration call |
| Availability of gpt-4.1-mini, Deepgram multi-hi and Sarvam voices in the workspace | Voice stack |
| Cal.com account, API key and demo event type | Real booking |
| Shareable location for the recording | Evidence |
| GitHub repository visibility | Submission |

## 6. Out of scope by design

LiveKit, Pipecat, n8n, vector databases, custom telephony, CRM, dashboards and webhook servers. The reference repositories are studied for patterns only; their technology stacks are not used.
