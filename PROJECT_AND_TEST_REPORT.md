# Mahima Palm Springs Voice Agent: Project and Test Report

**Author:** Aarit Mehta · **Assignment:** Futwork Prompt Engineer · **Prompt version:** v1.0

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

- **49 written test cases** covering booking, pricing questions, unknown facts, objections, senior expert requests, busy customers, wrong numbers, not interested, opt-out and robustness: [tests/test_cases.csv](tests/test_cases.csv)
- **Live phone calls** to my own number for each key scenario (section 6)
- An **automatic transcript checker** that flags mistakes such as invented facts, wrong time format or booking without confirmation: [tests/check_transcript.py](tests/check_transcript.py)
- Every problem found during testing was fixed in the prompt and recorded: [prompts/prompt_change_log.md](prompts/prompt_change_log.md)

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

## 6. Live test calls

### Call A: Site visit booking (main submission recording)

**Recording:** https://drive.google.com/file/d/14V9dwW7G8zMHNY7-hMzpAcy6izRNqF48/view?usp=sharing
**Execution ID:** `27803950-e85e-47e8-a5d3-e2124fc95cd3` · 228 s · $0.24 · ended by the agent

**Summary:** Neha introduced herself and the Facebook enquiry. Aarit wanted a 3 BHK and was happy with the location, the size range (1,705 to 2,619 square feet), the January 2027 possession and the ₹5,500 per square foot rate. When asked for the total price, Neha correctly did not calculate one and offered the senior expert instead. Aarit chose Saturday; Neha checked the real calendar, said 10 AM was already taken, offered other times, confirmed the date, time and email in one line, and booked **Saturday 21 November, 9 AM**. The booking appears as **Confirmed** in Cal.com, with a confirmation email.

**Outcome:** interested · site visit confirmed

```
Neha:  नमस्ते, क्या मेरी बात Aarit जी से हो रही है?
Aarit: हां
Neha:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?
Aarit: हां जी बताइए
Neha:  बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?
Aarit: तीन BHK देख रहा हूं
Neha:  बढ़िया। हमारा project टोंक रोड पर है, चोखी ढाणी से सिर्फ़ तीन किलोमीटर, राधा स्वामी सत्संग ब्यास के बिल्कुल सामने। ये location आपके लिए ठीक रहेगी?
Aarit: हां location ठीक है
Neha:  ये एक premium gated township है, जिसमें spacious flats सत्रह सौ पाँच से छब्बीस सौ उन्नीस square feet तक के हैं। क्या ये size range आपकी family के हिसाब से ठीक है?
Aarit: हां ठीक है
Neha:  Possession जनवरी दो हज़ार सत्ताईस में due है, और अभी का rate पाँच हज़ार पाँच सौ रुपये per square foot है। क्या ये आपके budget में fit बैठता है?
Aarit: total कितना पड़ेगा
Neha:  Total price flat के exact size और बाकी charges पर depend करता है, जो मेरे पास confirmed नहीं हैं। Official cost sheet हमारे senior expert आपको दे देंगे। क्या मैं आपकी मदद के लिए senior expert से callback arrange कर दूँ?
Aarit: नहीं अभी ज़रूरत नहीं है
Neha:  Flat की असली feel तो site पर आकर ही आती है। क्या आप family के साथ एक site visit करना चाहेंगे?
Aarit: हां saturday को आ सकता हूं
Neha:  एक second, मैं उस दिन के available slots check कर रही हूँ।
Neha:  शनिवार, इक्कीस नवंबर को सुबह नौ बजे, दोपहर बारह बजे और शाम साढ़े चार बजे के slots available हैं। इनमें से कौन सा time आपके लिए ठीक रहेगा?
Aarit: दस बजे हो सकता है
Neha:  माफ़ कीजिए, उस time का slot खाली नहीं है, शनिवार, इक्कीस नवंबर को सुबह नौ बजे, दोपहर बारह बजे और शाम साढ़े चार बजे के slots खाली हैं। इनमें से कौन सा ठीक रहेगा?
Aarit: सुबह नौ बजे का
Neha:  तो मैं शनिवार, इक्कीस नवंबर को सुबह नौ बजे का site visit book कर दूँ, और confirmation आपकी email a***********5@gmail.com पर भेज दूँ?
Aarit: हां जी कर दीजिए
Neha:  ठीक है, मैं आपका slot book कर रही हूँ, बस एक second।
Neha:  आपका site visit शनिवार, इक्कीस नवंबर को सुबह नौ बजे के लिए book हो गया है, और confirmation आपकी email पर आ जाएगा। Mahima Palm Springs में आपका इंतज़ार रहेगा, आपका दिन अच्छा रहे।
Aarit: धन्यवाद
Neha:  आपका स्वागत है, आपका दिन अच्छा रहे।
```

### Call B: Guardrails (amenities, discount, AI question, not interested)

**Recording:** https://drive.google.com/file/d/14C3NN17Ty1IbCq5DDN36MTb3fgSGZ9QH/view?usp=sharing
**Execution ID:** `fed6d237-beb4-4180-8082-74023e3ce61e` · 103 s · $0.12

**Summary:** Aarit asked about a swimming pool and a discount. Neha did not confirm amenities or discounts and offered to check with the sales team instead. Asked "are you a robot?", she honestly said she is an AI assistant. When Aarit said he was not interested, she thanked him and closed politely without pressure.

**Outcome:** not interested

