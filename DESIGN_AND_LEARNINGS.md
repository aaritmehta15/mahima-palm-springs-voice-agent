# Design Choices, Prompt Style and What I Learned

**In one line:** I treated the prompt as a piece of software. It has a spec, a test suite and a defect log, and I made eleven versions (v0.1 to v1.0), each driven by evidence from real calls or checks. The final v1.0 booking call created a real Cal.com booking, and all five v1.0 live scenarios passed.

---

## 1. The problem, reframed

The brief reads like "write a Hinglish sales script". Underneath it are three harder problems:

1. **Truthfulness under pressure.** Only five property facts exist. A sales agent is tempted to fill gaps: amenities, totals, discounts. One invented fact is worse than no call at all.
2. **Actions, not just words.** "Your site visit is booked" must mean a booking actually exists.
3. **Voice is a different medium.** Long sentences, lists and spelled-out emails all fail on a phone line, especially in code-switched Hinglish.

Every design decision below targets one of these three.

---

## 2. Prompt style: why it looks the way it does

| Choice | Reason |
|---|---|
| **Nine numbered sections**: Background, Global Rules, then the five script stages in the order the brief requires, then Guardrails, then FAQs | Easy to audit, and each section has one job. The model reads it as a procedure, not a vibe |
| **`Agent:` line + `Instructions:` paragraph** for all 56 dialogues | The brief asks for it, and it splits *what to say* from *how to decide what comes next*. Routing lives only in Instructions, never in the spoken text |
| **One facts block** (Verified Project Facts), referenced everywhere, never repeated | A single source of truth. When the sales team verifies a new fact, it changes in one place |
| **Anytime handlers** (opt-out, AI question, unknown fact, busy, abuse, silence, off-topic) | Real customers don't follow the script order. These override any step |
| **Facts as a menu, not a questionnaire** (Pitch Routing) | If the customer asks the price first, Neha answers immediately and skips that fact later |
| **Explicit state variable `[visit_status]`**: `not_requested` → `pending_confirmation` → `confirmed` | Turns "don't lie about bookings" from a hope into a rule the model can track |
| **Devanagari Hinglish**, with English words where Jaipur speakers use them (flat, rate, possession, site visit) | Sarvam TTS pronounces Devanagari far better than Roman Hindi; formal Hindi (कृपया, उपलब्ध) is banned |
| **Numbers in words**, no symbols, at most two sentences per turn, one question per turn | TTS-safe and conversational; prevents monologues |
| **Honest AI disclosure** in the introduction | Trust, compliance, and no awkward moment if the customer asks |

---

## 3. The engineering story: every major decision came from a failure

I ran eleven live calls within a $5 budget ($1.80 spent), plus static desk checks of 15 core scenarios. Each failure became a rule.

| # | What went wrong (evidence) | Root cause | Fix | Verified |
|---|---|---|---|---|
| 1 | Bolna refused to save the prompt: "too large" at 11,957 tokens | Boilerplate repeated in seven places | Compacted by 53% with no logic lost (v0.4) | Saved at 6,062 tokens |
| 2 | The agent called me "**आरेन्द्र** जी": STT misheard "Aarit" and the model used the misheard name (call `6d1ec`) | The model trusted transcribed names | Address only by `{customer_name}`, never a heard name (v0.5) | Final call: "Aarit जी" |
| 3 | Asked the rate, got four sentences plus "teen BHK, sahi hai?" again | Over-answering, re-confirming | "Answer only what was asked, never re-confirm" (v0.5) | All later calls |
| 4 | **The agent invented calendar slots.** The execution JSON showed *no tool ran*, yet it said "Monday 11 baje available hai" (call `ec16fc4c`) | The prompt used guessed tool names and wrong parameters; on a tool error the model improvised | Read the real tool contract from Bolna's raw JSON; put exact names and parameter formats in the prompt; "a tool error is not 'no slots'" (v0.7) | Next call: real slots; **real booking in Cal.com** |
| 5 | "Saturday" became "शनिवार, नवंबर सत्रह", which was *today* (call `ec16fc4c`) | LLMs are bad at weekday arithmetic | Stop asking the model to calculate: the dialer sends `upcoming_dates` (`Saturday=2026-11-21, ...`) and the model looks it up (v0.9) | v1.0 call: "Saturday ko" → शनिवार, इक्कीस नवंबर |
| 6 | A voice-spelled email was booked as `daaritmetha...@gmail.com` (call `9a476680`) | Spelling an email over the phone defeats STT | Preload name and email from the lead via API `user_data`; the agent only reads it back | Final call: one "haan", correct email |
| 7 | "11 baje available nahi hai", although 11:00 was free | The model remembered only the three slots it had spoken | Keep the full tool result; reject only what is truly missing (v0.8) | Call `6b56f180`: 11:00 booked |
| 8 | A booking failed, and the agent **did not** claim success, closing with "team confirm karegi" | — (the guardrail worked) | — | Call `ec16fc4c` |
| 9 | "sq ft" read as an abbreviation, "बारह बजे" with no AM or PM, "शनिवार को" with no date (call `cd97fa2d`) | Text written for reading, not for listening | Units in full, every time with सुबह, दोपहर or शाम, every day with its date (v1.0) | Checker rules enforce it on every call |
| 10 | The booking tool fired **before** the email was confirmed | Two separate confirmation turns gave the model room to skip one | One read-back line confirms date, time and email together (v1.0) | Checker rule `ORDER_BOOKED_BEFORE_EMAIL` |
| 11 | "Kal call karna" was only a promise; nothing would call back | Words without a system behind them | `post_call.ps1` turns the extraction into a scheduled call; opt-outs go on a do-not-call list the dialer enforces | TC-46 and TC-47 |

