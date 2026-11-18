"""Automatic checks on Bolna call transcripts for the Mahima Palm Springs agent.

Usage:
    python -I tests/check_transcript.py <file> [<file> ...]
    python -I tests/check_transcript.py tests/transcripts/*.txt --report tests/transcript_check_report.md

Accepts a plain transcript (.txt with "assistant:" / "user:" lines), a Markdown file containing the
transcript in a ``` block, or a Bolna execution JSON (uses its "transcript" field).

Severity
    CRITICAL  matches a critical failure in tests/evaluation_rubric.md (automatic FAIL)
    MAJOR     breaks a hard prompt rule the customer would notice
    MINOR     style issue

The checker is deliberately rule based: it is cheap, deterministic and runs on every call. It cannot see
tool results, so a flagged booking claim still has to be confirmed against Cal.com.
Exit code is 1 if any CRITICAL flag is found.
"""
import json
import re
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

# Lines Bolna plays itself (welcome message, pre-tool messages, user-online check). Not written by the model.
SYSTEM_LINES = (
    "नमस्ते, क्या मेरी बात",
    "एक second, मैं उस दिन के available slots check कर रही हूँ",
    "ठीक है, मैं आपका slot book कर रही हूँ",
    "Hello, क्या आप मुझे सुन पा रहे हैं",
)
BOOKING_TOOL_MSG = "ठीक है, मैं आपका slot book कर रही हूँ"

RE_TOTAL = re.compile(r"लाख|करोड़|\blakh\b|\bcrore\b", re.I)
RE_AMENITY = re.compile(r"swimming pool|\bpool\b|\bgym\b|club ?house|स्विमिंग|जिम\b", re.I)
RE_OPTOUT_USER = re.compile(r"call मत|मत call|call mat|mat call|मत करना|मत करो|number हटा|हटा दो|don'?t call|do not call|remove my number|दोबारा call नहीं", re.I)
RE_PITCH = re.compile(r"site visit|BHK|rate|slot|possession|book कर", re.I)
RE_AI_Q = re.compile(r"robot|रोबोट|\bAI\b|इंसान|insaan|machine|मशीन|real person", re.I)
RE_DIGIT = re.compile(r"\d")
RE_EMAIL = re.compile(r"[\w.+*-]+@[\w-]+\.[\w.]+")
RE_ABBREV = re.compile(r"\bsq\.? ?ft\b|\bsqft\b|पचपन सौ", re.I)
RE_FORMAL = re.compile(r"कृपया|धन्यवाद|उपलब्ध|निर्माण|संपत्ति|आवास")
RE_MASC = re.compile(r"रहा हूँ|रहा हूं|करूँगा|करूंगा|सकता हूँ|सकता हूं|चाहता हूँ|बताऊँगा")
RE_BAJE = re.compile(r"बजे")
RE_DAYPART = re.compile(r"सुबह|दोपहर|शाम|रात")
RE_WEEKDAY = re.compile(r"सोमवार|मंगलवार|बुधवार|गुरुवार|शुक्रवार|शनिवार|रविवार")
RE_MONTH = re.compile(r"जनवरी|फ़रवरी|फरवरी|मार्च|अप्रैल|मई|जून|जुलाई|अगस्त|सितंबर|अक्टूबर|नवंबर|दिसंबर")
RE_BOOKED = re.compile(r"site visit[^।?]*book हो गया")  # the customer's visit is confirmed (not "slot was taken")


