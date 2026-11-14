"""
Pull recent job/internship posts from marine-related job boards and filter them
to marine roles in the Seattle / Puget Sound area, hiding roles built around
harvesting or using animals.

Sources:
  mes       Evergreen MES Weekly              https://sites.evergreen.edu/mesweekly/
  uw        UW Marine Biology job board       https://marinebiology.uw.edu/news/category/job
  safs      UW Aquatic & Fishery Sciences     https://fish.uw.edu/news-events/category/student-career-opportunities
  usajobs   Federal jobs within 50 mi of Seattle (needs a free API key, see below)

Stdlib only, no installs needed.

USAJOBS setup: request a free key at https://developer.usajobs.gov/apirequest/
then set these (fish shell):
    set -Ux USAJOBS_API_KEY your-key-here
    set -Ux USAJOBS_EMAIL the-email-you-registered-with
Until they're set, the usajobs source is skipped.

Usage:
    python3 marine_jobs.py                  # all sources, last 30 days
    python3 marine_jobs.py --source uw      # just one source (repeatable)
    python3 marine_jobs.py --days 7 --new   # only posts you haven't seen before
    python3 marine_jobs.py --show-excluded  # also list animal-use exclusions, and why
    python3 marine_jobs.py --anywhere       # skip the location filter
    python3 marine_jobs.py --any-topic      # skip the marine-topic filter
    python3 marine_jobs.py --include-expired
    python3 marine_jobs.py --new --quiet    # print nothing unless there's a match
"""

import argparse
import html
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import date, datetime, timedelta
from pathlib import Path

# systemd sets STATE_DIRECTORY for services with StateDirectory=.
STATE_DIR = Path(os.environ.get("STATE_DIRECTORY") or Path.home() / ".local/share/marine-jobs")
STATE_FILE = STATE_DIR / "seen.json"
OLD_STATE_FILE = Path.home() / ".local/share/mes-jobs/seen.json"  # pre-rename
USER_AGENT = "marine-jobs-script/1.4"

WORDPRESS_SOURCES = {
    "mes": {
        "label": "MES",
        "api": "https://sites.evergreen.edu/mesweekly/wp-json/wp/v2",
        "categories": None,      # everything; non-jobs skipped by title
        "assume_marine": False,  # board covers all environmental fields
    },
    "uw": {
        "label": "UW",
        "api": "https://marinebiology.uw.edu/wp-json/wp/v2",
        "categories": ["job", "internship-and-research-opportunities", "other-opportunities"],
        "assume_marine": True,   # it's a marine biology board
    },
    "safs": {
        "label": "SAFS",
        "api": "https://fish.uw.edu/wp-json/wp/v2",
        "categories": ["student-career-opportunities"],
        "assume_marine": False,  # lots of freshwater/salmon work too
    },
}

USAJOBS = {
    "label": "USAJOBS",
    "location": "Seattle, Washington",
    "radius_miles": 50,
    # OPM job series: 0401 natural resources/biology, 0404 bio science tech,
    # 0408 ecology, 0410 zoology, 1301 physical science, 1360 oceanography
    "series": ["0401", "0404", "0408", "0410", "1301", "1360"],
}

SOURCE_NAMES = list(WORDPRESS_SOURCES) + ["usajobs"]

# --- Tweak these lists to taste -------------------------------------------
# Terms are whole words/phrases. A trailing * makes a stem match
# ("estuar*" matches estuary, estuarine).

LOCAL_PLACES = [
    "seattle", "bainbridge", "bremerton", "kitsap", "manchester", "port orchard",
    "poulsbo", "vashon", "tacoma", "everett", "edmonds", "mukilteo", "shoreline",
    "bellevue", "redmond", "kirkland", "renton", "kent", "burien", "des moines",
    "federal way", "lynnwood", "snohomish", "king county", "pierce county",
    "puget sound", "salish sea", "hood canal", "olympia", "lacey", "tumwater",
    "shelton", "gig harbor", "port townsend", "whidbey", "anacortes",
    "bellingham", "mount vernon", "skagit", "la conner", "kingston",
]

# Place names that are also ordinary words or exist in many states. They
# only count when they're in the title's location, never in the body.
AMBIGUOUS_PLACES = ["shoreline", "kent", "manchester", "des moines", "kingston",
                    "olympia", "puget sound", "salish sea"]

# A post is "marine" if one of these is in the title, or 2+ different ones
# are in the body. (Skipped for boards that are marine-only.)
MARINE = [
    "marine", "ocean*", "kelp", "eelgrass", "seagrass", "seaweed", "estuar*",
    "intertidal", "subtidal", "nearshore", "coastal", "salish sea", "puget sound",
    "plankton", "phytoplankton", "zooplankton", "benthic", "benthos", "sediment",
    "shellfish", "beach", "tidal", "scuba", "dive", "diving", "snorkel*",
    "water quality", "aquatic", "ocean acidification", "pinniped*", "cetacean*",
]

