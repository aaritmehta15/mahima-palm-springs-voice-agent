# Prompt Change Log

Each entry records what changed in [system_prompt.md](system_prompt.md), why, and which evidence (test case ID or call execution) triggered it. Entries without real test evidence are marked *design-time*.

## v0.4: Compaction to fit Bolna (2026-11-17)

**Trigger:** pasting v0.3 into the Bolna prompt canvas showed "This draft is too large to save. Shorten the prompt to keep autosaving." (11,957 tokens). A shorter prompt also lowers per-turn LLM latency on live calls.

| Change | Effect |
|---|---|
| The two Bolna static modules (Naturalization, Pronunciation) replaced by short `# Speaking Style` and `# Pronunciation` rules with the same intent | About 5,500 characters saved |
| The standard closing boilerplate repeated in seven Section 7 branches replaced by "Speak it as written, then end the call" | About 3,500 characters saved |
| Instructions rewritten as short imperatives with the same routing; Section 4 Branch A merged into the busy handler, which did the same thing | Same logic, fewer words |
| FAQs moved from YAML to `FAQ n:` + `Agent:` + `Instructions:`; the "are you AI" FAQ removed because the handler covers it | Every FAQ answer now has its own Instructions line |

**Result:** 25,213 characters (was 53,227). 54 of 54 Agent lines are followed by Instructions; no spoken-line violations; same three states; all facts unchanged; Sections 1 to 9 present. Round 1 static traces for T01–T15 still hold, because no routing changed. Waiting for the Bolna save to confirm it now fits.

## v0.3: Plan alignment + Round 1 static fixes (static-checked, not yet live-tested)

### Design changes
| # | Change | Reason |
|---|---|---|
| 1 | `[visit_status]` reduced from four values to three: `not_requested`, `pending_confirmation`, `confirmed` | Simpler for the model to track and easier to evaluate; matches the extraction field. Agreeing to a visit, giving a preferred time, or a tool failure all mean `pending_confirmation` until the tool succeeds |
| 2 | S5 Q1 is now a light 3 BHK or 4 BHK qualification; the "own use or investment" question is removed (purpose is only noted if volunteered); S5 Q3 no longer asks for the configuration again | One qualification question instead of two, so the call is less like an interrogation |
| 3 | New `# Pitch Routing` rules block: pitch facts are a menu; any question is answered immediately; facts already shared are skipped | Branching instead of a rigid questionnaire |
| 4 | New standard fact verification line in Section 2: "इसकी verified जानकारी अभी मेरे पास नहीं है। मैं आपके लिए sales team से confirm करवा सकती हूँ, करवा दूँ?", plus a `[unknown_questions]` variable | One consistent, honest response to unknowns |
| 5 | S7 Branch D now says the request has been noted, and its instructions forbid any extra promise | The "10 AM to 5 PM" window comes from the assessment script, not a verified service commitment; the request is recorded through the post-call extraction |

### Round 1 static desk-check fixes
See [tests/test_results.md](../tests/test_results.md), defects D1 to D3: FAQ unknowns now offer sales team confirmation; a greeting-time "not interested" is routed; the intro's question-handling instruction is corrected.

### Pre-paste review checklist (v0.3)
| Check | Result | Evidence |
|---|---|---|
| Every scripted Agent dialogue has Instructions immediately after it | ✅ | Lint: 40 of 40, none missing |
| All spoken agent dialogues are Hinglish | ✅ | Lint: every spoken line contains Devanagari; no formal Hindi words |
| All required sections included | ✅ | Lint: Sections 1 to 9 present |
| All property facts accurate | ✅ | Every fact string matches [knowledge/mahima_project_facts.md](../knowledge/mahima_project_facts.md) |
| Every unknown fact handled safely | ✅ | Standard verification line plus FAQ rule (D1 fix); lint finds no amenity, lakh or crore words |
| Responses conversational rather than robotic | ✅ static; ⏳ by ear | Two sentences or fewer per turn; one acknowledgement maximum; needs a Round 2 live check |
| Customer objections handled gracefully | ✅ | Six objections, one pivot each, close after two declines |
| The agent can skip irrelevant questions | ✅ | Pitch Routing block; S5 Q5 skipped if a visit was already asked for |
| Booking requires successful tool execution | ✅ | `confirmed` only on `book_calendar_slot` success; S7 A used only when confirmed |
| The agent can recover from tool failure | ✅ | S6 Branch C, one retry maximum, ends `pending_confirmation` |
| Refusal and opt-out are respected | ✅ | S4 Branch D, a single probe; opt-out handler is immediate |
| The call can end without forcing a site visit | ✅ | S7 B, C, D, E, F and G |

Status: ready to paste into Bolna. Live behaviour is still unverified (Rounds 2 and 3).

## v0.2: Phase E static review fixes (design-time, not yet tested)

Found by manual review of v0.1 against the Bolna Cal.com tool contract and Bolna call-hangup behaviour. No live tests were run.

