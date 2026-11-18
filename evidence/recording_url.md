# Call Recording: Submission Call (prompt v1.0)

| Field | Value |
|---|---|
| Recording URL (Bolna) | `https://api.bolna.ai/recordings/call/27803950-e85e-47e8-a5d3-e2124fc95cd3` |
| Shareable copy (accessible without login) | PENDING: download the audio of call `27803950` from Bolna Call History and upload it to Google Drive or another shareable location with "anyone with the link can view" |
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

## Redaction rules

- Never list full phone numbers or real email addresses in this repository.
- Never commit raw audio files. `.gitignore` blocks `*.wav`, `*.mp3` and `evidence/raw/`.
