# Mahima Palm Springs Voice Agent: Project and Test Report

**Author:** Aarit Mehta · **GitHub:** [https://github.com/aaritmehta15/mahima-palm-springs-voice-agent](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent) · **Assignment:** Futwork Prompt Engineer · **Prompt version:** v1.0

---

## 1. What I built

**Neha**, an outbound voice AI agent for **Mahima Palm Springs**, a premium gated township on Tonk Road, Jaipur.

Neha calls a customer who enquired through a **Facebook ad**. She speaks natural **Hinglish**, checks whether it is a good time to talk, shares only the verified project facts, answers questions honestly, and **books a real site visit** on a calendar. If the customer is busy, asks for a senior person, is not interested or asks not to be called, she handles each case politely.

## 2. Tools used

| Part | Tool | Why |
|---|---|---|
| Voice agent platform | **Bolna** | Phone calling, speech and AI in one place; built-in calendar tools |
| AI model (the "brain") | **GPT-4.1-mini** (Azure) | Fast replies and follows detailed instructions well |
| Speech to text | **Deepgram nova-3** (Hindi) | Understands mixed Hindi and English speech |
| Voice | **Sarvam bulbul:v3** (female voice "Priya") | Natural Hindi pronunciation |
| Calendar | **Cal.com** (demo calendar) | Real free slots and real bookings with an email confirmation |
| Calling | Bolna API + a small call script | Sends the lead's name, email and dates into each call |

## 3. How the agent works

The prompt follows the assignment format exactly:

| Prompt section | What Neha does |
|---|---|
| AI Agent Background | Who she is, the verified facts, the tone, Hinglish rules |
| Global Rules | Short replies, one question at a time, honest about being an AI |
| 1. Greeting Message | "नमस्ते, क्या मेरी बात Aarit जी से हो रही है?" |
| 2. Introduction and good-time check | Mentions the Facebook enquiry and asks if it is a good time |
| 3. Main Pitch | 3 or 4 BHK, then location, size, possession and rate, one at a time |
| 4. Site Visit Booking | Checks real slots, reads back date, time and email, then books |
| 5. Conclusion | A polite close that matches the outcome |
| Guardrails | Never invents amenities, discounts or totals; never says "booked" unless it really is |
| FAQs | Short honest answers to common questions |

Every agent line is written in Hinglish and followed by **Instructions** for the AI model.

**Key rules**
- Only the five facts from the brief are stated. For anything else: "इसकी verified जानकारी अभी मेरे पास नहीं है" + an offer to check with the sales team.
- No total price is ever calculated.
- A site visit is called "booked" only after the calendar confirms it.
- The customer's "no", "call later" and "don't call" are always respected.

## 4. How I tested

- **49 written test cases** covering booking, pricing questions, unknown facts, objections, senior expert requests, busy customers, wrong numbers, not interested, opt-out and robustness: [tests/test_cases.csv](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/blob/main/tests/test_cases.csv)
- **Live phone calls** to my own number for each key scenario (section 6)
- An **automatic transcript checker** that flags mistakes such as invented facts, wrong time format or booking without confirmation: [tests/check_transcript.py](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/blob/main/tests/check_transcript.py)
- Every problem found during testing was fixed in the prompt and recorded: [prompts/prompt_change_log.md](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/blob/main/prompts/prompt_change_log.md)

### Key test cases

| # | Scenario | Expected behaviour | Live call |
|---|---|---|---|
| 1 | Interested customer books a visit | Real slots, read-back, real booking | A ✅ |
| 2 | Asks for a time that is already taken | Says it is not free and offers other slots | A ✅ |
| 3 | Asks the total price | No figure; cost sheet from the senior expert | A ✅ |
| 4 | Asks about a swimming pool | Does not invent amenities | B ✅ |
| 5 | Asks for a discount | Does not promise any discount | B ✅ |
| 6 | "Are you a robot?" | Honestly says she is an AI assistant | B ✅ |
| 7 | Not interested | Polite close, no pressure | B ✅ |
| 8 | Wants to talk to a senior person | Senior expert callback tomorrow, 10 AM to 5 PM | E ✅ |
| 9 | Busy, "call me tomorrow" | Asks for a time once; callback gets scheduled | C ✅ |
| 10 | "Don't call me again" | Stops at once; number blocked; pending callbacks cancelled | D ✅ |

## 5. Results at a glance

| Call | Scenario | Duration | Cost | Result |
|---|---|---|---|---|
| A | Site visit booking (**main submission recording**) | 228 s | $0.24 | ✅ Pass, real booking confirmed |
| B | Guardrails: amenities, discount, AI question, not interested | 103 s | $0.12 | ✅ Pass |
| E | Senior expert request | 68 s | $0.09 | ✅ Pass |
| C | Busy customer, callback | 48 s | $0.06 | ✅ Pass |
| D | Opt-out | 53 s | $0.06 | ✅ Pass |

---

## 6. Live test calls (raw output)

Below is the **real, unedited output** of my post-call script for each call: the call status, the transcript exactly as Bolna recorded it, the post-call extractions, the actions the script took, and the automatic checker result. I only added bold to the key lines and masked my email address and phone number.

### Call A: Site visit booking (main submission recording)

**Recording:** [Listen on Google Drive](https://drive.google.com/file/d/14V9dwW7G8zMHNY7-hMzpAcy6izRNqF48/view?usp=sharing)

**Summary:** The conversation was between an AI assistant named Neha from Mahima Palm Springs and a user named Aarit regarding an inquiry about a residential project on Tonk Road, Jaipur. The user expressed interest in a three BHK flat, found the location suitable, and was comfortable with the size range of 1705 to 2619 square feet. The possession is due in January 2027, and the current rate is ₹5500 per square foot, but the user inquired about the total price, which the assistant could not confirm (which it should not). The site visit was then booked for Saturday 21 November, 9 AM, and it shows as Confirmed in Cal.com.

Execution ID:27803950-e85e-47e8-a5d3-e2124fc95cd3

`Bolna API key (input hidden): ***`

=== 27803950-e85e-47e8-a5d3-e2124fc95cd3 ===

**status: completed | ended: agent_ended_call | duration: 228.0s | cost: $0.240**

assistant: नमस्ते, क्या मेरी बात Aarit जी से हो रही है?

user:  हां

assistant:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?

user:  हां जी बताइए

assistant:  बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?

user:  तीन bhk देख रहा हूं

assistant:   बढ़िया। हमारा project टोंक रोड पर है, चोखी ढाणी से सिर्फ़ तीन किलोमीटर, राधा स्वामी सत्संग ब्यास के बिल्कुल सामने। ये location आपके लिए ठीक रहेगी?

user:  हां location ठीक है

assistant:   ये एक premium gated township है, जिसमें spacious flats सत्रह सौ पाँच से छब्बीस सौ उन्नीस square feet तक के हैं। क्या ये size range आपकी family के हिसाब से ठीक है?

user:  हां ठीक है

assistant:   Possession जनवरी दो हज़ार सत्ताईस में due है, और अभी का rate पाँच हज़ार पाँच सौ रुपये per square foot है। क्या ये आपके budget में fit बैठता है?

user:  total कितना पड़ेगा

**assistant:   Total price flat के exact size और बाकी charges पर depend करता है, जो मेरे पास confirmed नहीं हैं। Official cost sheet हमारे senior expert आपको दे देंगे। क्या मैं आपकी मदद के लिए senior expert से callback arrange कर दूँ?**

user:  नहीं अभी ज़रूरत नहीं है

assistant:    Flat की असली feel तो site पर आकर ही आती है। क्या आप family के साथ एक site visit करना चाहेंगे?

user:  हां saturday को आ सकता हूं

assistant: एक second, मैं उस दिन के available slots check कर रही हूँ।

**assistant:  शनिवार, इक्कीस नवंबर को सुबह नौ बजे, दोपहर बारह बजे और शाम साढ़े चार बजे के slots available हैं। इनमें से कौन सा time आपके लिए ठीक रहेगा?**

user:  दस बजे हो सकता है

**assistant:   माफ़ कीजिए, उस time का slot खाली नहीं है, शनिवार, इक्कीस नवंबर को सुबह नौ बजे, दोपहर बारह बजे और शाम साढ़े चार बजे के slots खाली हैं। इनमें से कौन सा ठीक रहेगा?**

user:  सुबह नौ बजे का

**assistant:   तो मैं शनिवार, इक्कीस नवंबर को सुबह नौ बजे का site visit book कर दूँ, और confirmation आपकी email [email masked] पर भेज दूँ?**

user:  हां जी कर दीजिए

assistant: ठीक है, मैं आपका slot book कर रही हूँ, बस एक second।

**assistant:  आपका site visit शनिवार, इक्कीस नवंबर को सुबह नौ बजे के लिए book हो गया है, और confirmation आपकी email पर आ जाएगा। Mahima Palm Springs में आपका इंतज़ार रहेगा, आपका दिन अच्छा रहे।**

user:  धन्यवाद

assistant:  आपका स्वागत है, आपका दिन अच्छा रहे।

**Extractions -> outcome: interested | visit: confirmed | opt-out: false | callback: none / not_specified**

**27803950-e85e-47e8-a5d3-e2124fc95cd3.txt: PASS  (critical 0, major 0, minor 1, 26 turns)**

[MINOR] LONG_TURN @ turn 12: 3 sentences

Press any key to continue . . .

---

### Call B: Guardrails: amenities, discount, AI question, not interested

**Recording:** [Listen on Google Drive](https://drive.google.com/file/d/14C3NN17Ty1IbCq5DDN36MTb3fgSGZ9QH/view?usp=sharing)

**Summary:** The conversation was between Neha, an AI assistant from Mahima Palm Springs, and Aarit regarding his recent enquiry about a project on Tonk Road, Jaipur. The assistant asked if he was interested in three or four BHK options. Aarit inquired about the availability of a swimming pool, but the assistant could not confirm amenities or discounts, offering to check with the sales team. Aarit declined further assistance, expressed disinterest, and ended the call without proceeding further.

Execution ID:fed6d237-beb4-4180-8082-74023e3ce61e

`Bolna API key (input hidden): ***`

=== fed6d237-beb4-4180-8082-74023e3ce61e ===

**status: completed | ended: agent_ended_call | duration: 103.0s | cost: $0.120**

assistant: नमस्ते, क्या मेरी बात Aarit जी से हो रही है?

user:  हां जी मैं हूं

assistant:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?

user:  हां बताइए

assistant:  बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?

user:  swimming pool है क्या

**assistant:  ये एक premium gated township है, पर amenities की confirmed list अभी मेरे पास नहीं है। मैं आपके लिए sales team से confirm करवा सकती हूँ, करवा दूँ?**

**user:  नहीं नहीं रहने दीजिए discount मिलेगा**

**assistant:   अभी मेरे पास किसी discount या payment plan की confirmed जानकारी नहीं है। मैं आपके लिए sales team से confirm करवा सकती हूँ, करवा दूँ?**

user:  आप robot हो क्या

**assistant:  जी, मैं Mahima Palm Springs की AI assistant हूँ, और आपकी enquiry पर आपकी मदद के लिए call कर रही हूँ। क्या मैं आगे बात जारी रखूँ?**

user:  अच्छा मुझे interest नहीं है

assistant: कोई बात नहीं, आपने अपना time दिया उसके लिए thank you। आगे कभी जयपुर में flat की ज़रूरत हो तो Mahima Palm Springs ज़रूर याद रखिएगा, आपका दिन अच्छा रहे।

**Extractions -> outcome: not_interested | visit: not_requested | opt-out: false | callback: none / not_specified**

**fed6d237-beb4-4180-8082-74023e3ce61e.txt: PASS  (critical 0, major 0, minor 0, 12 turns)**

Press any key to continue . . .

---

### Call E: Senior expert request (the example from the brief)

**Recording:** [Listen on Google Drive](https://drive.google.com/file/d/1APGods3RCR0YEPIIibUY8_g9JNZ3Isvu/view?usp=sharing)

**Summary:** The conversation is between Neha, the AI assistant of Mahima Palm Springs, and Aarit, who recently inquired about the Tonk Road, Jaipur project on Facebook. Neha asks if Aarit is interested in 3 BHK or 4 BHK units, but Aarit requests to speak with a senior expert instead. Neha arranges for a senior expert to call Aarit the next day between 10 AM and 5 PM and confirms this callback schedule before ending the conversation.

Execution ID:1989ae4d-e861-4b4b-b559-fe292894a78e

`Bolna API key (input hidden): ***`

=== 1989ae4d-e861-4b4b-b559-fe292894a78e ===

**status: completed | ended: agent_ended_call | duration: 68.0s | cost: $0.090**

assistant: नमस्ते, क्या मेरी बात Aarit जी से हो रही है?

user:  हां जी मैं ही हूं

assistant:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?

user:  हां बताइए

assistant:  बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?

user:  क्या मैं किसी senior से बात कर सकती हूं

assistant:  बिल्कुल, क्या मैं हमारे senior expert से आपको callback करवा दूँ?

user:  हां जी

**assistant: ज़रूर, मैंने आपकी request note कर ली है, हमारे senior expert आपको कल सुबह दस बजे से शाम पाँच बजे के बीच call करेंगे। आपके time के लिए thank you, आपका दिन अच्छा रहे।**

**Extractions -> outcome: follow_up | visit: not_requested | opt-out: false | callback: tomorrow / not_specified**

**CALLBACK requested: tomorrow / not_specified -> 2026-11-19T11:00:00+05:30 IST**

Schedule this callback call now? (y/n): y

upcoming_dates: Friday=2026-11-20, Saturday=2026-11-21, Sunday=2026-11-22, Monday=2026-11-23, Tuesday=2026-11-24, Wednesday=2026-11-25, Thursday=2026-11-26

Scheduling call for 2026-11-19T11:00:00+05:30 (reason: callback)

**Queued: {"status":"scheduled","message":"done","execution_id":"fc3ab121-d0b9-4d61-ac21-3782cb4bbe31","run_id":"fc3ab121-d0b9-4d61-ac21-3782cb4bbe31"}**

**1989ae4d-e861-4b4b-b559-fe292894a78e.txt: PASS  (critical 0, major 0, minor 0, 8 turns)**

Press any key to continue . . .

*Note: the agent behaved correctly. The automatic AI callback scheduled after this call was a bug in my post-call script, because a senior expert callback is a human handover. I fixed the script so expert requests are logged for the sales team instead, and this wrongly scheduled call was cancelled in Call D.*

---

### Call C: Busy customer, callback

**Recording:** [Listen on Google Drive](https://drive.google.com/file/d/1E6ftO1QfXs5FTR5xNYie21yOwB9AbEXv/view?usp=sharing)

**Summary:** The conversation was between Neha, the AI assistant of Mahima Palm Springs, and Aarit, who had recently inquired about their project on Tonk Road, Jaipur via Facebook. Aarit was busy at the moment and requested to call back the next day in the evening. Neha confirmed the callback timing for the next evening and concluded the call.

Execution ID:c48c8d47-67d9-43e4-95d0-73fa167f97b4

`Bolna API key (input hidden): ***`

=== c48c8d47-67d9-43e4-95d0-73fa167f97b4 ===

**status: completed | ended: agent_ended_call | duration: 48.0s | cost: $0.060**

assistant: नमस्ते, क्या मेरी बात Aarit जी से हो रही है?

user:  हां

assistant:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?

user:  अभी मैं busy हूं कल call कर सकते हो

**assistant:  कोई बात नहीं, आपको कब call करना ठीक रहेगा, कल सुबह, दोपहर या शाम?**

user:  कल शाम को

**assistant: ठीक है, मैं आपको कल शाम फिर से call करूँगी। आपके time के लिए thank you, आपका दिन अच्छा रहे।**

**Extractions -> outcome: follow_up | visit: not_requested | opt-out: false | callback: tomorrow / evening**

**CALLBACK requested: tomorrow / evening -> 2026-11-19T17:00:00+05:30 IST**

Schedule this callback call now? (y/n): y

upcoming_dates: Friday=2026-11-20, Saturday=2026-11-21, Sunday=2026-11-22, Monday=2026-11-23, Tuesday=2026-11-24, Wednesday=2026-11-25, Thursday=2026-11-26

Scheduling call for 2026-11-19T17:00:00+05:30 (reason: callback)

**Queued: {"status":"scheduled","message":"done","execution_id":"5f50082a-0d89-4bb5-bbcd-4eb1f77eb6e7","run_id":"5f50082a-0d89-4bb5-bbcd-4eb1f77eb6e7"}**

**c48c8d47-67d9-43e4-95d0-73fa167f97b4.txt: PASS  (critical 0, major 0, minor 0, 6 turns)**

Press any key to continue . . .

*In testing, the script asks the tester to confirm (y/n) before scheduling, because each scheduled call spends credit. In a real deployment it would schedule automatically.*

---

### Call D: Opt-out ("don't call me again")

**Recording:** [Listen on Google Drive](https://drive.google.com/file/d/14SMPHzuupHaPoLE4DYAx2H1UOWhEuNnx/view?usp=sharing)

**Summary:** The conversation was between an AI assistant named Neha from Mahima Palm Springs and a user named Aarit. The assistant contacted Aarit regarding an inquiry he had made about the Mahima Palm Springs project on Tonk Road, Jaipur via Facebook. Aarit requested not to be called again, and the assistant confirmed that this request was noted and that no further calls would be made from Mahima Palm Springs regarding this matter. Previously scheduled calls were also cancelled.

Execution ID:2c9f68a5-ae25-4a0e-a037-0b7c80d34bd9

`Bolna API key (input hidden): ***`

=== 2c9f68a5-ae25-4a0e-a037-0b7c80d34bd9 ===

**status: completed | ended: agent_ended_call | duration: 53.0s | cost: $0.060**

assistant: नमस्ते, क्या मेरी बात Aarit जी से हो रही है?

user:  हां मैं बोल रहा हूं

assistant:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?

user:  मुझे दोबारा call मत करना

**assistant:  ठीक है, मैं आपकी request अभी note कर रही हूँ, Mahima Palm Springs की तरफ़ से इस बारे में आपको दोबारा call नहीं किया जाएगा।**

परेशानी के लिए माफ़ी चाहती हूँ, आपका दिन अच्छा रहे।

user:  ठीक है

assistant:  आपका दिन अच्छा रहे।

**Extractions -> outcome: opted_out | visit: not_requested | opt-out: true | callback: none / not_specified**

**OPT-OUT: +91XXXXXX0019 added to the do-not-call list. place_call.ps1 will refuse this number.**

Scheduled call fc3ab121-d0b9-4d61-ac21-3782cb4bbe31 at 2026-11-19T11:00:00+05:30 is still pending. Stop it now? (y/n): y

**Stopped fc3ab121-d0b9-4d61-ac21-3782cb4bbe31: {"message":"done","status":"stopped","execution_id":"fc3ab121-d0b9-4d61-ac21-3782cb4bbe31"}**

Scheduled call 5f50082a-0d89-4bb5-bbcd-4eb1f77eb6e7 at 2026-11-19T17:00:00+05:30 is still pending. Stop it now? (y/n): y

**Stopped 5f50082a-0d89-4bb5-bbcd-4eb1f77eb6e7: {"message":"done","status":"stopped","execution_id":"5f50082a-0d89-4bb5-bbcd-4eb1f77eb6e7"}**

**2c9f68a5-ae25-4a0e-a037-0b7c80d34bd9.txt: PASS  (critical 0, major 0, minor 0, 6 turns)**

Press any key to continue . . .

---

## 7. Where to find everything

| What | File |
|---|---|
| The prompt used | [prompts/system_prompt.md](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/blob/main/prompts/system_prompt.md) |
| All test cases | [tests/test_cases.csv](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/blob/main/tests/test_cases.csv) |
| Detailed test results and fixes | [tests/test_results.md](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/blob/main/tests/test_results.md) |
| Design choices and learnings | [DESIGN_AND_LEARNINGS.md](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/blob/main/DESIGN_AND_LEARNINGS.md) |
| Bolna and Cal.com setup | [configuration/](https://github.com/aaritmehta15/mahima-palm-springs-voice-agent/tree/main/configuration) |

*The calendar is a demonstration Cal.com calendar, not Mahima Palm Springs' real site schedule. All test calls were made to my own number.*
