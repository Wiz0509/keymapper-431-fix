#!/usr/bin/env bash
# Build patched Key Mapper 4.3.1 from YOUR OWN Play APK.
# Usage:  bash tools/build.sh /path/to/Key_Mapper-4.3.1.apk [BUILD_TAG]
# Output: Key_Mapper_4.3.1_fix-<tag>.apk in current directory.
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

APK_IN="${1:?usage: bash tools/build.sh BASE_APK [BUILD_TAG]}"
TAG="${2:-public}"
OUT="Key_Mapper_4.3.1_fix-${TAG}.apk"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/.local/bin:${ANDROID_HOME:-/opt/android-sdk}/build-tools/34.0.0:$PATH"

for c in apktool smali python3 patch zipalign apksigner keytool curl sha256sum; do
  command -v "$c" >/dev/null || { echo "missing: $c (see README)"; exit 1; }
done

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> decode"
apktool d "$APK_IN" -o "$WORK/src" >/dev/null
echo "==> patch (24 files)"
patch -d "$WORK/src" -p1 --no-backup-if-mismatch < "$REPO/patches/all.patch"
if grep -rn "KMDT" "$WORK/src/smali_classes3/fb/r.smali" | grep -q .; then
  echo "diag remnants found, abort"; exit 1
fi
sed -i "s/KMBUILD f58/KMBUILD ${TAG}/" "$WORK/src/smali_classes3/km/buildtag.smali"
echo "==> assemble 3 dex"
smali assemble "$WORK/src/smali" -o "$WORK/classes.dex"
smali assemble "$WORK/src/smali_classes2" -o "$WORK/classes2.dex"
smali assemble "$WORK/src/smali_classes3" -o "$WORK/classes3.dex"
echo "==> fetch FOSS APK for native libs (Play APK ships none)"
FOSS_URL="https://github.com/keymapperorg/KeyMapper/releases/download/v4.3.1/keymapper-4.3.1-foss.apk"
FOSS_SHA="00fb0b4687dec5328cf06f2f9fcc9d010fe92c7c59a7cfba47dedb11ab6bb45e"
curl -sL --max-time 300 -o "$WORK/foss.apk" "$FOSS_URL"
echo "$FOSS_SHA  $WORK/foss.apk" | sha256sum -c - >/dev/null
echo "==> repack"
python3 "$REPO/tools/repack.py" --orig "$APK_IN" \
  --dex1 "$WORK/classes.dex" --dex2 "$WORK/classes2.dex" --dex3 "$WORK/classes3.dex" \
  --manifest-b64 "$REPO/assets/AndroidManifest-noemoji.b64" \
  --native-apk "$WORK/foss.apk" --out "$WORK/unsigned.apk"
KS="${KEYSTORE:-$REPO/debug.keystore}"
if [ ! -f "$KS" ]; then
  echo "==> generate debug key (password: android)"
  keytool -genkeypair -keystore "$KS" -alias androiddebugkey \
    -keyalg RSA -keysize 2048 -validity 10950 \
    -storepass android -keypass android -dname "CN=Android Debug" >/dev/null 2>&1
fi
echo "==> align + sign + verify"
zipalign -f -p 4 "$WORK/unsigned.apk" "$WORK/aligned.apk"
apksigner sign --ks "$KS" --ks-pass pass:android --out "$REPO/$OUT" "$WORK/aligned.apk"
apksigner verify "$REPO/$OUT" && echo "OK: $OUT" && md5sum "$REPO/$OUT"