| # | Issue in v0.1 | Risk | Change in v0.2 |
|---|---|---|---|
| 1 | `[selected_slot]` was only described in spoken form, but `book_calendar_slot` needs the exact ISO 8601 start time | The model could pass "subah gyarah baje" or a rebuilt time, and the booking would fail or land on the wrong slot | `# Context Variables` now requires each slot to be kept in two forms: the ISO value from the tool (passed to booking) and Hindi time words (spoken) |
| 2 | No explicit end-of-call rule | The agent may keep talking after a closing, or loop on "thank you"/"bye" | Added `# Ending the Call` to Section 2; enabled LLM-based hangup in [bolna_setup.md](../configuration/bolna_setup.md) |
| 3 | Abuse handler continued into the Section 7 Branch E closing ("... Mahima Palm Springs zaroor yaad rakhiyega") | A cheerful sales close after abuse sounds tone-deaf | The abuse line is now itself the closing; the call ends immediately |

Re-check: the automated lint was re-run after these edits (see below). The conversation flow doc and the setup guide were updated to match.

## v0.1: Initial design (design-time, not yet tested)

**Basis:** the assignment brief, the confirmed design decisions in [assignment/requirements.md](../assignment/requirements.md), and patterns from the reference repositories.

### Structure
- Nine sections. The five script stages required by the brief (Greeting, Introduction and good-time check, Main Pitch, Site Visit Booking, Conclusion) are Sections 3 to 7. The four extra sections the brief requires (AI Agent Background, Global Rules, Guardrails, FAQs) are Sections 1, 2, 8 and 9.
- Every spoken `Agent:` line is followed by an English `Instructions:` paragraph: 39 of 39, verified automatically.
- Business facts, spoken dialogue, internal instructions, branches, tool conditions, FAQs and guardrails sit in separate, labelled blocks.

### Key design decisions
| Decision | Reason |
|---|---|
| Devanagari Hindi with English loanwords in Roman | Bolna guidance and Sarvam TTS pronunciation. Roman reading copy in [conversation_flow.md](conversation_flow.md) |
| Female persona Neha, feminine verb forms throughout | Consistency across Hindi grammar |
| Proactive AI disclosure in the introduction, plus a truthful answer if asked | Honesty and trust; recommended by Bolna prompting tips |
| `[visit_status]`: requested, pending_confirmation, booked, declined | Stops false booking confirmations |
| Name and email preloaded from the Facebook lead form and confirmed | Avoids error-prone email capture by voice |
| Rate and size range only; totals never calculated | Area basis and charges are unverified |
| Senior expert means a callback tomorrow, 10 AM to 5 PM | Matches the example in the assignment brief |
| Objections: one pivot each, close after two declines | Persuasive without pressure |

### Deliberate deviations from the Bolna `prompt-writing` skill defaults
| Skill default | This prompt | Reason |
|---|---|---|
| Every scripted line in Hindi **and** English | Single Hinglish `Agent:` line | The brief requires Hinglish dialogue. The STT handles English replies, and an English fallback rule is in `# Language` |
| `Question N (Hindi):` labels | `Agent: "..."` followed by `Instructions:` | The brief specifies this exact convention |
| Identity clause forbids disclosing AI | Truthful disclosure | Honesty requirement in the build constraints |
| FAQ answers in `en` and `hi` | `hi` (Hinglish) answers only | Hinglish-only dialogue; the English fallback is described in the FAQ rules block |
| FAQ is the last section, Closing second-last | Order: Conclusion, Guardrails, FAQs | Keeps the script order the brief requires; FAQ is still last |

The two Bolna static modules (*Conversational Naturalization* and *Pronunciation and Script Normalisation*) are included with only the permitted changes: the caller noun is changed to "customer" and the examples are replaced with project-relevant names.

### Automated checks run on v0.1
| Check | Result |
|---|---|
| `Agent:` count equals `Instructions:` count, and each `Agent:` is followed directly by `Instructions:` | 39 = 39, pass |
| No digits, `!`, `/`, `@`, `%`, `&`, `$`, `#` or dashes in spoken lines (Agent lines and FAQ answers, 55 lines) | Pass |
| No formal Hindi words (कृपया, धन्यवाद, आवास, निर्माण, उपलब्ध, संपत्ति) or "tum" | Pass |
| No masculine self-references | Pass |
| No unverified facts in spoken lines (pool, gym, lakh, crore, guarantee, ready to move) | Pass |
| All nine required sections present | Pass |

### Known risks to verify in testing
- **Prompt length** is about 50,000 characters. Devanagari is token-heavy, so watch first-response latency. If it is high, trim the static module examples and merge FAQs into the facts block.
- **Calendar function names** must match the names Bolna assigns to the built-in Cal.com tools.
- **Spoken slot times**: the tool returns ISO timestamps, so check the agent converts them into natural Hindi time words.
- **Relative date resolution** ("kal", "Sunday") depends on `{current_date}` being populated with timezone Asia/Kolkata.
- **Reading back `{customer_email}`** over TTS: check the pronunciation of "at the rate" and "dot".

## Template for later entries

```
## vX.Y: <short title> (YYYY-MM-DD)
Trigger: test case TC-XX / execution <id, redacted>
Observed: <what the agent did>
Expected: <what it should have done>
Change: <section and line changed>
Re-test: <result + evidence link>
```
