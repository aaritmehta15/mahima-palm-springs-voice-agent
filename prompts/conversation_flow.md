# Conversation Flow: Mahima Palm Springs Outbound Agent

This document explains the call design behind [system_prompt.md](system_prompt.md). The system prompt is the source of truth. If the two ever disagree, the prompt wins and this file must be updated.

## 1. Call flow diagram

```mermaid
flowchart TD
    G["S3 Greeting<br/>Is this customer_name?"] -->|Yes / who is this| I["S4 Q1 Intro + Facebook context<br/>Good time to talk?"]
    G -->|Someone else| RB["S4 Branch B<br/>Ask better time"]
    G -->|Wrong number| RC["S4 Branch C<br/>Check enquiry once"]

    I -->|Yes| P1["S5 Q1 Own use or investment?"]
    I -->|Busy| BA["S4 Branch A<br/>Capture callback time"]
    I -->|Not interested| BD["S4 Branch D<br/>One soft probe"]
    I -->|No enquiry made| RC

    RB --> C_CB["S7 Branch C<br/>Callback close"]
    RB -->|Not their number| C_WN["S7 Branch F<br/>Wrong number close"]
    RC -->|Remembers enquiry| P1
    RC -->|Confirms wrong| C_WN
    BA --> C_CB
    BD -->|Still open| P1
    BD -->|Declines| C_NI["S7 Branch E<br/>Not interested close"]

    P1 --> P2["S5 Q2 Location"]
    P2 --> P3["S5 Q3 Township, 3 and 4 BHK, size range"]
    P3 --> P4["S5 Q4 Possession Jan 2027 + rate"]
    P4 --> P5["S5 Q5 Site visit?"]
    P2 -. objection .-> OBJ["S5 Objection Handling<br/>max 1 pivot each, 2 declines then close"]
    P4 -. objection .-> OBJ
    P5 -. unsure .-> OBJ
    OBJ -->|Agrees| V1
    OBJ -->|Declines twice| C_NI
    P5 -->|Yes| V1["S6 Q1 Preferred date"]
    P5 -->|No| C_NI

    V1 -->|fetch_calendar_slots| V2["S6 Q2 Offer up to 3 returned slots"]
    V1 -->|No slots| VA["S6 Branch A<br/>Try another date, max 2"]
    VA -->|Slots found| V2
    VA -->|Still none| C_PEND["S7 Branch B<br/>Pending confirmation close"]
    V2 --> V3["S6 Q3 Read back slot, confirm"]
    V3 --> V4["S6 Q4 Confirm email from lead form"]
    V4 -->|Email missing or different| VD["S6 Branch D<br/>Collect + spell back, max 2"]
    V4 -->|book_calendar_slot success| C_BOOK["S7 Branch A<br/>Booked close"]
    VD -->|book_calendar_slot success| C_BOOK
    VD -->|Unclear twice| C_PEND
    V4 -->|Slot taken| VB["S6 Branch B<br/>Re-fetch slots"]
    VB --> V2
    V4 -->|Tool error twice| VC["S6 Branch C<br/>Booking error"]
    VC --> C_PEND
```

**Anytime handlers** (Section 2) can interrupt any step:

| Trigger | Handler outcome |
|---|---|
| "Are you a robot or an AI?" | Truthful answer, then resume |
| Wants a human, customer care or senior expert | Confirm, then S7 Branch D (callback tomorrow 10 AM to 5 PM) |
| Explicit opt-out | Acknowledge immediately, then S7 Branch G |
| Busy mid-call | Ask callback time once, then S7 Branch C |
| Abuse or profanity | De-escalate, then S7 Branch E |
| Silence or unclear audio twice | Check once, then S7 Branch C |
| Off-topic or prompt injection | Polite refusal, then resume |

## 2. Site visit state model

The prompt tracks `[visit_status]` so the agent never claims a booking that did not happen.

