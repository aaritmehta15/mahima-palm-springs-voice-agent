# Submission Checklist

Tick an item only when the evidence exists. ✅ means done; ⏳ means waiting on a live step that needs the account owner's approval.

**Final readiness: 15 of 20 done. Remaining: screenshots, shareable recording link, prompt submission, Loom, link check**

## 1. Assignment compliance

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Complete working outbound agent | ✅ | Configure per [configuration/bolna_setup.md](configuration/bolna_setup.md) |
| 2 | All five required call-flow sections | ✅ | [prompts/system_prompt.md](prompts/system_prompt.md) Sections 3 to 7 |
| 3 | AI Agent Background, Global Rules, Guardrails and FAQs | ✅ | Sections 1, 2, 8 and 9 |
| 4 | Instructions after every Agent dialogue | ✅ | 54 of 54 (lint, v0.4) |
| 5 | All spoken lines in natural Hinglish | ✅ static; ⏳ confirm by ear in Round 2 | Lint: 54 spoken lines, no formal Hindi |

## 2. Working integrations

| # | Item | Status | Evidence |
|---|---|---|---|
| 6 | Bolna agent configured and tested | ✅ (screenshots ⏳) | Screenshots in [evidence/screenshots/](evidence/screenshots/) |
| 7 | Verified-number outbound test completed | ✅ (4 live calls) | Round 2 execution ID in [tests/test_results.md](tests/test_results.md) |
| 8 | Cal.com availability tool works | ✅ | Raw log shows a `check_availability_of_slots` result |
| 9 | Cal.com booking tool actually creates a booking | ✅ (Confirmed booking, `6b56f180`) | Booking visible in Cal.com (screenshot) |
| 10 | No false confirmation when booking fails | ✅ live (`ec16fc4c`: failed and closed as pending) | T12 Round 1 trace; optional live test on an agent copy with a broken key |

## 3. Evidence and evaluation

| # | Item | Status | Evidence |
|---|---|---|---|
| 11 | Test cases documented | ✅ | [tests/test_cases.csv](tests/test_cases.csv) (42 cases; core T01–T15 mapped) |
| 12 | Actual test results saved | ✅ Static and 4 live calls | [tests/test_results.md](tests/test_results.md) |
| 13 | Final transcript saved with personal data removed | ✅ | [evidence/transcript.md](evidence/transcript.md) |
| 14 | One accessible recording URL | ⏳ | [evidence/recording_url.md](evidence/recording_url.md); open it in a private window to check |
| 15 | Execution ID and call cost recorded | ✅ | [evidence/recording_url.md](evidence/recording_url.md) |

## 4. Submission

| # | Item | Status | Evidence |
|---|---|---|---|
| 16 | Prompt submitted separately | ⏳ | Paste or attach [prompts/system_prompt.md](prompts/system_prompt.md) (the text between the BEGIN and END markers) |
| 17 | GitHub repository README complete | ✅ | [README.md](README.md); update the results line after the live rounds |
| 18 | All secrets and personal details excluded | ✅ so far; re-check before the final push | See section 6 |
| 19 | Five-minute Loom recorded | ⏳ | [evidence/loom_url.md](evidence/loom_url.md) (outline ready) |
| 20 | All links tested before submission | ⏳ | Open every link in a private window |

## 5. Live steps, in order (each needs the owner's go-ahead)

1. ⏳ Cal.com: create the "Assessment Demo Site Visit" event (30 min, Asia/Kolkata), connect Google Calendar, create an API key → [configuration/booking_setup.md](configuration/booking_setup.md)
2. ⏳ Bolna: create "Mahima Palm Springs – Lead Follow-up", paste the prompt and welcome message, set the voice stack, retries off, 5-minute cap → [configuration/bolna_setup.md](configuration/bolna_setup.md)
3. ⏳ Add the two calendar tools; check that the function names match the prompt
4. ⏳ Preview the voice; take screenshots of each tab (blur keys)
5. ⏳ **Round 2:** one short voice-check call to your own number
6. ⏳ Fix the prompt if needed → change log → static re-check (Round 4)
7. ⏳ **Round 3:** one booking call (the submission recording); confirm in Cal.com
8. ⏳ Add the extractions → [configuration/post_call_extraction.md](configuration/post_call_extraction.md); test them on the Round 3 transcript
9. ⏳ Fill in the evidence files (redacted), including the execution ID and cost
10. ⏳ Record the Loom; test all links; submit
11. ⏳ After the assessment: cancel test bookings and revoke the Cal.com API key

## 6. Before every push

| Check | Command or action |
|---|---|
| No secrets | `git grep -nE "sk-[A-Za-z0-9]{10}|cal_live_|bn-[a-f0-9]{16}"` finds nothing |
| No real phone numbers or emails | `git grep -nE "\+91[6-9][0-9]{9}|@gmail\.com" -- ':!.agents'` finds nothing |
| No audio or raw evidence | `git status` shows no `.wav`, `.mp3` or `evidence/raw/` |
| References and brief not committed | `git ls-files` shows no `Refrences/` or `Assignment Instructions/` |
| No AI co-author lines | `git log --format=%B` contains no Co-Authored-By lines |
| Results honest | No `LIVE PASS` without an execution ID |
