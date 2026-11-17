# Post-Call Extraction (Bolna Dispositions)

After every call, Bolna runs these questions over the transcript and stores the answers in `extracted_data`. They do two jobs:

1. **Reporting:** a structured business outcome for every call, with no CRM needed.
2. **Automation:** [`scripts/post_call.ps1`](../scripts/post_call.ps1) reads `Opt-out`, `Callback Day` and `Callback Time` and **acts on them**. An opt-out goes on the do-not-call list. A callback request becomes a real scheduled call.

> The names below must match exactly, because `post_call.ps1` looks them up by name.

Configure in Bolna: Agent → **Extractions** → **New Category** `Lead Outcome` → add each disposition. Model: `gpt-4.1-mini`.

**System prompt (shared):**
`You are analysing a transcript of an outbound Hinglish sales call by Neha, an AI assistant for Mahima Palm Springs, Jaipur. Judge only from what was actually said. If something was not discussed, choose the not discussed or none option.`

## Category `Lead Outcome`

| # | Name | Question | Type and options |
|---|---|---|---|
| 1 | `Call Outcome` | What was the final outcome of this call? | Pre-defined: `interested` (a visit was confirmed or requested) · `follow_up` (busy, callback, or senior expert requested) · `not_interested` · `wrong_number` · `opted_out` · `no_conversation` |
| 2 | `Site Visit Status` | What is the status of the site visit? | Pre-defined: `not_requested` · `pending_confirmation` (wanted a visit, but no booking succeeded) · `confirmed` (only if the agent said the booking succeeded after the booking tool ran) |
| 3 | `Configuration Interest` | Which flat did the customer want? | Pre-defined: `3_bhk` · `4_bhk` · `undecided` · `not_discussed` |
| 4 | `Opt-out` | Did the customer explicitly ask not to be called again? | Pre-defined: `true` · `false` |
| 5 | `Callback Day` | If the customer asked to be called back later, on which day? | Pre-defined: `none` · `today` · `tomorrow` · `day_after_tomorrow` |
| 6 | `Callback Time` | If the customer asked for a callback, what time of day did they ask for? | Pre-defined: `morning` · `afternoon` · `evening` · `same_time` (they said "isi time") · `not_specified` |
| 7 | `Unknown Questions` | List the questions the agent could not answer from verified facts (for example amenities, RERA, loan, discount). Answer none if there were none. | Free text |

### How `post_call.ps1` turns 5 and 6 into a real call

| Callback Day | Offset from the call date (IST) | Callback Time | Hour (IST) |
|---|---|---|---|
| `today` | +0 days | `morning` | 11:00 |
| `tomorrow` | +1 day | `afternoon` | 14:00 |
| `day_after_tomorrow` | +2 days | `evening` | 17:00 |
| | | `same_time` | the original call's time |
| | | `not_specified` | 11:00 |

It then calls `POST /call` with `scheduled_at` and `call_reason=callback`, **after asking the operator to confirm**, because a scheduled call spends credit. The scheduled call opens with the callback introduction (prompt S4 Branch E).

## Testing extractions without a phone call

Use the **Test** button on the Extractions tab with a saved transcript ([tests/transcripts/](../tests/transcripts/)).

| Transcript | Call Outcome | Site Visit Status | Opt-out | Callback Day / Time |
|---|---|---|---|---|
| `call4_6b56f180` (submission) | `interested` | `confirmed` | `false` | `none` / `not_specified` |
| `call1_6d1ec` (busy, "kal isi time") | `follow_up` | `not_requested` | `false` | `tomorrow` / `same_time` |
| `call2_ec16fc4c` (booking failed) | `interested` | `pending_confirmation` | `false` | `none` / `not_specified` |

## Known limitation

Bolna's built-in Call Summary misread "पचपन सौ" as ₹5,550 in two calls. Prompt v1.0 says "पाँच हज़ार पाँच सौ" to remove the ambiguity. Extractions are still model output, so check them against the transcript before acting on money-related fields.
