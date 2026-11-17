# Call Transcript: Submission Recording

This is the real Bolna transcript of the submission call, copied from the execution. The only change is the redaction listed at the end.

| Field | Value |
|---|---|
| Execution ID (first 8 characters) | `6b56f180` |
| Prompt version | v0.8 |
| Date and time | 17 Nov 2026, about 11:01 PM IST |
| How the call was placed | `POST https://api.bolna.ai/call` with `user_data` (customer_name, customer_email, timezone), the same path a Facebook-lead integration would use |
| Duration and cost | 172 s, $0.180 |
| Ended by | Agent (`agent_ended_call`, `end_call_tool`) |
| Outcome | **Site visit confirmed**: a real Cal.com booking, Sat 21 Nov 2026, 11:00 to 11:30 IST |
| Recording | See [recording_url.md](recording_url.md) |

## Transcript

```
assistant: नमस्ते, क्या मेरी बात Aarit जी से हो रही है?
user: हां मैं ही बोल रहा हूं
assistant: मैं नेहा, Mahima Palm Springs की AI assistant बोल रही हूँ। आपने हाल ही में Facebook पर हमारे टोंक रोड, जयपुर वाले project के बारे में enquiry की थी, क्या अभी दो मिनट बात करना ठीक रहेगा?
user: हां जी बताइए
assistant: बहुत अच्छा, thank you। आप Mahima Palm Springs में तीन BHK देख रहे हैं या चार BHK?
user: तीन bhk
assistant: बढ़िया। हमारा project टोंक रोड पर है, चोखी ढाणी से सिर्फ़ तीन किलोमीटर, राधा स्वामी सत्संग ब्यास के बिल्कुल सामने। ये location आपके लिए ठीक रहेगी?
user: हां ठीक है
assistant: ये एक premium gated township है, जिसमें spacious flats सत्रह सौ पाँच से छब्बीस सौ उन्नीस sq. ft. तक के हैं। क्या ये size range आपकी family के हिसाब से ठीक है?
user: हां ठीक है
assistant: Possession जनवरी दो हज़ार सत्ताईस में due है, और अभी का rate पचपन सौ रुपये per sq. ft. है। क्या ये आपके budget में fit बैठता है?
user: हां बैठता है
assistant: Flat की असली feel तो site पर आकर ही आती है। क्या आप family के साथ एक site visit करना चाहेंगे?
user: हां saturday इक्कीस november को
assistant: एक second, मैं उस दिन के available slots check कर रही हूँ।
assistant: शनिवार, इक्कीस नवंबर को सुबह नौ बजे, सुबह साढ़े नौ बजे और दस बजे के slots available हैं। इनमें से कौन सा time आपके लिए ठीक रहेगा?
user: ग्यारह बजे वाला
assistant: तो मैं शनिवार, इक्कीस नवंबर को ग्यारह बजे का slot आपके लिए book कर दूँ?
user: हां
assistant: Booking की confirmation email पर भेजूँगी। क्या मैं उसी email ID पर भेज दूँ जो आपने Facebook form में दी थी, a***********5@gmail.com?
user: हां सही है
assistant: ठीक है, मैं आपका slot book कर रही हूँ, बस एक second।
assistant: आपका site visit शनिवार, इक्कीस नवंबर को ग्यारह बजे के लिए book हो गया है, और confirmation आपकी email पर आ जाएगा। Mahima Palm Springs में आपका इंतज़ार रहेगा, आपका दिन अच्छा रहे।
```

## What this call demonstrates (mapped to the prompt)

| Turn | Behaviour | Prompt section |
|---|---|---|
| 1 | Greets by preloaded name `{customer_name}` and confirms the recipient | S3 Greeting |
| 3 | Honest AI introduction, Facebook enquiry context, asks permission before pitching | S4 Q1 |
| 5 | One light qualification question (3 or 4 BHK) | S5 Q1 |
| 7, 9, 11 | One verified fact per turn, each ending with a question; no invented facts; numbers in words | S5 Q2 to Q4, Verified Project Facts |
| 13 | Bridge to the site visit | S5 Q5 |
| 15 to 16 | Calls the real availability tool; offers up to 3 returned slots | S6 Q1 to Q2, tool rules |
| 18 | Accepts 11:00 because it is in the full tool result (v0.8 fix D13) | S6 Q2 |
| 18 to 19 | Reads back the slot and gets an explicit yes before booking | S6 Q3 |
| 20 | Confirms the preloaded `{customer_email}` instead of asking the customer to spell it | S6 Q4 |
| 22 to 23 | Calls the booking tool and says "book ho gaya" **only after success** | S6 Q4 → S7 Branch A |
| End | Agent ends the call itself | `# Ending the Call` + Bolna hangup prompt |

## Tool calls (evidence)

Bolna's "Function tools" panel and `tool_call_logs` showed empty for this call, as for earlier calls. The evidence that both tools ran is:
1. The slots offered (9:00, 9:30, 10:00) match the Cal.com availability for that day.
2. **Cal.com shows a Confirmed booking**: "Assessment Demo Site Visit between Aarit Mehta and Aarit", Sat 21 Nov 2026, 11:00 to 11:30 IST. A confirmation email was received at the attendee address. Screenshots are in [screenshots/](screenshots/).

## Extracted data

Bolna's built-in Call Summary for this call stated the rate as "5,550 INR per square foot". The agent actually said "पचपन सौ" (5,500), as the transcript shows. This is a summarisation error by the post-call model, not by the agent. It is noted here as a reason to validate extractions against transcripts.

## Rubric score

Factual 100, Flow 100, Hinglish 95, Tools 100, Naturalness 90 → **98 of 100, PASS**, zero critical failures. See [tests/test_results.md](../tests/test_results.md).

## Redaction applied

- The customer email is masked as `a***********5@gmail.com`.
- Phone numbers are not included.
- Nothing else is changed.
