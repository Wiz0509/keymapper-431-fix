#!/usr/bin/env bash
# One-time Codespace setup: apktool + smali + Android build-tools (zipalign, apksigner).
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
sudo apt-get update -qq
sudo apt-get install -y -qq patch wget unzip curl >/dev/null
mkdir -p "$HOME/.local/bin"
cd "$HOME/.local/bin"
[ -f apktool.jar ] || wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.7.0/apktool_2.7.0.jar -O apktool.jar
[ -f smali.jar ] || wget -q https://github.com/JesusFreke/smali/releases/download/v2.5.2/smali-2.5.2.jar -O smali.jar
printf '#!/bin/sh\nexec java -jar "$HOME/.local/bin/apktool.jar" "$@"\n' > apktool
printf '#!/bin/sh\nexec java -jar "$HOME/.local/bin/smali.jar" "$@"\n' > smali
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
"$HOME/.local/bin/smali" --version 2>&1 | head -1
"$ANDROID_HOME/build-tools/34.0.0/zipalign" 2>&1 | head -1 || true
"$ANDROID_HOME/build-tools/34.0.0/apksigner" version 2>&1 | head -1 || true
