# Test Results

Scoring method and the four-round strategy: [evaluation_rubric.md](evaluation_rubric.md). Test definitions: [test_cases.csv](test_cases.csv).

> **Evidence labels.** `STATIC` means the scenario was traced by hand through the prompt's routing and instructions. It shows the prompt *design* handles the case; it does **not** prove how the live model behaves. `LIVE` requires a Bolna execution ID. Live calls so far: 1 (Round 2).

## 1. Run summary

| Round | Prompt version | Date | Scope | Result |
|---|---|---|---|---|
| 1. Static desk check | v0.3 (before fixes) | 2026-11-17 | Core T01–T15 | 12 STATIC PASS, 3 defects found (D1–D3) |
| 1. Static re-check | v0.3 (after fixes) | 2026-11-17 | T04, T08, T09 | 3 STATIC PASS |
| 2. Voice check | v0.4.1 | 2026-11-17 | 1 live call (119 s, $0.120), execution `6d1ec…` | **LIVE PASS, 89 of 100**, no critical failure; 3 defects (D4–D6) fixed in v0.5 |
| 3. Booking end to end | — | — | T01, T10 live | NOT RUN |
| 4. Regression | — | — | Critical cases after fixes | NOT RUN |

## 2. Core scenarios (T01–T15)

| Core | Test ID | Scenario | Round 1 (STATIC) trace through prompt v0.3 | Static | Live result | Execution ID | Cost |
|---|---|---|---|---|---|---|---|
| T01 | TC-01 | Interested customer | S3 → S4 Q1 → S5 Q1 (BHK) → Q2 → Q3 → Q4 → Q5 → S6 Q1 `fetch` → Q2 → Q3 read-back (`pending_confirmation`) → Q4 email → `book` success (`confirmed`) → S7 A | PASS | NOT RUN | | |
| T02 | TC-02 | Busy | Busy handler, callback time asked once → S7 C; no facts spoken | PASS | **LIVE PASS** (busy mid-pitch: callback asked once, closed, agent hung up) | `6d1ec…` | $0.120 (whole call) |
| T03 | TC-06 | Wrong number | S3 → S4 Branch C (one clarification) → S7 F; no details shared | PASS | NOT RUN | | |
| T04 | TC-04 | Not interested | S4 Q1 → Branch D (one probe) → S7 E. **D2:** "not interested" said during the greeting was not routed; fixed | PASS after fix | NOT RUN | | |
| T05 | TC-08 | Asks rate | Pitch Routing answers immediately: पचपन सौ per sq. ft.; fact skipped later | PASS | **LIVE PARTIAL**: rate correct and immediate, but over-answered (4 sentences) and re-confirmed the BHK (D6) | `6d1ec…` | same call |
| T06 | TC-10 | Asks sizes | FAQ 3 gives the range only, floor plans deferred; S5 Q3 forbids mapping sizes to BHK | PASS | NOT RUN | | |
| T07 | TC-41 | Asks possession | FAQ 6: due January 2027; FAQ 16 forbids construction claims | PASS | NOT RUN | | |
| T08 | TC-11 | Amenities | FAQ 8 confirms no amenity. **D1:** FAQ did not offer sales team confirmation or note the question; fixed in the FAQ rules block | PASS after fix | **LIVE PASS**: no pool claimed; standard line plus sales team offer; resumed correctly after "nahi" | `6d1ec…` | same call |
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
| D4 | Round 2 live | Greeting said "क्या मेरी बात  जी से": `customer_name` was empty on the dashboard test call | Set default values in Bolna Variables (configuration fix) | Pending re-test |
| D5 | Round 2 live | The transcriber heard "Aarit" as "आरेन्द्र", and the agent addressed the customer by that misheard name | v0.5: address only by `{customer_name}`, otherwise "आप"; never use a name heard on the call | STATIC PASS; live re-test pending |
| D6 | Round 2 live | "Teen BHK, rate kya hai?" got rate + sizes + floor plan + "teen BHK, sahi hai?" (4 sentences, re-confirmation) | v0.5: answer only what was asked, in one sentence; never re-confirm what the customer said | STATIC PASS; live re-test pending |
| D3 | Round 1, T05 | The S4 Q1 instruction said a permission check happens at S5 Q1, but S5 Q1 has no permission check | The question is now treated as permission, and the call follows Pitch Routing (v0.3) | STATIC PASS |

## 4. Remaining test cases (TC-01 to TC-41)

The other 26 cases in [test_cases.csv](test_cases.csv) are documented scenarios. They are **NOT RUN** in this round; they are checked statically or live only if budget remains after Rounds 2 and 3. Any case run later is added here with its label and evidence.

## 5. Round 2 scoring detail (execution `6d1ec…`, prompt v0.4.1)

| Dimension | Weight | Score | Notes |
|---|---|---|---|
| Factual correctness | 25 | 100 | Rate and size range correct and in words; no amenity invented |
| Flow adherence | 25 | 75 | Permission before pitch, branching on the rate question, resumed after the FAQ, callback asked once; but the greeting had a blank name (D4) and the BHK was re-confirmed (D6) |
| Hinglish quality | 20 | 90 | Natural; feminine forms correct (समझ गई); always आप |
| Tool and booking correctness | 20 | 100 | No tools needed, none called; no booking language |
| Naturalness | 10 | 70 | One four-sentence turn; addressed the customer by a misheard name |
| **Weighted** | | **88.75** | **PASS** (≥ 85, zero critical failures) |

Observations: the agent ended the call itself after the closing ("Agent ended call"). Duration 119 s; cost $0.120. The tester reported no pronunciation problems other than the name issue.