# Hidden wherever they appear: these describe the work itself.
EXCLUDE_ANYWHERE = [
    "creel", "catch survey*", "test fish*", "electrofish*", "stomach content*",
    "otolith*", "stock assessment", "harvest management", "fish husbandry",
    "animal husbandry", "euthan*", "lethal sampling", "dissect*", "seafood",
    "shellfish farm*", "oyster farm*", "fish farm*", "port sampler*",
    "dockside sampl*",
]

# Hidden only if in the title (in the body they're often just an agency
# name or a passing mention, so there they become a ⚑ flag instead).
EXCLUDE_IN_TITLE = [
    "fisheries", "fishery", "aquaculture", "harvest*",
    "hatchery", "aquarium", "zoo", "husbandry", "animal care",
]

# Flagged for you to judge, never hidden.
FLAG = [
    "hatchery", "tagging", "trapping", "seine", "seining", "capture",
    "animal handling", "specimen collection", "fisheries", "fishery",
    "aquaculture", "harvest*", "aquarium", "fish collection", "screw trap*",
    "specimen*", "trawl*", "commercial fish*",
]

# Titles containing these are skipped (events, not jobs).
SKIP_TITLE_WORDS = [
    "workshop", "panel", "info session", "information session", "webinar",
    "recording*", "career fair", "community event", "seminar", "open house",
]

# Titles starting with these are skipped (not jobs).
SKIP_PREFIXES = ["event:", "resources:", "resource:", "news:"]

# ---------------------------------------------------------------------------

TAG_RE = re.compile(r"<[^>]+>")
PAREN_RE = re.compile(r"\(([^()]*)\)")
STATE_RE = re.compile(r",\s*[A-Z]{2}\b|\bremote\b", re.IGNORECASE)
DEADLINE_RE = re.compile(
    r"(?:deadline|apply by|closes?|closing date|applications? due|due by)"
    r"[^A-Za-z0-9]{0,15}"
    r"([A-Z][a-z]{2,8}\.? \d{1,2},? \d{4}|\d{1,2}/\d{1,2}/\d{2,4})",
    re.IGNORECASE,
)
PAY_RE = re.compile(
    r"\$\s?\d[\d,]*(?:\.\d+)?(?:\s?(?:-|–|to)\s?\$?\s?\d[\d,]*(?:\.\d+)?)?"
    r"(?:\s?(?:/|per)\s?(?:hour|hr|month|year|yr|week))?",
    re.IGNORECASE,
)
DATE_FORMATS = ["%B %d, %Y", "%B %d %Y", "%b %d, %Y", "%b %d %Y",
                "%m/%d/%Y", "%m/%d/%y"]


def compile_terms(terms):
    out = []
    for t in terms:
        stem = t.endswith("*")
        core = re.escape(t.rstrip("*")).replace(r"\ ", r"\s+")
        out.append((t.rstrip("*"), re.compile(rf"\b{core}" + ("" if stem else r"\b"))))
    return out


LOCAL_P = compile_terms(LOCAL_PLACES)
LOCAL_BODY_P = compile_terms([p for p in LOCAL_PLACES if p not in AMBIGUOUS_PLACES])
MARINE_P = compile_terms(MARINE)
EXCL_ANY_P = compile_terms(EXCLUDE_ANYWHERE)
EXCL_TITLE_P = compile_terms(EXCLUDE_IN_TITLE)
FLAG_P = compile_terms(FLAG)
SKIP_TITLE_P = compile_terms(SKIP_TITLE_WORDS)


def hits(text, patterns):
    return [name for name, rx in patterns if rx.search(text)]


def clean(text):
    return re.sub(r"\s+", " ", html.unescape(TAG_RE.sub(" ", text or ""))).strip()


def parse_date(s):
    s = s.replace(".", "").strip()
    for fmt in DATE_FORMATS:
        try:
            return datetime.strptime(s, fmt).date()
        except ValueError:
            pass
    return None


def get_json(url, headers=None):
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, **(headers or {})})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp), resp.headers


# --- Fetchers: each returns a list of normalized posts ---------------------
# {id, date, link, title, body, local (True/None), deadline_str, pay}

class SkipSource(Exception):
    """Source can't run (e.g. no API key). Reported as a note, not an error."""


