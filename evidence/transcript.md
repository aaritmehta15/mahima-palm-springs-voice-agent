# Call Transcript: Submission Recording (prompt v1.0)

The real Bolna transcript of the submission call, copied from the execution. The only change is the redaction listed at the end. The call was made with **the same prompt that is submitted**: [prompts/system_prompt.md](../prompts/system_prompt.md) v1.0.

| Field | Value |
|---|---|
| Execution ID (first 8 characters) | `27803950` |
| Prompt version | **v1.0** |
| Date | 18 Nov 2026 |
| How the call was placed | `POST /call` with `user_data` (customer_name, customer_email, upcoming_dates, timezone) via [scripts/place_call.ps1](../scripts/place_call.ps1) |
| Duration and cost | 228 s, $0.24 |
| Ended by | Agent (`agent_ended_call`) |
| Outcome | **Site visit confirmed**: a real Cal.com booking, Sat 21 Nov 2026, 9:00 to 9:30 IST |
| Post-call extraction | Call Outcome `interested` · Site Visit Status `confirmed` · Opt-out `false` |
| Automatic check | [`check_transcript.py`](../tests/check_transcript.py): **PASS**, 0 critical, 0 major |
| Recording | See [recording_url.md](recording_url.md) |

## Transcript

```
assistant: नमस्ते, क्या मेरी बात Aarit जी से हो रही है?
user: हां
assistant: मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?
user: हां जी बताइए
assistant: बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?
user: तीन bhk देख रहा हूं
assistant: बढ़िया। हमारा project टोंक रोड पर है, चोखी ढाणी से सिर्फ़ तीन किलोमीटर, राधा स्वामी सत्संग ब्यास के बिल्कुल सामने। ये location आपके लिए ठीक रहेगी?
user: हां location ठीक है
assistant: ये एक premium gated township है, जिसमें spacious flats सत्रह सौ पाँच से छब्बीस सौ उन्नीस square feet तक के हैं। क्या ये size range आपकी family के हिसाब से ठीक है?
user: हां ठीक है
assistant: Possession जनवरी दो हज़ार सत्ताईस में due है, और अभी का rate पाँच हज़ार पाँच सौ रुपये per square foot है। क्या ये आपके budget में fit बैठता है?
user: total कितना पड़ेगा
assistant: Total price flat के exact size और बाकी charges पर depend करता है, जो मेरे पास confirmed नहीं हैं। Official cost sheet हमारे senior expert आपको दे देंगे। क्या मैं आपकी मदद के लिए senior expert से callback arrange कर दूँ?
user: नहीं अभी ज़रूरत नहीं है
assistant: Flat की असली feel तो site पर आकर ही आती है। क्या आप family के साथ एक site visit करना चाहेंगे?
user: हां saturday को आ सकता हूं
assistant: एक second, मैं उस दिन के available slots check कर रही हूँ।
assistant: शनिवार, इक्कीस नवंबर को सुबह नौ बजे, दोपहर बारह बजे और शाम साढ़े चार बजे के slots available हैं। इनमें से कौन सा time आपके लिए ठीक रहेगा?
user: दस बजे हो सकता है
assistant: माफ़ कीजिए, उस time का slot खाली नहीं है, शनिवार, इक्कीस नवंबर को सुबह नौ बजे, दोपहर बारह बजे और शाम साढ़े चार बजे के slots खाली हैं। इनमें से कौन सा ठीक रहेगा?
user: सुबह नौ बजे का
assistant: तो मैं शनिवार, इक्कीस नवंबर को सुबह नौ बजे का site visit book कर दूँ, और confirmation आपकी email a***********5@gmail.com पर भेज दूँ?
user: हां जी कर दीजिए
assistant: ठीक है, मैं आपका slot book कर रही हूँ, बस एक second।
assistant: आपका site visit शनिवार, इक्कीस नवंबर को सुबह नौ बजे के लिए book हो गया है, और confirmation आपकी email पर आ जाएगा। Mahima Palm Springs में आपका इंतज़ार रहेगा, आपका दिन अच्छा रहे।
user: धन्यवाद
assistant: आपका स्वागत है, आपका दिन अच्छा रहे।
```

## What this call demonstrates

| Moment | Behaviour | Prompt section |
|---|---|---|
| Greeting | Uses the preloaded `{customer_name}` to confirm the recipient | S3 |
| Introduction | Honest AI disclosure + Facebook context + permission before any pitch | S4 Q1 |
| Qualification | One question, 3 or 4 BHK | S5 Q1 |
| Pitch | One verified fact per turn; "square feet" in full; "पाँच हज़ार पाँच सौ" spoken unambiguously | S5 Q2 to Q4, Verified Facts, Pronunciation |
| "Total kitna padega?" | No figure, no multiplication; cost sheet deferred; expert offered; "no" respected | FAQ 5, Pricing Guardrails |
| "Saturday" | Date resolved by **lookup** in `upcoming_dates` → "शनिवार, इक्कीस नवंबर" (fix for D7) | S6 Q1 |
| Slots | Real Cal.com availability, spread across the day, each with सुबह, दोपहर or शाम (fix for D15, D17) | S6 Q2 + tool rules |
| "Das baje?" | 10:00 was already booked → "उस time का slot खाली नहीं है" + real alternatives | S6 Branch F (fix for D16) |
| Read-back | **One** line confirms date, time and email; booking only after "haan" (fix for D18) | S6 Q3 |
| Booked | "book हो गया" only after the booking tool ran; the agent ends the call | S7 A, Booking Guardrails |

## Evidence the tools ran

Bolna's tool panel does not list tool calls, so the evidence is downstream state:
1. The 10:00 slot was correctly reported as taken; an earlier test booking occupies it in Cal.com.
2. **Cal.com shows the new booking Confirmed** for Sat 21 Nov 2026, 9:00 to 9:30 IST, and the confirmation email arrived.

## Redaction applied

The customer email is masked as `a***********5@gmail.com`. Phone numbers are not included. Nothing else is changed.

## Earlier submission candidate

`6b56f180` (prompt v0.8, scored 98) is kept as a backup in [tests/transcripts/](../tests/transcripts/). It was replaced because the submission recording must use the submitted prompt version.
