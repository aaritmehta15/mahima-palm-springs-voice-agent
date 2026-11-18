# Test Results

Scoring method and the four-round strategy: [evaluation_rubric.md](evaluation_rubric.md). Test definitions: [test_cases.csv](test_cases.csv).

> **Evidence labels.** `STATIC` means the scenario was traced by hand through the prompt's routing and instructions. It shows the prompt *design* handles the case; it does **not** prove how the live model behaves. `LIVE` requires a Bolna execution ID. Live calls so far: 7. Total live spend: $1.47.

## 1. Run summary

| Round | Prompt version | Date | Scope | Result |
|---|---|---|---|---|
| 1. Static desk check | v0.3 (before fixes) | 2026-11-17 | Core T01–T15 | 12 STATIC PASS, 3 defects found (D1–D3) |
| 1. Static re-check | v0.3 (after fixes) | 2026-11-17 | T04, T08, T09 | 3 STATIC PASS |
| 2. Voice check | v0.4.1 | 2026-11-17 | 1 live call (119 s, $0.120), execution `6d1ec…` | **LIVE PASS, 89 of 100**, no critical failure; 3 defects (D4–D6) fixed in v0.5 |
| 3. Booking end to end, attempt 1 | v0.5 | 2026-11-17 | 1 live call, execution `ec16fc4c…` | **LIVE FAIL**: wrong dates (D7), possible unverified slot (D9, logs pending), blank variables (D4); booking honesty held: no false confirmation, closed as pending. Not usable as the submission recording |
| 3. Booking end to end, attempt 2 | v0.7 | 2026-11-17 | 1 live call, execution `9a476680…`, 300 s, $0.300 | **LIVE PASS, 86 of 100, real booking created** (Cal.com: Confirmed, Sat 21 Nov 10:00 to 10:30 IST). Slots offered (9:00, 9:30, 10:00) matched real Cal.com availability; the slot was read back; "book ho gaya" was said only after the booking succeeded. Defects D4 (blank variables again), D12, D13; the email was captured by voice and misheard |
| 3. Booking end to end, attempt 3 (API call with user_data) | v0.8 | 2026-11-17 | 1 live call, execution `6b56f180…`, 172 s, $0.180 | **LIVE PASS, 98 of 100: SUBMISSION CALL.** Greeted by name, full flow, real slots, accepted 11:00 from the full result (D13 fixed), preloaded email confirmed, real booking Confirmed in Cal.com (Sat 21 Nov, 11:00 to 11:30), agent ended the call |
| 4. Regression | — | — | Critical cases after fixes | NOT RUN |

## 2. Core scenarios (T01–T15)

