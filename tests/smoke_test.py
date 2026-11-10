"""Run against a live Tomcat deployment. Uses only Python standard library."""
import sys
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import urlopen

base = (sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080/ch04survey/").rstrip("/") + "/"

def request(path, data=None):
    payload = None if data is None else urlencode(data).encode("utf-8")
    try:
        with urlopen(base + path, data=payload, timeout=30) as response:
            return response.status, response.read().decode("utf-8")
    except HTTPError as error:
        return error.code, error.read().decode("utf-8")

valid = dict(action="add", firstName="Nhật <script>alert(1)</script>",
             lastName="Nguyễn", email="demo@example.com", date="2004-09-20",
             heardFrom="Social Media", contactVia="Email only", wantsUpdates="yes")
status, html = request("")
assert status == 200 and "Survey" in html and 'method="post"' in html
status, html = request("emailList", valid)
assert status == 200 and "Thanks for completing our survey" in html
for expected in ("Nhật", "Nguyễn", "2004-09-20", "Social Media", "Email only",
                 "Receive announcements: Yes", "Receive email announcements: No", "&lt;script&gt;"):
    assert expected in html, expected
assert "<script>alert(1)</script>" not in html
both = dict(valid, wantsUpdates="yes", emailAnnouncements="yes", contactVia="Postal mail only")
assert "Receive email announcements: Yes" in request("emailList", both)[1]
neither = {key: value for key, value in valid.items() if key != "wantsUpdates"}
assert "Receive announcements: No" in request("emailList", neither)[1]
for changes in (dict(firstName=" "), dict(email="invalid"), dict(date="2004-02-30"),
                dict(date="2999-01-01"), dict(heardFrom="forged"), dict(contactVia="forged"),
                dict(action="unknown")):
    assert request("emailList", dict(valid, **changes))[0] == 400, changes
assert "Survey" in request("emailList?action=join")[1]
assert "Thanks for" not in request("emailList?action=add")[1]
print("PASS: form, JSP result, UTF-8, HTML escaping, checkbox states, validation and Return")
