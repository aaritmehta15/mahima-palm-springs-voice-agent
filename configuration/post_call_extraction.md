# Post-Call Extraction (Bolna Dispositions)

After every call, Bolna runs these extraction questions over the transcript and stores the answers in `extracted_data` on the execution. This gives the evaluator a structured **business outcome** for every call, with no database or CRM. Reference: [.agents/skills/create-disposition/SKILL.md](../.agents/skills/create-disposition/SKILL.md).

> Add these **after** the main conversation works. They are an enhancement, not a requirement for the first test call.

Configure in the dashboard: Agent → **Analytics / Extractions**. Each item below is one disposition. Use model `gpt-4.1-mini`.

**System prompt for all dispositions:**
`You are analysing a transcript of an outbound Hinglish sales call by Neha, an AI assistant for Mahima Palm Springs, Jaipur. Judge only from what was actually said and from tool results in the transcript. If something was not discussed, choose the "not discussed" or "none" option.`

## Category: Call Outcome

### 1. Call Outcome (pre-defined)
Question: `What was the final outcome of this call?`

| Value | Condition |
|---|---|
| `interested` | The customer showed interest and a site visit was confirmed or is pending confirmation |
| `follow_up` | The customer was busy, asked for a callback, or asked for a senior expert or sales team confirmation |
| `not_interested` | The customer declined |
| `wrong_number` | Wrong person, or no enquiry was made |
| `opted_out` | The customer explicitly asked not to be called again |
| `no_conversation` | Voicemail, silence or disconnected before the introduction |

### 2. Site Visit Status (pre-defined): same three states as the prompt's `[visit_status]`
Question: `What is the status of the site visit?`

| Value | Condition |
|---|---|
| `not_requested` | No visit was requested, or the customer declined a visit |
| `pending_confirmation` | The customer wanted a visit or gave a preferred date or time, but the booking tool did not return a successful booking |
| `confirmed` | **Only** if `book_appointment` returned a successful booking in the transcript or tool log |

### 3. Preferred Visit Time (free text)
Question: `What date and time did the customer ask for or agree to for the site visit, as they said it? If confirmed, give the booked slot in ISO 8601 with a +05:30 offset. Otherwise answer none.`

## Category: Lead Profile

### 4. Configuration Interest (pre-defined)
Values: `3_bhk`, `4_bhk`, `undecided`, `not_discussed`.

### 5. Interest Level (pre-defined)
| Value | Condition |
|---|---|
| `high` | Visit confirmed, or a specific visit date was requested |
| `medium` | Interested but wanted a callback, the expert, or time to think |
| `low` | Not interested, wrong number or opted out |

### 6. Objections Raised (free text)
Question: `List the objections the customer raised, comma separated (e.g. price, location, possession timing, family discussion, other projects). Answer none if there were none.`

## Category: Follow-up and Compliance

### 7. Callback Requested (pre-defined, plus free text)
Values: `yes`, `no`. Free text: `When did the customer ask to be called back, as they said it? Answer none if not asked.`

> The "senior expert will call tomorrow between 10 AM and 5 PM" line is from the assessment's example script. In this demo, the request is **recorded** only in this extraction field. No real scheduling system acts on it, and the documentation does not claim otherwise.

### 8. Opt-out (pre-defined)
Values: `true` (the customer explicitly asked not to be contacted again), `false`.
**Production use:** every `true` must go on a do-not-call list before the next campaign.

### 9. Unknown Questions (free text)
Question: `List the questions the agent could not answer from verified facts and offered to get confirmed by the sales team (e.g. amenities, RERA, total price, loan, discount). Answer none if there were none.`
**Use:** shows the sales team which facts to verify and add to [knowledge/mahima_project_facts.md](../knowledge/mahima_project_facts.md).

### 10. Asked If AI (pre-defined)
Values: `yes`, `no`. Tracks whether the disclosure in the introduction is enough.

## Testing extractions without a phone call

Bolna can test every disposition against a pasted transcript:
`POST /v2/agent/{agent_id}/dispositions/test` (see the `create-disposition` skill), or use the dashboard test button.

Expected results on the test transcripts:

| Test | Call Outcome | Site Visit Status | Callback Requested | Opt-out |
|---|---|---|---|---|
| TC-01 interested, books | `interested` | `confirmed` | `no` | `false` |
| TC-02 busy | `follow_up` | `not_requested` | `yes` | `false` |
| TC-04 not interested | `not_interested` | `not_requested` | `no` | `false` |
| TC-25 slot unavailable | `interested` | `confirmed` or `pending_confirmation` | `no` | `false` |
| TC-27 booking tool fails | `interested` | `pending_confirmation` | `no` | `false` |
| TC-31 opt-out | `opted_out` | `not_requested` | `no` | `true` |
