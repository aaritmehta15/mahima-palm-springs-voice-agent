# Call Recording: Submission Call (prompt v1.0)

| Field | Value |
|---|---|
| Recording URL (Bolna) | `https://api.bolna.ai/recordings/call/27803950-e85e-47e8-a5d3-e2124fc95cd3` |
| **Shareable recording (submission)** | https://drive.google.com/file/d/14V9dwW7G8zMHNY7-hMzpAcy6izRNqF48/view?usp=sharing |
| Bolna execution ID (first 8 characters) | `27803950` |
| Prompt version | **v1.0** (the submitted prompt) |
| Date of call (IST) | 18 Nov 2026 |
| Call mode | Outbound phone call through `POST /call` with `user_data`, to the developer's own verified number |
| Duration | 228 s |
| Total call cost | $0.24 |
| Test cases demonstrated | TC-01, TC-09 (total price), TC-42 (weekday only), TC-43 (time of day), TC-45 (taken time), TC-49 (booking only after the combined read-back) |
| Booking outcome in Cal.com demo calendar | **Confirmed**: Sat 21 Nov 2026, 9:00 to 9:30 IST (screenshot in `screenshots/`) |
| Transcript | [transcript.md](transcript.md) |

## Notes for the reviewer

- The call was placed to the developer's own verified phone, with the developer playing the customer. No real customer was called.
- The calendar is a Cal.com **demonstration** calendar, not the real Mahima Palm Springs site office schedule.
- Bolna recording links may need a Bolna login. The shareable copy above is the link intended for reviewers.

## Other recorded test calls (for transparency)

| Execution (first 8) | Round | Prompt | Result |
|---|---|---|---|
| `6d1ec…` | 2: voice check | v0.4.1 | PASS 89; defects D4 to D6 found |
| `ec16fc4c` | 3: booking, attempt 1 | v0.5 | FAIL; invented slots and wrong dates (D7 to D11), no false booking |
| `9a476680` | 3: booking, attempt 2 | v0.7 | PASS 86; first real booking; voice-spelled email misheard |
| `6b56f180` | 3: booking, attempt 3 | v0.8 | PASS 98 (former submission candidate) |
| `cd97fa2d` | 4: weekday only | v0.9 | Booked; D14 to D19 found |
| `748687e7` | 5: v1.0 booking, attempt 1 | v1.0 | Stopped by the tester mid-call (STT heard "ten" for "teen"; the agent correctly re-asked) |
| `27803950` | 5: v1.0 booking | **v1.0** | **PASS: submission call** |

## Recordings of the other v1.0 live tests

| Test | Execution | What it shows | Recording |
|---|---|---|---|
| B: guardrails | `fed6d237` | No amenity or discount invented; honest AI disclosure; refusal respected | https://drive.google.com/file/d/14C3NN17Ty1IbCq5DDN36MTb3fgSGZ9QH/view?usp=sharing |
| E: senior expert (the brief's own example) | `1989ae4d` | "senior expert आपको कल सुबह दस बजे से शाम पाँच बजे के बीच call करेंगे" | https://drive.google.com/file/d/1APGods3RCR0YEPIIibUY8_g9JNZ3Isvu/view?usp=sharing |
| C: callback | `c48c8d47` | "कल सुबह, दोपहर या शाम?" → callback auto-scheduled | https://drive.google.com/file/d/1E6ftO1QfXs5FTR5xNYie21yOwB9AbEXv/view?usp=sharing |
| D: opt-out | `2c9f68a5` | Immediate acknowledgement → do-not-call list → pending callbacks stopped | https://drive.google.com/file/d/14SMPHzuupHaPoLE4DYAx2H1UOWhEuNnx/view?usp=sharing |

## Redaction rules

- Never list full phone numbers or real email addresses in this repository.
- Never commit raw audio files. `.gitignore` blocks `*.wav`, `*.mp3` and `evidence/raw/`.