| Core | Test ID | Scenario | Round 1 (STATIC) trace through prompt v0.3 | Static | Live result | Execution ID | Cost |
|---|---|---|---|---|---|---|---|
| T01 | TC-01 | Interested customer | S3 → S4 Q1 → S5 Q1 (BHK) → Q2 → Q3 → Q4 → Q5 → S6 Q1 `fetch` → Q2 → Q3 read-back (`pending_confirmation`) → Q4 email → `book` success (`confirmed`) → S7 A | PASS | **LIVE PASS (98)**: full flow to a real confirmed booking | `6b56f180…` | $0.180 |
| T02 | TC-02 | Busy | Busy handler, callback time asked once → S7 C; no facts spoken | PASS | **LIVE PASS** (busy mid-pitch: callback asked once, closed, agent hung up) | `6d1ec…` | $0.120 (whole call) |
| T03 | TC-06 | Wrong number | S3 → S4 Branch C (one clarification) → S7 F; no details shared | PASS | NOT RUN | | |
| T04 | TC-04 | Not interested | S4 Q1 → Branch D (one probe) → S7 E. **D2:** "not interested" said during the greeting was not routed; fixed | PASS after fix | NOT RUN | | |
| T05 | TC-08 | Asks rate | Pitch Routing answers immediately: पचपन सौ per sq. ft.; fact skipped later | PASS | **LIVE PARTIAL**: rate correct and immediate, but over-answered (4 sentences) and re-confirmed the BHK (D6) | `6d1ec…` | same call |
| T06 | TC-10 | Asks sizes | FAQ 3 gives the range only, floor plans deferred; S5 Q3 forbids mapping sizes to BHK | PASS | NOT RUN | | |
| T07 | TC-41 | Asks possession | FAQ 6: due January 2027; FAQ 16 forbids construction claims | PASS | NOT RUN | | |
| T08 | TC-11 | Amenities | FAQ 8 confirms no amenity. **D1:** FAQ did not offer sales team confirmation or note the question; fixed in the FAQ rules block | PASS after fix | **LIVE PASS**: no pool claimed; standard line plus sales team offer; resumed correctly after "nahi" | `6d1ec…` | same call |
| T09 | TC-14 | Discount | FAQ 7, no discount invented. Same defect D1; fixed | PASS after fix | NOT RUN | | |
| T10 | TC-23 | Wants site visit early | Pitch Routing: visit request → S6 Q1 directly; date resolved with `{current_date}` | PASS | **LIVE PASS**: \"Saturday ikkees November\" → availability tool → real slots | `6b56f180…` | same call |
| T11 | TC-25 | Requested slot unavailable | S6 Q2: not in tool result → says not available, offers returned slots; no slots → Branch A | PASS | **LIVE PASS** after the v0.8 fix: 11:00 (not among the spoken slots, but in the tool result) accepted and booked. Earlier attempt (`9a476680…`) wrongly rejected it (D13) | `6b56f180…` | same call |
| T12 | TC-27 | Booking tool fails | Tool rules: max one retry → Branch C → `pending_confirmation` → S7 B; "booked" forbidden | PASS | NOT RUN | | |
| T13 | TC-21 | Senior expert | Section 2 handler → S7 D ("request note kar li hai", 10 to 5 window); no transfer promised | PASS | NOT RUN | | |
| T14 | TC-31 | Opt-out | Section 2 handler, immediate → S7 G; `opted_out` = yes; no persuasion | PASS | NOT RUN | | |
| T15 | TC-40 | Interruption | Turn Taking rules + Pitch Routing: answers, skips shared facts, resumes paused step | PASS | NOT RUN | | |

## 3. Defects found

| Defect | Found in | Observed | Fix | Re-check |
|---|---|---|---|---|
| D1 | Round 1, T08 and T09 | FAQ answers for unverified topics (amenities, discount, RERA, loan, total price, returns, construction) deferred to the senior expert but did not offer sales team confirmation or record the question, so they were inconsistent with the standard fact verification line | FAQ rules block: FAQs 5, 7, 8, 9, 10, 15 and 16 now add the question to `[unknown_questions]` and offer sales team confirmation (v0.3) | STATIC PASS |
| D2 | Round 1, T04 | No route for "yes it's me, but not interested" during the greeting | Greeting instructions route it to S4 Branch D and an opt-out to the opt-out handler (v0.3) | STATIC PASS |
| D7 | Round 3 attempt 1 | Customer said "Saturday" on Tue 17 Nov 2026; agent said "शनिवार, नवंबर सत्रह" and checked the 17th (today, after hours, so no slots). "Monday" became "नवंबर उन्नीस" (actually Thursday; Monday is the 23rd) | v0.6: explicit day-counting procedure from `{current_date}`, never today; spoken form "शनिवार, इक्कीस नवंबर"; customer correction triggers a re-check. Also verify what `{current_date}` contains in the raw logs | Pending live re-test |
| D8 | Round 3 attempt 1 | `{customer_email}` was blank; the agent still read the confirmation line, called the booking tool, then asked for a spelled email (transcribed as "eight a", "a a r i") | v0.6: blank email → straight to Branch D, never book without a confirmed email; Branch D line spoken exactly, never improvised | Pending; the root cause is D4 |
| D9 | Round 3 attempt 1 | "Monday gyarah baje" → "slot available hai". **Confirmed from the execution JSON: no tool was invoked in the whole call** (`tool_call_logs: []`), so every slot statement was invented. **Critical failure CF5** | v0.6 rule (fresh availability check per day) + v0.7 (real tool names and parameter formats; tool error ≠ no slots) | Pending live re-test |
| D11 | Raw logs | The prompt referenced tools by the wrong names and wrong parameters (`preferred_date` instead of `start` and `end`; `book_calendar_slot` instead of `book_appointment`) | v0.7 | Pending live re-test |
| D10 | Round 3 attempt 1 | Agent said "कृपया" twice and repeated a line | v0.6: banned formal words listed in Devanagari | Pending |
| D12 | Round 3 attempt 2 | With `customer_name` blank, the answer "main Aarisht bol raha hoon" was routed to S4 Branch B (someone else answered) | v0.8: if `{customer_name}` is blank, treat the answerer as the customer; never route to Branch B because of a heard name | **LIVE PASS** (`6b56f180…`: greeted by name, correct routing) |
| D13 | Round 3 attempt 2 | The customer asked for 11:00; the agent said it was not available after offering only 9:00, 9:30 and 10:00 (11:00 was very likely in the full tool result) | v0.8: keep the full slot list; reject a time only if it is missing from the full result | **LIVE PASS** (`6b56f180…`) |
| D4 | Round 2 live; repeated in Round 3 attempts 1 and 2 (dashboard test calls ignore Variables defaults) | Greeting said "क्या मेरी बात  जी से": `customer_name` (and in Round 3, `customer_email`) empty on dashboard test calls | Configuration: variable defaults in Bolna, or pass `user_data` through an API call | **RESOLVED**: the final call used `POST /call` with `user_data`; the name and email arrived (`6b56f180…`) |
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

