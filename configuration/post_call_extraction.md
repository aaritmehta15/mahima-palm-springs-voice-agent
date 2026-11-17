# Post-Call Extraction (Bolna Dispositions)

After every call, Bolna runs these extraction questions over the transcript and stores the answers in `extracted_data`. This gives each call a structured outcome without a CRM. Reference: [.agents/skills/create-disposition/SKILL.md](../.agents/skills/create-disposition/SKILL.md).

Configure in the dashboard: Agent → **Analytics / Extractions**. Each item below is one disposition. Use model `gpt-4.1-mini`.

**System prompt for all dispositions:**
`You are analysing a transcript of an outbound Hinglish sales call by Neha, an AI assistant for Mahima Palm Springs, Jaipur. Judge only from what was actually said and from tool results in the transcript. If something was not discussed, choose the "unknown" or "not discussed" option.`

## Category: Call Outcome

### 1. Call Outcome (pre-defined)
Question: `What was the final outcome of this call?`

| Value | Condition |
|---|---|
| `site_visit_booked` | The booking tool returned a successful booking and the agent confirmed it |
| `site_visit_pending` | The customer wanted a visit but no successful booking happened (no slots, tool error, email not captured) |
| `callback_requested` | The customer was busy or asked to be called later |
| `senior_expert_callback` | The customer asked for a human, customer care or a senior expert |
| `not_interested` | The customer declined |
| `wrong_number` | Wrong person, or no enquiry was made |
| `opted_out` | The customer explicitly asked not to be called again |
| `no_conversation` | Voicemail, silence or disconnected before the introduction |

### 2. Site Visit Status (pre-defined)
Question: `What is the status of the site visit?`

| Value | Condition |
|---|---|
| `booked` | Only if `book_calendar_slot` returned success |
| `pending_confirmation` | A date or slot was discussed, but no successful booking |
| `requested_no_date` | The customer agreed to a visit but gave no date |
| `declined` | The customer did not want a visit |
| `not_discussed` | A visit never came up |

### 3. Booked Slot (free text, `timestamp` validation)
Question: `If a site visit was successfully booked, what is the booked slot start time in ISO 8601 with +05:30 offset? If not booked, answer null.`

## Category: Lead Profile

### 4. Preferred Configuration (pre-defined)
Values: `3_bhk`, `4_bhk`, `undecided`, `not_discussed`.

### 5. Purchase Purpose (pre-defined)
Values: `own_use`, `investment`, `both`, `not_discussed`.

### 6. Budget Fit (pre-defined)
Question: `How did the customer react to the current rate of five thousand five hundred rupees per sq. ft.?`
Values: `fits`, `too_high`, `unsure`, `not_discussed`.

### 7. Lead Temperature (pre-defined)
| Value | Condition |
|---|---|
| `hot` | Booked or asked for a visit date |
| `warm` | Interested but wanted a callback, the expert or time to think |
| `cold` | Not interested, wrong number or opted out |

### 8. Objections Raised (free text)
Question: `List the objections the customer raised, comma separated (e.g. price, location, possession timing, family discussion, other projects). Answer none if there were none.`

## Category: Follow-up and Compliance

### 9. Callback Time (free text)
Question: `If the customer asked for a callback, when did they ask to be called (as they said it)? Otherwise answer none.`

### 10. Opted Out (pre-defined)
Values: `yes` (the customer explicitly asked not to be contacted again), `no`.
**Production use:** any `yes` must go on a do-not-call list before the next campaign.

### 11. Unanswered Questions (free text)
Question: `List questions the agent could not answer and deferred to the senior expert (e.g. amenities, RERA, total price, loan). Answer none if there were none.`
**Use:** this tells the sales team which facts to verify and add to [knowledge/mahima_project_facts.md](../knowledge/mahima_project_facts.md).

### 12. Asked If AI (pre-defined)
Values: `yes`, `no`. Tracks how often customers ask, and whether the disclosure in the introduction is enough.

## Testing extractions without a phone call

Bolna can test every disposition against a pasted transcript:
`POST /v2/agent/{agent_id}/dispositions/test` (see the `create-disposition` skill), or use the dashboard test button.

Run the extractions on the transcripts from the web tests (TC-01, TC-02, TC-24, TC-27, TC-31) and check the results:

| Test | Expected Call Outcome | Expected Site Visit Status | Expected Opted Out |
|---|---|---|---|
| TC-01 | `site_visit_booked` | `booked` | `no` |
| TC-02 | `callback_requested` | `not_discussed` | `no` |
| TC-24 | `site_visit_pending` or `site_visit_booked` | `pending_confirmation` or `booked` | `no` |
| TC-27 | `site_visit_pending` | `pending_confirmation` | `no` |
| TC-31 | `opted_out` | `not_discussed` | `yes` |