def load(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    if path.suffix == ".json":
        return json.loads(text).get("transcript", "")
    if path.suffix == ".md":
        m = re.search(r"```\s*\n(.*?)```", text, re.S)
        return m.group(1) if m else text
    return text


def parse(text: str):
    turns = []
    for raw in text.splitlines():
        m = re.match(r"\s*(assistant|user)\s*:\s*(.*)", raw)
        if m:
            role, content = m.group(1), m.group(2).strip()
            is_system = role == "assistant" and content.startswith(SYSTEM_LINES)
            turns.append({"role": role, "text": content, "system": is_system})
    return turns


def sentences(text: str):
    text = re.sub(r"sq\. ?ft\.?", "sqft", text, flags=re.I)  # an abbreviation, not a sentence end
    parts = re.split(r"[।?]|\.(?=\s|$)", text)
    return [p for p in (s.strip(" \"'") for s in parts) if len(p) > 1]


def check(turns):
    flags = []

    def flag(sev, code, i, msg):
        flags.append((sev, code, i + 1, msg))

    agent = [(i, t) for i, t in enumerate(turns) if t["role"] == "assistant" and not t["system"]]

    # Opt-out: nothing may be pitched after the customer opts out
    optout_at = next((i for i, t in enumerate(turns) if t["role"] == "user" and RE_OPTOUT_USER.search(t["text"])), None)
    if optout_at is not None:
        for i, t in agent:
            if i > optout_at and RE_PITCH.search(t["text"]) and "दोबारा call नहीं" not in t["text"]:
                flag("CRITICAL", "CF3_PITCH_AFTER_OPTOUT", i, t["text"][:90])

    # Booking claim must follow the booking tool message, which must follow an email confirmation
    tool_at = [i for i, t in enumerate(turns) if t["system"] and t["text"].startswith(BOOKING_TOOL_MSG)]
    email_at = [i for i, t in agent if "email" in t["text"]]
    for i, t in agent:
        if RE_BOOKED.search(t["text"]) and not any(j < i for j in tool_at):
            flag("CRITICAL", "CF1_BOOKED_WITHOUT_TOOL", i, "says booked, but no booking tool message came before it")
    for j in tool_at:
        if not any(e < j for e in email_at):
            flag("MAJOR", "ORDER_BOOKED_BEFORE_EMAIL", j, "booking tool started before the email was confirmed")

    # AI disclosure
    for i, t in enumerate(turns):
        if t["role"] == "user" and RE_AI_Q.search(t["text"]):
            nxt = next((a for k, a in agent if k > i), None)
            if nxt is not None and "AI" not in nxt["text"]:
                flag("CRITICAL", "CF6_AI_NOT_DISCLOSED", i, "customer asked about AI; next reply does not say AI")

    for i, t in agent:
        x = t["text"]
        if RE_TOTAL.search(x):
            flag("CRITICAL", "CF4_TOTAL_PRICE", i, x[:90])
        if RE_AMENITY.search(x):
            flag("CRITICAL", "CF2_AMENITY_MENTIONED", i, x[:90])
        no_email = RE_EMAIL.sub("", x)
        if RE_DIGIT.search(no_email):
            flag("MAJOR", "DIGITS_SPOKEN", i, x[:90])
        if RE_ABBREV.search(x):
            flag("MAJOR", "ABBREVIATION_OR_AMBIGUOUS_NUMBER", i, RE_ABBREV.search(x).group(0))
        if RE_FORMAL.search(x):
            flag("MAJOR", "FORMAL_HINDI", i, RE_FORMAL.search(x).group(0))
        if RE_MASC.search(x):
            flag("MAJOR", "MASCULINE_SELF_FORM", i, RE_MASC.search(x).group(0))
        if "!" in x:
            flag("MINOR", "EXCLAMATION", i, x[:60])
        for s in sentences(x):
            if RE_BAJE.search(s) and not RE_DAYPART.search(s):
                flag("MAJOR", "TIME_WITHOUT_PART_OF_DAY", i, s[:80])
            if RE_WEEKDAY.search(s) and RE_BAJE.search(s) and not RE_MONTH.search(s):
                flag("MAJOR", "VISIT_DAY_WITHOUT_DATE", i, s[:80])
        real = [s for s in sentences(x) if len(s.split()) > 2]  # one-word acknowledgements are not sentences
        if len(real) > 2:
            flag("MINOR", "LONG_TURN", i, f"{len(real)} sentences")

    for (i, a), (k, b) in zip(agent, agent[1:]):
        if a["text"] == b["text"]:
            flag("MINOR", "REPEATED_LINE", k, b["text"][:60])
    return flags


def main(argv):
    report_path = None
    if "--report" in argv:
        idx = argv.index("--report")
        report_path = Path(argv[idx + 1])
        argv = argv[:idx] + argv[idx + 2:]
    files = [Path(a) for a in argv]
    if not files:
        print(__doc__)
        return 0
    any_critical = False
    md = ["# Transcript Check Report", "", "Generated by `tests/check_transcript.py`.", "",
          "| Transcript | Critical | Major | Minor | Verdict |", "|---|---|---|---|---|"]
    details = []
    for f in files:
        raw = load(f)
        if "à¤" in raw:  # UTF-8 Devanagari decoded as Latin-1: the checks would silently pass on garbage
            print(f"\n{f.name}: ERROR  transcript is mis-encoded (Latin-1 mojibake); re-fetch it as UTF-8")
            any_critical = True
            continue
        turns = parse(raw)
        flags = check(turns)
        c = sum(1 for s, *_ in flags if s == "CRITICAL")
        m = sum(1 for s, *_ in flags if s == "MAJOR")
        n = sum(1 for s, *_ in flags if s == "MINOR")
        verdict = "FAIL" if c else ("REVIEW" if m else "PASS")
        any_critical |= bool(c)
        print(f"\n{f.name}: {verdict}  (critical {c}, major {m}, minor {n}, {len(turns)} turns)")
        for sev, code, line, msg in flags:
            print(f"  [{sev}] {code} @ turn {line}: {msg}")
        md.append(f"| `{f.name}` | {c} | {m} | {n} | **{verdict}** |")
        if flags:
            details.append(f"\n### `{f.name}`\n")
            details += [f"- **{sev}** `{code}` (turn {line}): {msg}" for sev, code, line, msg in flags]
    if report_path:
        report_path.write_text("\n".join(md + details) + "\n", encoding="utf-8")
        print(f"\nReport written to {report_path}")
    return 1 if any_critical else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