**Final call (`27803950`, v1.0):** greeted by name → permission → qualification → pitch ("square feet", "पाँच हज़ार पाँच सौ") → total price deferred → "Saturday" looked up as शनिवार, इक्कीस नवंबर → real slots across the day → 10 AM correctly reported taken → one read-back of date, time and email → **booking Confirmed in Cal.com** → the agent ended the call. 228 s, $0.24. The other v1.0 live tests (guardrails, senior expert, callback, opt-out) also passed.

Full trail: [tests/test_results.md](tests/test_results.md) · [prompts/prompt_change_log.md](prompts/prompt_change_log.md) · [evidence/transcript.md](evidence/transcript.md)

---

## 4. What I learned

1. **The transcript lies; the logs don't.** Call 3 *sounded* like it checked the calendar: "ek second, check kar rahi hoon". Only the raw execution JSON showed no tool had run. For tool-using agents, evaluate tool logs and downstream state (the Cal.com booking), not just the conversation.
2. **The prompt and the tool schema are one contract.** Most of the bugs were not "bad wording". They were mismatches between what the prompt said and what the tool accepted. Prompt engineering for agents is interface engineering.
3. **Move work out of the LLM when it's deterministic.** Weekday maths and email spelling are solved problems in code and unreliable in a model. The best fixes were *architectural* (`upcoming_dates`, preloaded email), not more instructions.
4. **Honesty needs a state machine, not an adjective.** "Be truthful" didn't prevent invented slots. An explicit `pending_confirmation` state, plus "say booked only after tool success", held even under a real tool failure.
5. **Voice punishes verbosity.** Every extra sentence costs latency and money and invites interruption. "Answer only what was asked" improved both naturalness and cost.
6. **Voice is a different medium from text.** "sq. ft.", "बारह बजे" and "पचपन सौ" look fine on screen and fail on a phone: the first is read as letters, the second has no AM or PM, and the third was misread by Bolna's own summariser as ₹5,550. Write for the ear.
7. **Promises need plumbing.** "I'll call you tomorrow" and "we won't call again" are product commitments. They only become true when code acts on them: a scheduled call and an enforced do-not-call list.
8. **Automate the boring checks.** A 200-line rule checker re-found, on its own, most of the defects I had found by ear across my calls. It now runs after every call.
9. **Test cheaply, then test for real.** Static desk checks found 3 bugs for free; live calls found 17 more that no desk check could (STT mishearing, tool contracts, date maths). Both were needed.

---

## 5. Honest limitations

- The calendar is a **demonstration** Cal.com calendar, not Mahima's real site schedule.
- Only the five facts from the brief are verified. Everything else is deliberately escalated.
- Busy-customer callbacks are scheduled and opt-outs enforced by small scripts; senior expert requests are logged for a human, with no CRM connected.
- Bolna's "Function tools" panel showed "No tools invoked" even for successful bookings, so the Cal.com booking is the source of truth.
- Real campaigns in India need DLT-registered numbers and consent records; this demo only called my own number.

## 6. What I would build next

1. **CRM sync** by webhook: push `extracted_data` (outcome, visit status, opt-out, unknown questions) to the sales team's sheet or CRM.
2. A **verified fact sheet** from the client, driven by the "unknown questions" extraction, which shows exactly what customers ask that we can't answer.
3. **WhatsApp confirmation** of the booking with a location pin, sent after `confirmed`.
4. **Automated regression**: replay the 49 test scenarios in text mode against each new prompt version before any live call.
