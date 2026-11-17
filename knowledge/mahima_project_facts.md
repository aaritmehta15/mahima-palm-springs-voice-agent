# Mahima Palm Springs: Verified Project Facts

This is the **only** source of property facts for the agent. Every fact the agent speaks must trace back to a row in Section 1. Anything else is unknown and must be escalated, never guessed.

Source: the assignment brief (Futwork Prompt Engineer assignment). No other source has been verified.

## 1. Verified facts

| ID | Fact | Exact wording in brief | How the agent says it (Hinglish) |
|---|---|---|---|
| F1 | Project name | Mahima Palm Springs | Mahima Palm Springs |
| F2 | Project type | premium gated township | premium gated township |
| F3 | Road and city | located at Tonk Road, Jaipur | टोंक रोड, जयपुर |
| F4 | Landmark distance | 3 kilometers from Chokhi Dhani | चोखी ढाणी से सिर्फ़ तीन किलोमीटर |
| F5 | Landmark opposite | Near Radha Swami Satsang Beas ke saamne | राधा स्वामी सत्संग ब्यास के बिल्कुल सामने |
| F6 | Configurations | 3 and 4 bedroom spacious flats | तीन और चार BHK के spacious flats |
| F7 | Possession | possession due in Jan 2027 | possession जनवरी दो हज़ार सत्ताईस में due है |
| F8 | Flat size range | 1705 sq. ft. to 2619 sq. ft | सत्रह सौ पाँच से छब्बीस सौ उन्नीस sq. ft. तक |
| F9 | Current rate | ₹5500 per sq. ft. | अभी का rate पचपन सौ रुपये per sq. ft. है |
| F10 | Lead source | The customer enquired via a facebook ad | आपने Facebook ad पर enquiry की थी |

### Speaking rules for these facts

- Numbers are always spoken in words, never as digits.
- Say "possession due in January 2027". Never say "ready", "guaranteed" or "on time".
- Say "current rate". Rates can change, so never promise the rate will stay the same.
- Size is a range across the project. Do not say which size belongs to the 3 BHK or the 4 BHK.

## 2. Unknown facts: the agent must not state these

| Topic | Why it is unknown | Agent response pattern |
|---|---|---|
| Amenities (pool, gym, clubhouse, parks, security systems) | Not in the brief | A senior expert will confirm; offer a callback or the site visit |
| Exact inventory, floors, towers, facing, units left | Not in the brief | Same |
| Which size maps to 3 BHK and which to 4 BHK | Only the overall range is given | Give the range only; the expert shares floor plans |
| Carpet, built-up or super built-up basis of the size | Not specified | Do not label the area type |
| Total flat price or any multiplication of rate by area | Area basis and charges unknown | Never calculate; the expert shares the official cost sheet |
| Discounts, offers, payment plans, booking amount | Not in the brief | No offers can be confirmed on this call |
| GST, registration, stamp duty, maintenance, parking, PLC | Not in the brief | Expert confirms |
| RERA registration number or status | Not in the brief | Expert confirms; never claim it is or is not registered |
| Construction progress beyond the possession date | Not in the brief | Only the January 2027 possession date may be stated |
| Developer name, history, past projects, guarantees | Not in the brief | Expert confirms |
| Home loans, bank tie-ups, EMI figures | Not in the brief | Expert confirms |
| Site office timings | Not in the brief | Only slots returned by the calendar tool may be offered |
| Price appreciation, rental yield, investment returns | Not in the brief and not promisable | Never promise returns |

## 3. Things that are deliberately NOT in this file

Facts from the reference repositories (for example Northstar One in Gurugram, its prices, its sales agent names or booking tokens) are fictional and belong to another project. None of them are used here.

## 4. Change control

Any new fact must come from a verifiable client source. Record it here first with its source and date, then add it to the prompt and log the change in [prompts/prompt_change_log.md](../prompts/prompt_change_log.md).