def fetch_wordpress(name, days):
    src = WORDPRESS_SOURCES[name]
    params = {
        "after": (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%dT00:00:00"),
        "per_page": 100,
        "_fields": "id,date,link,title,content",
    }
    if src["categories"]:
        q = urllib.parse.urlencode({"slug": ",".join(src["categories"]), "_fields": "id,slug"})
        cats, _ = get_json(f"{src['api']}/categories?{q}")
        if not cats:
            raise RuntimeError(f"none of the categories {src['categories']} exist")
        params["categories"] = ",".join(str(c["id"]) for c in cats)

    raw, page = [], 1
    while True:
        q = urllib.parse.urlencode({**params, "page": page})
        try:
            batch, headers = get_json(f"{src['api']}/posts?{q}")
        except urllib.error.HTTPError as e:
            if e.code == 400 and page > 1:  # past the last page
                break
            raise
        raw.extend(batch)
        if page >= int(headers.get("X-WP-TotalPages", 1)) or not batch:
            break
        page += 1

    return [{
        "id": p["id"],
        "date": p["date"][:10],
        "link": p["link"],
        "title": clean(p["title"]["rendered"]),
        "body": clean(p["content"]["rendered"]),
        "local": None,          # work it out from the text
        "deadline_str": None,   # parse from the body
        "pay": None,
    } for p in raw]


def fetch_usajobs(days):
    key, email = os.environ.get("USAJOBS_API_KEY"), os.environ.get("USAJOBS_EMAIL")
    if not (key and email):
        raise SkipSource("set USAJOBS_API_KEY and USAJOBS_EMAIL to enable (see --help)")

    params = urllib.parse.urlencode({
        "LocationName": USAJOBS["location"],
        "Radius": USAJOBS["radius_miles"],
        "JobCategoryCode": ";".join(USAJOBS["series"]),
        "DatePosted": min(days, 60),  # API maximum is 60
        "ResultsPerPage": 500,
    })
    data, _ = get_json(
        f"https://data.usajobs.gov/api/search?{params}",
        headers={"Host": "data.usajobs.gov", "User-Agent": email, "Authorization-Key": key},
    )

    posts = []
    for item in data.get("SearchResult", {}).get("SearchResultItems", []):
        d = item.get("MatchedObjectDescriptor", {})
        details = d.get("UserArea", {}).get("Details", {})
        pay = None
        for r in d.get("PositionRemuneration", [])[:1]:
            lo, hi = float(r.get("MinimumRange", 0)), float(r.get("MaximumRange", 0))
            per = {"PA": "year", "PH": "hour"}.get(r.get("RateIntervalCode"), r.get("Description", ""))
            pay = f"${lo:,.0f} – ${hi:,.0f} per {per}" if hi else None
        close = (d.get("ApplicationCloseDate") or "")[:10]
        posts.append({
            "id": item.get("MatchedObjectId") or d.get("PositionID"),
            "date": (d.get("PublicationStartDate") or "")[:10],
            "link": d.get("PositionURI", ""),
            "title": f"{d.get('PositionTitle', '?')}, {d.get('OrganizationName', '')} "
                     f"({d.get('PositionLocationDisplay', '')})",
            "body": clean(" ".join([
                details.get("JobSummary", ""),
                d.get("QualificationSummary", ""),
                " ".join(details.get("MajorDuties", []) or []),
            ])),
            "local": True,  # the API already filtered by radius
            "deadline_str": close or None,
            "pay": pay,
        })
    return posts


def fetch(name, days):
    if name == "usajobs":
        return fetch_usajobs(days)
    return fetch_wordpress(name, days)


def label_for(name):
    return USAJOBS["label"] if name == "usajobs" else WORDPRESS_SOURCES[name]["label"]


def assume_marine(name):
    return name != "usajobs" and WORDPRESS_SOURCES[name]["assume_marine"]


# --- Filtering ---------------------------------------------------------------

def is_local(title, body):
    # Check every "(...)" in the title, e.g. "(Marine Ecology) (Everett) (PAID)".
    parens = [p.lower() for p in PAREN_RE.findall(title)]
    if any(hits(p, LOCAL_P) for p in parens):
        return True
    if any(STATE_RE.search(p) for p in parens):
        return False  # title names a location, and it isn't local
    return bool(hits(body, LOCAL_BODY_P))  # no location in title, check body


def analyze(source, post):
    title, body = post["title"], post["body"]
    t, b = title.lower(), body.lower()

    marine = (assume_marine(source)
              or bool(hits(t, MARINE_P))
              or len(set(hits(b, MARINE_P))) >= 2)

    excluded = sorted(set(hits(f"{t} {b}", EXCL_ANY_P) + hits(t, EXCL_TITLE_P)))
    flags = sorted(set(hits(f"{t} {b}", FLAG_P)) - set(excluded))

    deadline_str = post["deadline_str"]
    if deadline_str:  # ISO date from an API
        deadline = date.fromisoformat(deadline_str)
    else:
        m = DEADLINE_RE.search(body)
        deadline_str = m.group(1) if m else None
        deadline = parse_date(deadline_str) if deadline_str else None

    pay = post["pay"]
    if not pay:
        m = PAY_RE.search(body)
        pay = m.group(0).rstrip(",") if m else None

    return {
        "key": f"{source}:{post['id']}",
        "source": label_for(source),
        "date": post["date"],
        "link": post["link"],
        "title": title,
        "is_job": not (any(t.startswith(p) for p in SKIP_PREFIXES) or hits(t, SKIP_TITLE_P)),
        "local": post["local"] if post["local"] is not None else is_local(title, b),
        "marine": marine,
        "excluded": excluded,
        "flags": flags,
        "deadline_str": deadline_str,
        "expired": bool(deadline and deadline < date.today()),
        "pay": pay,
    }


# --- State & output ------------------------------------------------------------

def load_seen():
    path = STATE_FILE if STATE_FILE.exists() else OLD_STATE_FILE
    try:
        raw = json.loads(path.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return set()
    # Older versions stored bare MES post ids.
    return {k if isinstance(k, str) else f"mes:{k}" for k in raw}


def save_seen(seen):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(sorted(seen)))


def show(job):
    print(f"• [{job['source']}] {job['title']}")
    print(f"  posted {job['date']}  {job['link']}")
    extras = []
    if job["pay"]:
        extras.append(f"pay: {job['pay']}")
    if job["deadline_str"]:
        extras.append(f"deadline: {job['deadline_str']}")
    if extras:
        print("  " + " | ".join(extras))
    if job["flags"]:
        print(f"  ⚑ mentions: {', '.join(job['flags'])}")
    print()


def main():
    ap = argparse.ArgumentParser(
        description=__doc__.split("\n\n")[0],
        epilog="Run with -h to see this; full notes are at the top of the file.",
    )
    ap.add_argument("--source", choices=SOURCE_NAMES, action="append",
                    help="only check this source (repeatable; default: all)")
    ap.add_argument("--days", type=int, default=30, help="how far back to look (default 30)")
    ap.add_argument("--new", action="store_true", help="only posts not seen on a previous run")
    ap.add_argument("--show-excluded", action="store_true", help="list animal-use exclusions too")
    ap.add_argument("--anywhere", action="store_true", help="don't filter by location")
    ap.add_argument("--any-topic", action="store_true", help="don't require marine keywords")
    ap.add_argument("--include-expired", action="store_true", help="keep posts past their deadline")
    ap.add_argument("--quiet", action="store_true",
                    help="print nothing (besides errors) when there are no matching posts")
    args = ap.parse_args()

    jobs, failures, ran = [], 0, 0
    for source in args.source or SOURCE_NAMES:
        try:
            jobs += [analyze(source, p) for p in fetch(source, args.days)]
            ran += 1
        except SkipSource as e:
            print(f"  ({label_for(source)} skipped: {e})", file=sys.stderr)
        except Exception as e:
            failures += 1
            print(f"⚠ Couldn't read {label_for(source)}: {e}", file=sys.stderr)
    if failures and not ran:
        return 1

    # Every fetched key is marked seen, including cross-post duplicates, so a
    # duplicate doesn't resurface as new once the copy kept here ages out.
    fetched_keys = {j["key"] for j in jobs}

    # Same job cross-posted on several boards: keep the first one seen.
    by_title = {}
    for j in jobs:
        by_title.setdefault(re.sub(r"\W+", " ", j["title"].lower()).strip(), j)
    jobs = sorted(by_title.values(), key=lambda j: j["date"], reverse=True)

    seen = load_seen()
    pool = [j for j in jobs if j["key"] not in seen] if args.new else jobs

    counts = {"not a job": 0, "outside area": 0, "not marine": 0, "expired": 0}
    candidates = []
    for j in pool:
        if not j["is_job"]:
            counts["not a job"] += 1
        elif not (args.anywhere or j["local"]):
            counts["outside area"] += 1
        elif not (args.any_topic or j["marine"]):
            counts["not marine"] += 1
        elif j["expired"] and not args.include_expired:
            counts["expired"] += 1
        else:
            candidates.append(j)

    keep = [j for j in candidates if not j["excluded"]]
    dropped = [j for j in candidates if j["excluded"]]

    if args.quiet and not keep:
        save_seen(seen | fetched_keys)
        return 0

    label = "new " if args.new else ""
    skipped = ", ".join(f"{n} {k}" for k, n in counts.items() if n)
    print(f"\n{len(keep)} {label}matching posts in the last {args.days} days")
    print(f"(skipped: {len(dropped)} animal-use{', ' + skipped if skipped else ''})\n")
    for j in keep:
        show(j)

    if args.show_excluded and dropped:
        print("── Excluded for animal use ──\n")
        for j in dropped:
            print(f"• [{j['source']}] {j['title']}  [{', '.join(j['excluded'])}]")
            print(f"  {j['link']}\n")

    save_seen(seen | fetched_keys)
    return 0


if __name__ == "__main__":
    sys.exit(main())