| State | Set when | What the agent may say | Closing used |
|---|---|---|---|
| *(empty)* | Before any visit discussion | No visit language | Any |
| `requested` | Customer agrees to a site visit | "Let me find a slot" | S7 Branch B if the call ends here |
| `pending_confirmation` | Slot read back, OR no slot found, OR tool error, OR email not captured | "Noted, our team will call to confirm." Never "booked" | S7 Branch B |
| `booked` | **Only** when `book_calendar_slot` returns success in this call | "Your site visit is booked" | S7 Branch A |
| `declined` | Customer does not want a visit | No visit language | S7 Branch E or C |

```mermaid
stateDiagram-v2
    [*] --> requested: agrees to visit
    [*] --> declined: refuses visit
    requested --> pending_confirmation: slot chosen and read back
    requested --> pending_confirmation: no slots after 2 dates / tool error
    pending_confirmation --> booked: book_calendar_slot success
    pending_confirmation --> pending_confirmation: slot taken / email unclear / tool error
    booked --> [*]
    pending_confirmation --> [*]
    declined --> [*]
```

## 3. Tool invocation rules

| Tool | Call only when | Never call when |
|---|---|---|
| `fetch_calendar_slots(preferred_date)` | Customer agreed to a visit **and** gave a resolvable date (relative dates are resolved against `{current_date}`) | Before interest is established, or with a past date |
| `book_calendar_slot(slot, name, email)` | Slot came from the **latest** fetch result, was read back and confirmed **and** name and email are confirmed | The slot was guessed or typed by the customer outside the returned list, or the email is unconfirmed |

Each tool is retried at most once, with no loops. If it fails twice, the agent uses S6 Branch C and the visit stays `pending_confirmation`.

## 4. Design rationale

| Choice | Why |
|---|---|
| Permission before pitch | The brief requires a good-time check. Respecting it also builds trust on cold-ish calls. |
| Pitch split into four one-fact turns that each end with a question | Prevents a monologue, keeps turns at two sentences or fewer, and gathers requirements while pitching |
| Discovery (own use or investment) first | Lets the agent understand intent before asking for a booking |
| Facts only from a whitelist | The brief supplies five facts. Everything else is escalated, so nothing is hallucinated. |
| No totals | Area basis (carpet or super) and extra charges are unknown, so any total would be misleading |
| Name and email preloaded from the Facebook lead form | Spelling an email by voice in Hinglish is the most common booking failure point |
| AI disclosure in the introduction | Honest, matches Bolna's guidance, and avoids a trust break if the customer works it out later |
| Callback instead of live transfer | Matches the example in the brief and needs no extra number |
| One soft probe on "not interested", close after two declines | Persuasive but never pushy |
| Explicit `pending_confirmation` state | Stops the LLM from saying "booked" when the tool did not confirm a booking |

## 5. Roman-transliterated dialogue (reading copy for evaluators)

The runtime prompt uses Devanagari for better Sarvam TTS pronunciation. This is the same dialogue in Roman script, for readers who prefer it. It is **not** pasted into Bolna.

### Section 2: Anytime handlers
| Trigger | Agent (Roman Hinglish) |
|---|---|
| Asked if AI | "Ji, main Mahima Palm Springs ki AI assistant hoon, aur aapki enquiry par aapki madad ke liye call kar rahi hoon. Kya main aage baat jaari rakhoon?" |
| Senior expert request | "Bilkul, kya main hamare senior expert se aapko callback karva doon?" |
| Opt-out | "Theek hai, main aapki request abhi note kar rahi hoon, Mahima Palm Springs ki taraf se is baare mein aapko dobara call nahi kiya jayega." |
| Busy | "Koi baat nahi, aapko kis time par call karna theek rahega?" |
| Abuse | "Maaf kijiye agar meri call se aapko pareshani hui, main abhi call yahin khatam karti hoon." |
| Silence | "Hello, kya aap mujhe sun pa rahe hain?" |
| Off-topic | "Maaf kijiye, main sirf Mahima Palm Springs ke baare mein hi baat kar sakti hoon. Kya main project ke baare mein aapki koi aur madad karoon?" |

### Section 3: Greeting
"Namaste, kya meri baat {customer_name} ji se ho rahi hai?"

