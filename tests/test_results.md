# Test Results

Scoring method and the four-round strategy: [evaluation_rubric.md](evaluation_rubric.md). Test definitions: [test_cases.csv](test_cases.csv).

> **Evidence labels.** `STATIC` means the scenario was traced by hand through the prompt's routing and instructions. It shows the prompt *design* handles the case; it does **not** prove how the live model behaves. `LIVE` requires a Bolna execution ID. No live call has been made yet.

## 1. Run summary

| Round | Prompt version | Date | Scope | Result |
|---|---|---|---|---|
| 1. Static desk check | v0.3 (before fixes) | 2026-11-17 | Core T01–T15 | 12 STATIC PASS, 3 defects found (D1–D3) |
| 1. Static re-check | v0.3 (after fixes) | 2026-11-17 | T04, T08, T09 | 3 STATIC PASS |
| 2. Voice check | — | — | 1 live call | NOT RUN |
| 3. Booking end to end | — | — | T01, T10 live | NOT RUN |
| 4. Regression | — | — | Critical cases after fixes | NOT RUN |

## 2. Core scenarios (T01–T15)

| Core | Test ID | Scenario | Round 1 (STATIC) trace through prompt v0.3 | Static | Live result | Execution ID | Cost |
|---|---|---|---|---|---|---|---|
| T01 | TC-01 | Interested customer | S3 → S4 Q1 → S5 Q1 (BHK) → Q2 → Q3 → Q4 → Q5 → S6 Q1 `fetch` → Q2 → Q3 read-back (`pending_confirmation`) → Q4 email → `book` success (`confirmed`) → S7 A | PASS | NOT RUN | | |
| T02 | TC-02 | Busy | S4 Q1 → Branch A, callback time asked once → S7 C; no facts spoken | PASS | NOT RUN | | |
| T03 | TC-06 | Wrong number | S3 → S4 Branch C (one clarification) → S7 F; no details shared | PASS | NOT RUN | | |
| T04 | TC-04 | Not interested | S4 Q1 → Branch D (one probe) → S7 E. **D2:** "not interested" said during the greeting was not routed; fixed | PASS after fix | NOT RUN | | |
| T05 | TC-08 | Asks rate | Pitch Routing answers immediately: पचपन सौ per sq. ft.; fact skipped later | PASS | NOT RUN | | |
| T06 | TC-10 | Asks sizes | FAQ 3 gives the range only, floor plans deferred; S5 Q3 forbids mapping sizes to BHK | PASS | NOT RUN | | |
| T07 | TC-41 | Asks possession | FAQ 6: due January 2027; FAQ 16 forbids construction claims | PASS | NOT RUN | | |
| T08 | TC-11 | Amenities | FAQ 8 confirms no amenity. **D1:** FAQ did not offer sales team confirmation or note the question; fixed in the FAQ rules block | PASS after fix | NOT RUN | | |
| T09 | TC-14 | Discount | FAQ 7, no discount invented. Same defect D1; fixed | PASS after fix | NOT RUN | | |
| T10 | TC-23 | Wants site visit early | Pitch Routing: visit request → S6 Q1 directly; date resolved with `{current_date}` | PASS | NOT RUN | | |
| T11 | TC-25 | Requested slot unavailable | S6 Q2: not in tool result → says not available, offers returned slots; no slots → Branch A | PASS | NOT RUN | | |
| T12 | TC-27 | Booking tool fails | Tool rules: max one retry → Branch C → `pending_confirmation` → S7 B; "booked" forbidden | PASS | NOT RUN | | |
| T13 | TC-21 | Senior expert | Section 2 handler → S7 D ("request note kar li hai", 10 to 5 window); no transfer promised | PASS | NOT RUN | | |
| T14 | TC-31 | Opt-out | Section 2 handler, immediate → S7 G; `opted_out` = yes; no persuasion | PASS | NOT RUN | | |
| T15 | TC-40 | Interruption | Turn Taking rules + Pitch Routing: answers, skips shared facts, resumes paused step | PASS | NOT RUN | | |

## 3. Defects found

| Defect | Found in | Observed | Fix | Re-check |
|---|---|---|---|---|
| D1 | Round 1, T08 and T09 | FAQ answers for unverified topics (amenities, discount, RERA, loan, total price, returns, construction) deferred to the senior expert but did not offer sales team confirmation or record the question, so they were inconsistent with the standard fact verification line | FAQ rules block: FAQs 5, 7, 8, 9, 10, 15 and 16 now add the question to `[unknown_questions]` and offer sales team confirmation (v0.3) | STATIC PASS |
| D2 | Round 1, T04 | No route for "yes it's me, but not interested" during the greeting | Greeting instructions route it to S4 Branch D and an opt-out to the opt-out handler (v0.3) | STATIC PASS |
| D3 | Round 1, T05 | The S4 Q1 instruction said a permission check happens at S5 Q1, but S5 Q1 has no permission check | The question is now treated as permission, and the call follows Pitch Routing (v0.3) | STATIC PASS |

## 4. Remaining test cases (TC-01 to TC-41)

The other 26 cases in [test_cases.csv](test_cases.csv) are documented scenarios. They are **NOT RUN** in this round; they are checked statically or live only if budget remains after Rounds 2 and 3. Any case run later is added here with its label and evidence.