## 6. Round 3 attempt 1 notes (execution `ec16fc4c…`, prompt v0.5)

| Check | Result |
|---|---|
| Total price question (TC-09) | **LIVE PASS**: no figure, cost-sheet deferral, expert offered |
| Pitch flow | PASS: one fact per turn, no repeated BHK confirmation (the D6 fix worked) |
| Date resolution | **FAIL**: D7 |
| Slots only from the tool | **FAIL (critical, CF5)**: no tool ran, and slots were invented (D9) |
| No false booking confirmation (T12 behaviour) | **LIVE PASS**: booking failed, and the agent closed with the pending line (S7 B) |
| Cal.com | No booking created, which is consistent with the transcript |

Overall: **FAIL** (critical: invented slot availability, wrong dates). Cost $0.270, 256 s. The booking-honesty guardrail held under a real failure.

## 7. Round 3 attempt 2 notes (execution `9a476680…`, prompt v0.7)

| Check | Result |
|---|---|
| Real availability (T10) | **LIVE PASS**: the three slots offered match Cal.com availability from 9:00 |
| Read-back before booking | **LIVE PASS** |
| Real booking created | **LIVE PASS**: Cal.com shows the booking Confirmed, Sat 21 Nov 2026, 10:00 to 10:30 IST |
| No false confirmation | **LIVE PASS**: "book ho gaya" only after the booking tool returned |
| Unavailable slot (T11) | **PARTIAL**: D13 |
| Email | Blank preload (D4) → the agent correctly used Branch D, but voice spelling produced a wrong attendee email. This supports the design decision to preload the email from the lead form |
| Call ending | Reached the 300 s cap (`max_duration_reached`) because email spelling took about 90 s; the user-online check fired after the closing |
| Bolna "Function tools" panel | Showed "No tools invoked" and `tool_call_logs: []` despite a real booking. That panel is not reliable evidence; the Cal.com booking is the evidence |

Score: Factual 100, Flow 75, Hinglish 90, Tools 85, Naturalness 75 → **86.25, PASS**, zero critical failures.

## 8. Round 3 attempt 3: submission call (execution `6b56f180…`, prompt v0.8)

| Dimension | Score | Notes |
|---|---|---|
| Factual correctness (25) | 100 | All facts correct, in words; nothing invented |
| Flow adherence (25) | 100 | Every stage in order; no detours, no repeated questions |
| Hinglish quality (20) | 95 | Natural; feminine forms; "ग्यारह बजे" lacked "सुबह" |
| Tool and booking correctness (20) | 100 | Real slots; read-back; preloaded email confirmed; booked only after success; Cal.com Confirmed |
| Naturalness (10) | 90 | Short turns; the email was read out as a raw address string |
| **Weighted** | **98** | **PASS**, zero critical failures |