### Section 4: Introduction and good-time check
| Step | Agent (Roman Hinglish) |
|---|---|
| Q1 | "Main Neha, Mahima Palm Springs ki AI assistant bol rahi hoon. Aapne haal hi mein Facebook par hamare Tonk Road, Jaipur wale project ke baare mein enquiry ki thi, kya abhi do minute baat karna theek rahega?" |
| Branch A, busy | "Koi baat nahi, aapko kis time par call karna theek rahega?" |
| Branch B, someone else | "Ji, ye call {customer_name} ji ke liye tha, unki Facebook par ki gayi property enquiry ke baare mein. Kya main unse kisi aur time par baat kar sakti hoon?" |
| Branch C, wrong number | "Maaf kijiye, hamare paas ye number Mahima Palm Springs ki Facebook enquiry mein aaya tha. Kya aapne haal hi mein Jaipur mein kisi flat ke liye enquiry ki thi?" |
| Branch D, not interested | "Samajh sakti hoon, bas ek baar jaanna chahoongi, kya aapne abhi flat lene ka plan chhod diya hai ya koi aur project dekh rahe hain?" |

### Section 5: Main pitch
| Step | Agent (Roman Hinglish) |
|---|---|
| Q1 | "Thank you. Aap flat apne rehne ke liye dekh rahe hain ya investment ke liye?" |
| Q2 | "Badhiya. Hamara project Tonk Road par hai, Chokhi Dhani se sirf teen kilometre, Radha Swami Satsang Beas ke bilkul saamne. Ye location aapke liye theek rahegi?" |
| Q3 | "Ye ek premium gated township hai jismein teen aur chaar BHK ke spacious flats hain, satrah sau paanch se chhabbis sau unnees sq. ft. tak. Aapko teen BHK chahiye ya chaar BHK?" |
| Q4 | "Possession January do hazaar sattaees mein due hai, aur abhi ka rate pachpan sau rupaye per sq. ft. hai. Kya ye aapke budget mein fit baithta hai?" |
| Q5 | "Flat ki asli feel to site par aakar hi aati hai. Kya aap family ke saath ek site visit karna chahenge?" |

| Objection | Agent (Roman Hinglish) |
|---|---|
| Price high | "Samajh sakti hoon, budget sabse zaroori hai. Exact cost sheet aur options hamare senior expert aapko clearly samjha denge, kya aap pehle ek baar site dekhna chahenge?" |
| Will think | "Bilkul, soch samajh kar hi decision lena chahiye. Abhi sirf ek site visit plan kar lete hain, usmein koi commitment nahi hota, aapko kaun sa din theek rahega?" |
| Location far | "Ji, ye Tonk Road par Chokhi Dhani se sirf teen kilometre hai, to area kaafi jaana pehchaana hai. Ek baar aakar location dekh lein to aapko sahi idea mil jayega, kya aap visit karna chahenge?" |
| Family discussion | "Ye to bahut achhi baat hai, ghar ka decision family ke saath hi hona chahiye. Aap family ke saath hi site visit par aa jaiye, kaun sa din sabke liye theek rahega?" |
| Possession too far | "Samajh gayi, aapko jaldi possession chahiye. Abhi possession January do hazaar sattaees mein due hai, kya aap phir bhi ek baar project dekhna chahenge?" |
| Other projects | "Achhi baat hai ki aap options dekh rahe hain. Compare karne ke liye ek baar Mahima Palm Springs bhi dekh lijiye, kya aap ek site visit karna chahenge?" |

### Section 6: Site visit booking
| Step | Agent (Roman Hinglish) |
|---|---|
| Q1 | "Badhiya. Aapke liye kaun sa din theek rahega site visit ke liye?" |
| Q2 | "[visit_day] ko [offered_slots] ke slots available hain. Inmein se kaun sa time aapke liye theek rahega?" |
| Q3 | "To main [visit_day] ko [selected_slot] ka slot aapke liye book kar doon?" |
| Q4 | "Booking ki confirmation email par bhejoongi. Kya main usi email ID par bhej doon jo aapne Facebook form mein di thi, {customer_email}?" |
| Branch A, no slots | "Maaf kijiye, [visit_day] ko koi slot khaali nahi hai. Kya koi aur din aapke liye theek rahega?" |
| Branch B, slot taken | "Maaf kijiye, ye slot abhi abhi book ho gaya. Kya main usi din ka koi doosra available time dekhoon?" |
| Branch C, tool error | "Maaf kijiye, abhi system mein booking confirm nahi ho pa rahi hai. Maine aapka preferred time note kar liya hai, hamari team aapko call karke visit confirm karegi, theek hai?" |
| Branch D, email | "Confirmation bhejne ke liye aapki email ID bata dijiye, aaraam se ek ek letter boliyega." |