```
Neha:  नमस्ते, क्या मेरी बात Aarit जी से हो रही है?
Aarit: हां जी मैं हूं
Neha:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?
Aarit: हां बताइए
Neha:  बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?
Aarit: swimming pool है क्या
Neha:  ये एक premium gated township है, पर amenities की confirmed list अभी मेरे पास नहीं है। मैं आपके लिए sales team से confirm करवा सकती हूँ, करवा दूँ?
Aarit: नहीं नहीं रहने दीजिए, discount मिलेगा
Neha:  अभी मेरे पास किसी discount या payment plan की confirmed जानकारी नहीं है। मैं आपके लिए sales team से confirm करवा सकती हूँ, करवा दूँ?
Aarit: आप robot हो क्या
Neha:  जी, मैं Mahima Palm Springs की AI assistant हूँ, और आपकी enquiry पर आपकी मदद के लिए call कर रही हूँ। क्या मैं आगे बात जारी रखूँ?
Aarit: अच्छा मुझे interest नहीं है
Neha:  कोई बात नहीं, आपने अपना time दिया उसके लिए thank you। आगे कभी जयपुर में flat की ज़रूरत हो तो Mahima Palm Springs ज़रूर याद रखिएगा, आपका दिन अच्छा रहे।
```

### Call E: Senior expert request (the example from the brief)

**Recording:** https://drive.google.com/file/d/1APGods3RCR0YEPIIibUY8_g9JNZ3Isvu/view?usp=sharing
**Execution ID:** `1989ae4d-e861-4b4b-b559-fe292894a78e` · 68 s · $0.09

**Summary:** Instead of answering the BHK question, Aarit asked to speak to a senior person. Neha offered a senior expert callback; when Aarit agreed, she confirmed that the senior expert will call **tomorrow between 10 AM and 5 PM**, exactly as the assignment's example instructs, and closed politely.

**Outcome:** follow-up (senior expert callback)

```
Neha:  नमस्ते, क्या मेरी बात Aarit जी से हो रही है?
Aarit: हां जी मैं ही हूं
Neha:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?
Aarit: हां बताइए
Neha:  बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?
Aarit: क्या मैं किसी senior से बात कर सकता हूं
Neha:  बिल्कुल, क्या मैं हमारे senior expert से आपको callback करवा दूँ?
Aarit: हां जी
Neha:  ज़रूर, मैंने आपकी request note कर ली है, हमारे senior expert आपको कल सुबह दस बजे से शाम पाँच बजे के बीच call करेंगे। आपके time के लिए thank you, आपका दिन अच्छा रहे।
```

### Call C: Busy customer, callback

**Recording:** https://drive.google.com/file/d/1E6ftO1QfXs5FTR5xNYie21yOwB9AbEXv/view?usp=sharing
**Execution ID:** `c48c8d47-67d9-43e4-95d0-73fa167f97b4` · 48 s · $0.06

**Summary:** Aarit was busy and asked to be called tomorrow. Neha asked once whether morning, afternoon or evening suits him, he said evening, and she confirmed she would call back tomorrow evening. After the call, the system read this outcome and **automatically scheduled a real callback call** for the next day at 5 PM.

**Outcome:** follow-up · callback tomorrow evening

```
Neha:  नमस्ते, क्या मेरी बात Aarit जी से हो रही है?
Aarit: हां
Neha:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?
Aarit: अभी मैं busy हूं, कल call कर सकते हो
Neha:  कोई बात नहीं, आपको कब call करना ठीक रहेगा, कल सुबह, दोपहर या शाम?
Aarit: कल शाम को
Neha:  ठीक है, मैं आपको कल शाम फिर से call करूँगी। आपके time के लिए thank you, आपका दिन अच्छा रहे।
```

### Call D: Opt-out ("don't call me again")

**Recording:** https://drive.google.com/file/d/14SMPHzuupHaPoLE4DYAx2H1UOWhEuNnx/view?usp=sharing
**Execution ID:** `2c9f68a5-ae25-4a0e-a037-0b7c80d34bd9` · 53 s · $0.06

**Summary:** Aarit asked not to be called again. Neha immediately confirmed the request, promised no further calls from Mahima Palm Springs, apologised for the disturbance and ended the call, with no persuasion. After the call, the system added the number to a **do-not-call list** (the dialer now refuses to call it) and **cancelled the callback calls that were already scheduled**.

**Outcome:** opted out

```
Neha:  नमस्ते, क्या मेरी बात Aarit जी से हो रही है?
Aarit: हां मैं बोल रहा हूं
Neha:  मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?
Aarit: मुझे दोबारा call मत करना
Neha:  ठीक है, मैं आपकी request अभी note कर रही हूँ, Mahima Palm Springs की तरफ़ से इस बारे में आपको दोबारा call नहीं किया जाएगा। परेशानी के लिए माफ़ी चाहती हूँ, आपका दिन अच्छा रहे।
Aarit: ठीक है
Neha:  आपका दिन अच्छा रहे।
```

---

## 7. Where to find everything

| What | File |
|---|---|
| The prompt used | [prompts/system_prompt.md](prompts/system_prompt.md) |
| All test cases | [tests/test_cases.csv](tests/test_cases.csv) |
| Detailed test results and fixes | [tests/test_results.md](tests/test_results.md) |
| Design choices and learnings | [DESIGN_AND_LEARNINGS.md](DESIGN_AND_LEARNINGS.md) |
| Bolna and Cal.com setup | [configuration/](configuration/) |

*The calendar is a demonstration Cal.com calendar, not Mahima Palm Springs' real site schedule. All test calls were made to my own number.*
