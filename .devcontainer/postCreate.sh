#!/usr/bin/env bash
# One-time Codespace setup. Verified recipe (2026-10-06):
# - apktool 2.7.0 pinned upstream jar  -> DECODE (byte-exact for our patches)
# - smali  -> Debian apktool package jars (org.jf.smali.Main, tested byte-identical)
# - zipalign/apksigner -> Android build-tools via sdkmanager
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
sudo apt-get update -qq
sudo apt-get install -y -qq apktool libjcommander-java patch wget unzip curl >/dev/null
mkdir -p "$HOME/.local/bin"
cd "$HOME/.local/bin"
[ -f apktool-2.7.0.jar ] || wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.7.0/apktool_2.7.0.jar -O apktool-2.7.0.jar
printf '#!/bin/sh\nexec java -jar "$HOME/.local/bin/apktool-2.7.0.jar" "$@"\n' > apktool
SMALI_CP="/usr/share/apktool/smali.jar:/usr/share/apktool/dexlib2.jar:/usr/share/apktool/smali-util.jar:/usr/share/apktool/guava.jar:/usr/share/apktool/antlr3-runtime.jar:/usr/share/java/jcommander.jar"
for j in /usr/share/apktool/smali.jar /usr/share/apktool/dexlib2.jar /usr/share/apktool/smali-util.jar /usr/share/apktool/guava.jar /usr/share/apktool/antlr3-runtime.jar /usr/share/java/jcommander.jar; do
  [ -f "$j" ] || { echo "MISSING: $j (apt layout changed?)"; exit 1; }
done
printf '#!/bin/sh\nexec java -cp "%s" org.jf.smali.Main "$@"\n' "$SMALI_CP" > smali
chmod +x apktool smali
if [ ! -d /opt/android-sdk/cmdline-tools/latest ]; then
  cd /tmp
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip
  sudo mkdir -p /opt/android-sdk/cmdline-tools
  sudo unzip -q -o tools.zip -d /opt/android-sdk/cmdline-tools
  sudo mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest
  rm -f tools.zip
  sudo chown -R "$(id -u):$(id -g)" /opt/android-sdk
fi
export ANDROID_HOME=/opt/android-sdk
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "build-tools;34.0.0" >/dev/null 2>&1 || true
echo "--- versions ---"
"$HOME/.local/bin/apktool" --version
BT=/opt/android-sdk/build-tools/34.0.0
[ -x "$BT/zipalign" ] && [ -x "$BT/apksigner" ] || { echo "build-tools missing!"; exit 1; }
echo "--- smoke test: assemble ---"
mkdir -p /tmp/smoke/smali/a && printf '.class La/A;\n.super Ljava/lang/Object;\n' > /tmp/smoke/smali/a/A.smali
"$HOME/.local/bin/smali" assemble /tmp/smoke/smali -o /tmp/smoke/out.dex && echo SMOKE_OK && rm -rf /tmp/smoke
