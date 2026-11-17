# Submission Checklist

Tick an item only when the evidence exists. ✅ means done; ⏳ means waiting on a live step that needs the account owner's approval.

## A. What the assignment asks for

| # | Deliverable | Status | Evidence |
|---|---|---|---|
| A1 | Agent built | ⏳ | Configure per [configuration/bolna_setup.md](configuration/bolna_setup.md); add screenshots to [evidence/screenshots/](evidence/screenshots/) |
| A2 | Agent tested | ⏳ | [tests/test_results.md](tests/test_results.md) currently NOT RUN |
| A3 | List of test cases | ✅ | [tests/test_cases.csv](tests/test_cases.csv) (40 cases) + [tests/evaluation_rubric.md](tests/evaluation_rubric.md) |
| A4 | One call recording or audio URL | ⏳ | [evidence/recording_url.md](evidence/recording_url.md) |
| A5 | The prompt used | ✅ | [prompts/system_prompt.md](prompts/system_prompt.md) v0.2. Re-confirm it matches what is pasted in Bolna before submitting |
| A6 | Five-minute Loom | ⏳ | [evidence/loom_url.md](evidence/loom_url.md) (outline ready) |

## B. Prompt format required by the assignment

| # | Requirement | Status |
|---|---|---|
| B1 | Greeting Message | ✅ Section 3 |
| B2 | Introduction, context setting, good-time confirmation | ✅ Section 4 |
| B3 | Main Pitch | ✅ Section 5 |
| B4 | Site Visit Booking | ✅ Section 6 |
| B5 | Conclusion | ✅ Section 7 |
| B6 | AI Agent Background | ✅ Section 1 |
| B7 | Global Rules | ✅ Section 2 |
| B8 | Guardrails | ✅ Section 8 |
| B9 | FAQs | ✅ Section 9 (16 entries) |
| B10 | Key facts used correctly | ✅ [knowledge/mahima_project_facts.md](knowledge/mahima_project_facts.md) |
| B11 | Hinglish, not formal Hindi | ✅ Lint pass; ⏳ confirm by ear in a test call |
| B12 | `Instructions:` after every dialogue | ✅ 39 of 39 |

## C. Live steps, in order (each needs the owner's go-ahead)

1. ⏳ Create the Cal.com demo event and API key → [configuration/booking_setup.md](configuration/booking_setup.md)
2. ⏳ Create the Bolna agent, paste the prompt and welcome message, set the voice stack → [configuration/bolna_setup.md](configuration/bolna_setup.md)
3. ⏳ Add the two calendar tools; confirm the function names match the prompt
4. ⏳ Add the 12 extractions → [configuration/post_call_extraction.md](configuration/post_call_extraction.md)
5. ⏳ Take screenshots of each Bolna tab and the Cal.com event (blur the API keys)
6. ⏳ Run all P1 test cases as **web calls**; record the results; fix the prompt and log the version
7. ⏳ **One** approved phone call to your own number (TC-01) → recording and transcript
8. ⏳ Fill in [evidence/recording_url.md](evidence/recording_url.md) and [evidence/transcript.md](evidence/transcript.md) (redacted)
9. ⏳ Record the Loom using the outline → [evidence/loom_url.md](evidence/loom_url.md)
10. ⏳ Cancel the test bookings and revoke the Cal.com API key after the assessment

## D. Before every push

| Check | Command or action |
|---|---|
| No secrets | `git grep -nE "sk-|cal_live_|api[_-]?key"` returns nothing in project files |
| No real phone numbers or emails | `git grep -nE "\+91[6-9][0-9]{9}|@gmail\.com"` returns only `.agents/` example data |
| No audio or raw evidence | `git status` shows no `.wav`, `.mp3` or `evidence/raw/` |
| References and brief not committed | `git ls-files` shows no `Refrences/` or `Assignment Instructions/` |
| Results honest | No test is marked PASS without an execution ID |

## E. Loom outline (5 minutes)

| Time | Section | Talking points |
|---|---|---|
| 0:00 | Use case | Facebook lead → Hinglish call → booked site visit; what the brief asked for |
| 0:40 | Setup | Bolna (gpt-4.1-mini, Deepgram multi-hi, Sarvam female voice), built-in Cal.com tools, why no custom code, demo calendar caveat |
| 1:30 | Prompt design | Nine sections; Agent plus Instructions; facts whitelist and no totals; visit status states; one question per turn; objection limits; opt-out; AI honesty; Devanagari for TTS |
| 2:45 | Demo | Play the recorded call; show the matching Cal.com booking and the Bolna extractions |
| 3:45 | Testing | Test matrix, rubric with critical failures, what failed, and the prompt change log entries |
| 4:30 | Learnings | Booking honesty needs explicit states; voice needs short turns; Devanagari vs Roman; what to improve next (CRM sync for callbacks, DLT numbers, verified fact sheet) |

## F. Final submission package

- [ ] GitHub repository link: https://github.com/aaritmehta15/mahima-palm-springs-voice-agent
- [ ] Recording URL (from `evidence/recording_url.md`)
- [ ] Loom URL (from `evidence/loom_url.md`)
- [ ] Prompt: link to `prompts/system_prompt.md`, or paste it if the form asks for text
- [ ] Repository access confirmed (public, or the reviewer added)
