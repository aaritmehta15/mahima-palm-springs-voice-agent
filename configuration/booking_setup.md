# Site Visit Booking Setup (Cal.com + Bolna)

The agent checks **real** availability and creates **real** bookings using Bolna's built-in Cal.com tools. Bolna makes the Cal.com HTTP calls itself, so no server or code is needed. Reference: [.agents/skills/setup-tools/references/cal-com.md](../.agents/skills/setup-tools/references/cal-com.md).

> **This is a demonstration calendar.** It is a Cal.com account controlled by the developer. Its availability is **not** the real Mahima Palm Springs site office schedule, and the agent's prompt is forbidden from claiming that it is.

## 1. Cal.com account and event type

1. Create a free Cal.com account. A personal test account is fine.
2. Create an event type:

| Field | Value |
|---|---|
| Title | `Mahima Palm Springs – Assessment Demo Site Visit` |
| Host | Your own account |
| Duration | `30` minutes (demo assumption) |
| Location | `In person: Mahima Palm Springs, Tonk Road, Jaipur` |
| Description | `Illustrative calendar for an assessment demo; not an official property-company schedule.` |
| Timezone | `Asia/Kolkata` |
| Availability | Demo schedule, e.g. Mon–Sun, 10:00–18:00 IST |
| Minimum notice | `2` hours, so the agent cannot book a slot that has already passed |
| Booking questions | Name and email only (Cal.com defaults). Add no required custom fields, or the booking tool will fail |

3. **Connect Google Calendar** (or another supported calendar) under Cal.com → Settings → Calendars, so Cal.com checks real conflicts. Then a busy block you add in Google Calendar disappears from the slots the agent offers, which is a simple live test of T11.
4. To test the "no slots" branch (TC-24), block out one full day in the availability, e.g. every Monday.

## 2. Cal.com API key

Cal.com → Settings → Developer → **API Keys** → create a key named `bolna-demo`.

- Paste the key **only** into the Bolna Tools tab.
- **Never** put it in this repository, a `.env` file that might get committed, screenshots or the Loom. Blur it if it is on screen.
- Revoke the key after the assessment.

## 3. Add the tools in Bolna

Agent → **Tools** tab → **Select functions**:

### Tool 1: Check slot availability (using Cal.com)

| Field | Value |
|---|---|
| Function name | `check_availability_of_slots` |
| Cal.com API key | (paste) |
| Event type | `Mahima Palm Springs – Assessment Demo Site Visit` |
| Timezone | `Asia/Kolkata` (must match the event) |
| Description | `Fetch available site visit slots from the calendar. Call this only after the customer has agreed to a site visit and given a preferred date. Pass preferred_date in YYYY-MM-DD format, resolving words like kal or Sunday from current_date.` |
| Pre-call message (Hindi) | `एक second, मैं उस दिन के available slots check कर रही हूँ।` |
| Pre-call message (English) | `One moment, let me check the available slots for that day.` |

### Tool 2: Book appointment (using Cal.com)

| Field | Value |
|---|---|
| Function name | `book_appointment` |
| Cal.com API key | (paste) |
| Event type | `Mahima Palm Springs – Assessment Demo Site Visit` |
| Timezone | `Asia/Kolkata` |
| Description | `Book a site visit slot only after the customer chose a slot returned by check_availability_of_slots, the slot was read back and confirmed, and the customer's name and email are confirmed. Never book a time that was not returned by check_availability_of_slots.` |
| Pre-call message (Hindi) | `ठीक है, मैं आपका slot book कर रही हूँ, बस एक second।` |
| Pre-call message (English) | `Booking that for you now, one moment.` |

Use the **+ Add** button in the Cal.com tool config to add the Hindi pre-call message. If only one message is allowed, use the Hindi one.

## 4. How the prompt uses the tools

| Step | Prompt location | Tool |
|---|---|---|
| Customer agrees to a visit → ask date | Section 6, Q1 | — |
| Date captured | Section 6, Q1 | `check_availability_of_slots(preferred_date)` |
| Offer up to three returned slots | Section 6, Q2 | — |
| Read back and confirm | Section 6, Q3 | — |
| Confirm the preloaded email, or collect one (Branch D) | Section 6, Q4 / Branch D | — |
| Book | Section 6, Q4 | `book_appointment(slot, name, email)` |
| Success → "booked" | Section 7, Branch A | — |
| Failure → "noted, team will confirm" | Section 6, Branch B or C → Section 7, Branch B | — |

## 5. Verification checklist (after setup, before demo)

| Check | How | Expected |
|---|---|---|
| Tools load | Bolna Tools tab shows both functions with the event type selected | Both listed |
| Timezone match | Ask for "kal subah" in a web test | Slots are spoken in IST and match Cal.com |
| Real booking | TC-01 web test | Booking appears in Cal.com → Upcoming, with the test email |
| No-slot branch | TC-24, ask for the blocked day | The agent offers another date |
| Error branch | TC-27: temporarily disable the event type or use a revoked key on a **copy** of the agent | The agent says "noted, team will confirm" and never "booked" |
| Clean-up | Cancel the test bookings in Cal.com | Calendar clean before the demo |

## 6. Known failure modes

| Symptom | Likely cause | Fix |
|---|---|---|
| Spoken times are off by hours | Timezone mismatch | Set `Asia/Kolkata` in both Cal.com and Bolna |
| `check_availability_of_slots` returns nothing | Event paused or no availability window | Check the event in Cal.com |
| Cal.com shows the booking but the agent said it failed | Tool timed out | Check raw logs; lengthen the pre-call message. The prompt already falls back to "pending" safely |
| Booking fails with a missing field | Required custom booking question | Remove the extra required questions from the event |
| Wrong email booked | Email misheard | The prompt reads it back letter by letter (Branch D); use the preloaded email where possible |
