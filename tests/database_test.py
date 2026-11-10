"""Integration check: HTTP submissions plus real PostgreSQL queries. Leaves labeled demo rows.
Load DB_* environment variables first; psql must be installed.
"""
import concurrent.futures
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys
import uuid
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import urlopen

base = sys.argv[1].rstrip("/") + "/"
mode = sys.argv[2] if len(sys.argv) > 2 else "--create"
marker = Path(__file__).resolve().parents[1] / ".runtime/database-test-marker.json"
psql = shutil.which("psql") or "C:/Program Files/PostgreSQL/17/bin/psql.exe"
env = dict(os.environ, PGPASSWORD=os.environ["DB_PASSWORD"],
           PGSSLMODE=os.environ.get("DB_SSLMODE", "require"), PGCLIENTENCODING="UTF8")

table = os.environ.get("DB_TABLE", "w2_survey")
assert re.fullmatch(r"[a-z][a-z0-9_]{0,39}", table)

def query(sql):
    sql = sql.replace("survey_responses", "public." + table)
    result = subprocess.run([psql, "-X", "-A", "-t", "-v", "ON_ERROR_STOP=1",
                             "-h", env["DB_HOST"], "-p", env.get("DB_PORT", "5432"),
                             "-U", env["DB_USER"], "-d", env["DB_NAME"], "-c", sql],
                            env=env, text=True, encoding="utf-8", capture_output=True, timeout=20)
    if result.returncode:
        raise AssertionError(result.stderr)
    return result.stdout.strip()

def send(data=None, path="emailList"):
    try:
        with urlopen(base + path, data=None if data is None else urlencode(data).encode(), timeout=20) as r:
            return r.status, r.read().decode("utf-8")
    except HTTPError as e:
        return e.code, e.read().decode("utf-8")

if mode == "--verify-persistence":
    saved = json.loads(marker.read_text(encoding="utf-8"))
    actual = json.loads(query("SELECT row_to_json(s) FROM survey_responses s WHERE id = " + str(int(saved["id"]))))
    assert actual == saved, (actual, saved)
    assert send(path="health") == (200, "OK")
    print("PASS: persisted row unchanged after restart, id=" + str(saved["id"]))
    sys.exit(0)

email = "db-test-" + uuid.uuid4().hex + "@example.com"
data = dict(action="add", firstName="Nhật O'Connor <script>alert(1)</script>", lastName="Nguyễn",
            email=email, date="2004-09-20", heardFrom="Social Media", wantsUpdates="yes", contactVia="Email only")
if mode == "--expect-unavailable":
    status, html = send(data)
    assert status == 503 and "Thanks for completing" not in html, status
    assert send(path="health")[0] == 503
    print("PASS: database outage returns 503; no false success")
    sys.exit(0)

assert send(path="health") == (200, "OK")
status, html = send(data)
assert status == 200 and "&lt;script&gt;" in html
saved = json.loads(query("SELECT row_to_json(s) FROM survey_responses s WHERE email = '" + email + "'"))
assert saved["first_name"] == data["firstName"] and saved["last_name"] == data["lastName"]
assert saved["email"] == email and saved["date_of_birth"] == data["date"]
assert saved["heard_from"] == "Social Media" and saved["contact_via"] == "Email only"
assert saved["wants_updates"] is True and saved["email_announcements"] is False
assert saved["id"] > 0 and saved["submitted_at"]
marker.parent.mkdir(exist_ok=True)
marker.write_text(json.dumps(saved, ensure_ascii=False), encoding="utf-8")

# Same email must retain multiple complete submissions, including concurrent requests.
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    assert all(status == 200 for status, _ in pool.map(send, [data] * 4))
assert query("SELECT count(*) FROM survey_responses WHERE email = '" + email + "'") == "5"
both = dict(data, emailAnnouncements="yes", contactVia="Postal mail only")
assert send(both)[0] == 200
assert query("SELECT count(*) FROM survey_responses WHERE email = '" + email + "' AND wants_updates AND email_announcements") == "1"
neither = {k: v for k, v in data.items() if k != "wantsUpdates"}
assert send(neither)[0] == 200
assert query("SELECT count(*) FROM survey_responses WHERE email = '" + email + "' AND NOT wants_updates AND NOT email_announcements") == "1"
for changes in (dict(date="2004-02-30"), dict(email="bad"), dict(heardFrom="forged")):
    assert send(dict(data, **changes))[0] == 400
assert query("SELECT count(*) FROM survey_responses WHERE email = '" + email + "'") == "7"
print("PASS: all fields persisted, UTF-8, quotes/HTML, booleans, repeated email, concurrent writes, rejected input; marker id=" + str(saved["id"]))