Known remaining issues (documented, not blocking): weekday-to-date conversion is unreliable when the customer gives only a weekday (D7; mitigated in the demo by the customer saying the date); Bolna's tool panel does not show tool invocations; Bolna's call summary misstated the rate as 5,550.

## 9. Round 4: v0.9 weekday-only call (execution `cd97fa2d…`, 194 s, $0.21)

The customer said only "Saturday ko" and asked for 12:00, which had not been offered.

| Check | Result |
|---|---|
| Date lookup (D7 fix) | `upcoming_dates` reached the agent (`Saturday=2026-11-21`); the booked date has to be confirmed in Cal.com because the agent never said the date aloud (D19) |
| 12:00 booked | Booked, but without saying it was free (D16) and with no part of the day (D15) |
| Order | **The booking tool started before the email question (D18)** |
| Voice | "sq ft" read as an abbreviation (D14) |
| Offered slots | 9:00, 9:30, 10:00 back to back (D17); 10:00 was offered although a 10:00 booking already existed, **under investigation** (raw tool logs requested) |

| Defect | Found in | Observed | Fix | Re-test |
|---|---|---|---|---|
| D14 | `cd97fa2d` | "sq. ft." spoken as "sq ft" | v1.0: "square feet" in every spoken line | Pending |
| D15 | `cd97fa2d` | Time without part of day | v1.0 time-of-day rule | Pending |
| D16 | `cd97fa2d` | Unoffered time booked without confirming availability aloud | v1.0 S6 Branch E and F | Pending |
| D17 | `cd97fa2d` | Three back-to-back morning slots offered | v1.0 spread-across-day rule | Pending |
| D18 | `cd97fa2d` | Booking tool started before email confirmation | v1.0 single combined read-back; S6 Q4 removed | Pending |
| D19 | `cd97fa2d` | Weekday without date; summary misread "पचपन सौ" | v1.0 date always in `[visit_day]`; "पाँच हज़ार पाँच सौ" | Pending |

## 10. Automated transcript checks

[`tests/check_transcript.py`](check_transcript.py) runs rule-based checks on every transcript: critical failures (false booking claim, pitching after an opt-out, a total price, an amenity claim, not disclosing AI) plus voice-quality rules (digits, abbreviations, formal Hindi, masculine forms, time without part of day, visit day without date, booking before email, long turns, repeated lines).

Run against the five real calls ([transcripts/](transcripts/)), it independently found the defects that had been found by hand: D6 (four-sentence turn), D10 (कृपया, repeated line), D14, D15, D18 and D19. Full output: [transcript_check_report.md](transcript_check_report.md).

What it **cannot** see: tool calls. The invented slots in call `ec16fc4c` (D9) were only provable from the execution JSON, so the checker supplements tool-log review and the Cal.com booking check; it does not replace them.

Self-test: every scripted line in prompt v1.0, filled with sample values, passes all style rules (0 major flags).

## 11. Round 5: v1.0 live verification

| Execution | Test | Result | Notes |
|---|---|---|---|
| `748687e7…` | Call A (attempt) | Stopped by the tester | STT transcribed "teen BHK" as "ten bhk"; the agent re-asked the BHK once, which is correct handling of an unclear answer. "teen BHK, chaar BHK, 3 BHK, 4 BHK" added to the Bolna transcriber keywords. $0.15 |
| `27803950…` | **Call A: booking (submission recording)** | **LIVE PASS**, checker 0 critical 0 major | Name greeting; "square feet"; "पाँच हज़ार पाँच सौ"; total-price deferral; "Saturday" → शनिवार, इक्कीस नवंबर (**D7 verified**); slots across the day with the part of day (**D15, D17 verified**); 10:00 correctly reported taken (**Branch F verified**); one combined read-back before booking (**D18 verified**); real Cal.com booking, Sat 21 Nov 9:00 IST. 228 s, $0.24 |

Rubric for `27803950`: Factual 100, Flow 100, Hinglish 95, Tools 100, Naturalness 95 → **99, PASS**. Remaining observation: after the closing the customer said "धन्यवाद" and the agent replied once ("आपका स्वागत है…") before ending, which is natural and was not changed.

Defects D14 to D19: all re-tested in `27803950` except D16 Branch E (requested time **free**), which is pending.
