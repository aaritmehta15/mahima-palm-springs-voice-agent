# Call Recording

> **Status: PENDING.** No call has been recorded yet. This file will be updated only with a real recording from a Bolna execution.

| Field | Value |
|---|---|
| Recording URL | PENDING |
| Bolna execution ID (first 8 characters) | PENDING |
| Prompt version | PENDING |
| Date of call (IST) | PENDING |
| Call mode | PENDING (phone call to the developer's own number) |
| Duration | PENDING |
| Total call cost (`total_cost`) | PENDING |
| Recording URL opened in a private browser window (accessible to the evaluator) | PENDING |
| Test case demonstrated | TC-01 (happy path booking), planned |
| Booking outcome in Cal.com demo calendar | PENDING (screenshot in `evidence/screenshots/`) |
| `extracted_data` Site Visit Status | PENDING |

## Notes for the reviewer

- The call is placed to the developer's own verified phone, with the developer playing the customer. No real customer is called.
- If anyone else takes part, they are told beforehand that it is a recorded AI demo.
- The customer name and email in the call are dummy values.
- The calendar is a Cal.com **demonstration** calendar, not the real Mahima Palm Springs site office schedule.
- Bolna recording links can expire. A copy of the audio is kept in a shareable location controlled by the developer, and that link is listed here.

## Redaction rules

- Never list full phone numbers. Mask them as `+91XXXXXX1234`.
- Never list real email addresses. Use dummy test emails only.
- Never commit raw audio files to this repository. `.gitignore` blocks `*.wav`, `*.mp3` and `evidence/raw/`.
