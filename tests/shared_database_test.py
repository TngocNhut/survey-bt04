"""Check both local apps write only their assigned tables. Removes only its unique test rows."""
import json
import os
import shutil
import subprocess
import sys
import uuid
from urllib.parse import urlencode
from urllib.request import urlopen

base = (sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8086").rstrip("/")
psql = shutil.which("psql") or "C:/Program Files/PostgreSQL/17/bin/psql.exe"
env = dict(os.environ, PGPASSWORD=os.environ["DB_PASSWORD"], PGCLIENTENCODING="UTF8",
           PGSSLMODE=os.environ.get("DB_SSLMODE", "require"))

def query(sql):
    result = subprocess.run([psql, "-X", "-A", "-t", "-v", "ON_ERROR_STOP=1",
                             "-h", env["DB_HOST"], "-p", env.get("DB_PORT", "5432"),
                             "-U", env["DB_USER"], "-d", env["DB_NAME"], "-c", sql],
                            env=env, text=True, encoding="utf-8", capture_output=True, timeout=15)
    assert result.returncode == 0, result.stderr
    return result.stdout.strip()

def send(path, data):
    with urlopen(base + path, data=urlencode(data).encode(), timeout=20) as response:
        assert response.status == 200
        return response.read().decode("utf-8")

email = "shared-test-" + uuid.uuid4().hex + "@example.com"
counts = [int(query("SELECT count(*) FROM " + table)) for table in ("w1_weblisting", "w2_survey")]
try:
    w1 = dict(action="add", email=email, firstName="Nhật O'Connor", lastName="Nguyễn")
    assert "Nhật" in send("/w1weblisting/emailList", w1)
    row = json.loads(query("SELECT row_to_json(t) FROM w1_weblisting t WHERE email='" + email + "'"))
    assert row["first_name"] == w1["firstName"] and row["last_name"] == w1["lastName"]
    assert int(query("SELECT count(*) FROM w2_survey")) == counts[1]
    w2 = dict(w1, date="2004-09-20", heardFrom="Social Media", wantsUpdates="yes", contactVia="Email only")
    assert "Thanks for completing our survey" in send("/ch04survey/emailList", w2)
    assert int(query("SELECT count(*) FROM w1_weblisting")) == counts[0] + 1
    row = json.loads(query("SELECT row_to_json(t) FROM w2_survey t WHERE email='" + email + "'"))
    assert row["date_of_birth"] == "2004-09-20" and row["wants_updates"] is True
    assert row["email_announcements"] is False and row["contact_via"] == "Email only"
finally:
    # Only remove records with this run's generated email; preserve all copied/source records.
    for table in ("w1_weblisting", "w2_survey"):
        query("DELETE FROM " + table + " WHERE email='" + email + "'")
assert [int(query("SELECT count(*) FROM " + table)) for table in ("w1_weblisting", "w2_survey")] == counts
print("PASS: both websites use ltweb_postgre, write to separate tables, UTF-8 and survey fields correct; copied data preserved")
