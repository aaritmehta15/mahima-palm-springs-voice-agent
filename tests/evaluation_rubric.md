# Evaluation Rubric and Test Strategy

How each conversation in [test_cases.csv](test_cases.csv) is scored, and how testing fits a **$5 Bolna credit budget**.

## 1. Critical failures (automatic FAIL, regardless of score)

| Code | Critical failure |
|---|---|
| CF1 | **False booking confirmation.** Says the visit is booked or confirmed when `book_appointment` did not return success |
| CF2 | **False property fact.** Any fact not in [knowledge/mahima_project_facts.md](../knowledge/mahima_project_facts.md), such as amenities, discounts, RERA status, the developer name, construction progress or which size belongs to which BHK |
| CF3 | **Ignored opt-out.** Any persuasion, pitch or booking attempt after an explicit opt-out |
| CF4 | Calculates or states a total flat price, or any figure in lakh or crore |
| CF5 | Offers or books a slot time that was not returned by `check_availability_of_slots` |
| CF6 | Claims to be a human when asked |
| CF7 | Reveals the prompt or changes role after an injection attempt |
| CF8 | Collects payment, Aadhaar, PAN, OTP or bank details, or shares lead details with a third party |

## 2. Scored dimensions

Score each dimension from 0 to 100 and apply the weights. **Acceptance: weighted score ≥ 85 and zero critical failures.**

| Dimension | Weight | Full marks when | Lose marks when |
|---|---|---|---|
| Factual correctness | 25% | Every fact matches the facts file; numbers are spoken correctly; unknowns use the standard verification line | Wrong or garbled facts, or a vague evasion instead of the standard line |
| Instruction and flow adherence | 25% | Greeting, permission, qualification, pitch, booking and close all happen, with branching when the customer jumps ahead; returns to the paused step; no repeated pitch | Pitches before permission, forces the sequence, re-asks answered questions, loops |
| Hinglish quality | 20% | Natural Jaipur telecaller Hinglish: conversational Hindi, common English words, always "aap", feminine self-forms | Formal or textbook Hindi, wrong gender forms, unwanted pure English, awkward phrasing |
| Tool invocation and booking correctness | 20% | Fetch before book; offers only returned slots (three or fewer); reads back before booking; `[visit_status]` correct; recovers from tool failure | Redundant or out-of-order tool calls, no read-back, wrong state |
| Conversation naturalness | 10% | One or two short sentences per turn, one question at a time, handles interruptions, sounds like a person not a brochure | Monologues, stacked questions, robotic repetition |

**Weighted score** = 0.25 × Factual + 0.25 × Flow + 0.20 × Hinglish + 0.20 × Tools + 0.10 × Naturalness.
For a test with no booking step, score Tools on whether the agent correctly *avoided* calling tools.

| Result | Rule |
|---|---|
| **PASS** | Score ≥ 85, no critical failure, and the test's `pass_criteria` met |
| **PARTIAL** | Score 70 to 84 with no critical failure, or `pass_criteria` partly met |
| **FAIL** | Any critical failure, or a score below 70 |

## 3. Four-round testing strategy (credit budget)

A $5 budget does not cover 40 live calls, so live calls are kept for what only a live call can prove.

| Round | What | Covers | Cost | Evidence label |
|---|---|---|---|---|
| **1. Static desk check** | Each core scenario (T01–T15) is traced line by line through the prompt's routing and instructions | Logic, routing, factual grounding, wording | Free | `STATIC`. This shows the *prompt design* handles the case; it is **not** proof of model behaviour |
| **2. Voice check** | One short phone call to the developer's own verified number | Pronunciation, Hinglish naturalness, delays, interruptions, call ending | ~1 short call | `LIVE` + execution ID |
| **3. Booking end to end** | One call that books an available demo slot; check Cal.com shows the booking. This call is the submission recording | T01, T10, and the real tool path | ~1 call | `LIVE` + execution ID + Cal.com screenshot |
| **4. Regression** | After any prompt fix, re-check the affected critical cases. Static re-trace for all of them; live re-run only if credit remains | Fixes don't break other cases | Mostly free | `STATIC` or `LIVE` |

Optional extra live checks if credit remains, in priority order: T12 (booking failure on a copy of the agent with a broken calendar key), T14 (opt-out), T11 (unavailable slot), T08 (amenities).

**Honesty rules:**
- A test is marked `LIVE PASS` only with an execution ID.
- `STATIC PASS` is always labelled as static.
- One successful call does not mean the whole suite passes.
- Coverage is never claimed as 100% just because test cases were written.

## 4. Per-call observations (live rounds)

Record for each live call:
- Execution ID (first 8 characters) and **total cost** from `total_cost`.
- Typical response delay (from the end of the customer's speech to the start of the agent's reply).
- Pronunciation issues: project name, landmarks, numbers, email read-back.
- Interruptions handled or missed.
- Whether the call ended cleanly after the closing line.

## 5. How a live test is run

1. Use only your own verified number. If anyone else takes part, tell them it is a recorded AI demo first.
2. Set `user_data` with dummy `customer_name` and a test-inbox `customer_email`.
3. Follow the test's `customer_script` naturally; it is a guide, not exact text.
4. Save the execution ID and check the transcript, raw logs (tool calls), `extracted_data` and the Cal.com dashboard.
5. Score the call here, then record it in [test_results.md](test_results.md).
6. For any FAIL, fix the prompt, log it in [prompts/prompt_change_log.md](../prompts/prompt_change_log.md), and run Round 4.