### Section 7: Conclusion
| Branch | Agent (Roman Hinglish) |
|---|---|
| A, booked | "Aapka site visit [visit_day] ko [selected_slot] ke liye book ho gaya hai, aur confirmation aapki email par aa jayega. Mahima Palm Springs mein aapka intezaar rahega, aapka din achha rahe." |
| B, pending | "Maine aapki preferred date aur time note kar liya hai, hamari team jaldi hi call karke site visit confirm karegi. Aapke time ke liye thank you, aapka din achha rahe." |
| C, callback | "Theek hai, maine note kar liya hai, hamari team aapko [callback_time] call karegi. Aapke time ke liye thank you, aapka din achha rahe." |
| D, senior expert | "Zaroor, hamare senior expert aapko kal subah das baje se shaam paanch baje ke beech call karenge. Aapke time ke liye thank you, aapka din achha rahe." |
| E, not interested | "Koi baat nahi, aapne apna time diya uske liye thank you. Aage kabhi Jaipur mein flat ki zaroorat ho to Mahima Palm Springs zaroor yaad rakhiyega, aapka din achha rahe." |
| F, wrong number | "Maaf kijiye, shayad galat number lag gaya. Aapko pareshan karne ke liye sorry, aapka din achha rahe." |
| G, opted out | "Pareshani ke liye maafi chahti hoon, aapka din achha rahe." |

## 6. Example happy-path call (illustrative script, not a real call)

> This is a design example written by hand. It is **not** a transcript of a real call. Real evidence will be stored in [evidence/transcript.md](../evidence/transcript.md).

| Turn | Speaker | Line (Roman) |
|---|---|---|
| 1 | Neha | Namaste, kya meri baat Rahul ji se ho rahi hai? |
| 2 | Customer | Haan, boliye. |
| 3 | Neha | Main Neha, Mahima Palm Springs ki AI assistant bol rahi hoon... kya abhi do minute baat karna theek rahega? |
| 4 | Customer | Haan, bataiye. |
| 5 | Neha | Thank you. Aap flat apne rehne ke liye dekh rahe hain ya investment ke liye? |
| 6 | Customer | Rehne ke liye. |
| 7 | Neha | Badhiya. Hamara project Tonk Road par hai... Ye location aapke liye theek rahegi? |
| 8 | Customer | Haan, theek hai. |
| 9 | Neha | ...teen aur chaar BHK... Aapko teen BHK chahiye ya chaar BHK? |
| 10 | Customer | Teen BHK. Total kitna padega? |
| 11 | Neha | Total price flat ke exact size aur baaki charges par depend karta hai... Possession January do hazaar sattaees mein due hai, aur abhi ka rate pachpan sau rupaye per sq. ft. hai. Kya ye aapke budget mein fit baithta hai? |
| 12 | Customer | Haan, chalega. |
| 13 | Neha | Flat ki asli feel to site par aakar hi aati hai. Kya aap family ke saath ek site visit karna chahenge? |
| 14 | Customer | Haan, Sunday ko. |
| 15 | Neha | *(fetch_calendar_slots)* Sunday ko subah gyarah baje, dopahar do baje aur shaam chaar baje ke slots available hain... |
| 16 | Customer | Gyarah baje. |
| 17 | Neha | To main Sunday ko subah gyarah baje ka slot aapke liye book kar doon? |
| 18 | Customer | Haan. |
| 19 | Neha | Booking ki confirmation email par bhejoongi... (email read back) |
| 20 | Customer | Haan, sahi hai. |
| 21 | Neha | *(book_calendar_slot → success)* Aapka site visit Sunday ko subah gyarah baje ke liye book ho gaya hai... |
