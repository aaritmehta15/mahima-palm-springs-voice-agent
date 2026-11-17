# Call Recording: Submission Call

| Field | Value |
|---|---|
| Recording URL (Bolna) | `https://api.bolna.ai/recordings/call/6b56f180-c232-440f-ba19-218d16f01316` |
| Shareable copy (accessible without login) | PENDING: download the audio from Bolna Call History and upload it to Google Drive or another shareable location with "anyone with the link can view" |
| Bolna execution ID (first 8 characters) | `6b56f180` |
| Prompt version | v0.8 |
| Date of call (IST) | 17 Nov 2026, about 11:01 PM |
| Call mode | Outbound phone call through `POST /call` with `user_data`, to the developer's own verified number |
| Duration | 172 s |
| Total call cost | $0.180 (LLM $0.033, voice $0.057, speech recognition $0.026, network $0.015, platform $0.060) |
| Test case demonstrated | TC-01 (T01 interested customer), TC-23 (T10 site visit), TC-25 (T11 requested slot not among those offered) |
| Booking outcome in Cal.com demo calendar | **Confirmed**: Sat 21 Nov 2026, 11:00 to 11:30 IST (screenshot in `screenshots/`) |
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
| `6b56f180` | 3: booking, attempt 3 | v0.8 | **PASS 98: submission call** |

## Redaction rules

- Never list full phone numbers or real email addresses in this repository.
- Never commit raw audio files. `.gitignore` blocks `*.wav`, `*.mp3` and `evidence/raw/`.
