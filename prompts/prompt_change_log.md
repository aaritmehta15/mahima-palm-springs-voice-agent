# Prompt Change Log

Each entry records what changed in [system_prompt.md](system_prompt.md), why, and which evidence (test case ID or call execution) triggered it. Entries without real test evidence are marked *design-time*.

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
