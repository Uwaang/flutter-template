"""Build synthetic Android runtime smoke config using the actual debug certificate."""

import base64
import hashlib
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[2]
properties = {}
for line in (root / "android/extras/keystores/debug.properties").read_text().splitlines():
    if "=" in line and not line.lstrip().startswith("#"):
        key, value = line.split("=", 1)
        properties[key.strip()] = value.strip()
for key in ("storeFile", "storePassword", "keyAlias"):
    if not properties.get(key):
        raise SystemExit(f"Missing debug signing property: {key}")

keystore = (root / "android/app" / properties["storeFile"]).resolve()
if not keystore.is_file():
    raise SystemExit("Debug keystore fixture not found")
cert = subprocess.run(
    [
        "keytool", "-exportcert", "-keystore", str(keystore),
        "-storepass", properties["storePassword"], "-alias", properties["keyAlias"],
    ],
    check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
).stdout
if not cert:
    raise SystemExit("Unable to export debug signing certificate")

digest = hashlib.sha256(cert).digest()
assert len(digest) == 32
debug_hash = base64.b64encode(digest).decode("ascii")
replacements = {
    "APP_ID=com.example.flutter_template": "APP_ID=com.strv.flutter.template",
    **{
        f"SIGNING_CERT_{kind}_BASE64=Y2k=": f"SIGNING_CERT_{kind}_BASE64={debug_hash}"
        for kind in ("DEBUG", "RELEASE", "GOOGLE_PLAY")
    },
}
for filename in (".env", ".env-development", ".env-staging", ".env-production"):
    path = root / filename
    content = path.read_text()
    for original, replacement in replacements.items():
        if content.count(original) != 1:
            raise SystemExit(f"Unexpected CI placeholder in {filename}")
        content = content.replace(original, replacement)
    path.write_text(content)

# All slots contain the *debug* hash only for this synthetic profile APK.
# This does not sign or configure a real production release.
print("Android smoke CI fixture: debug certificate SHA-256 and matching app ID")
