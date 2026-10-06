# Key Mapper 4.3.1 — patched build (build it yourself)

Smali patches + build scripts for **Key Mapper 4.3.1, Play edition**
(package `io.github.sds100.keymapper`).
This repo contains **no APK** — you build from your own copy.

## What the patch does

- Premium unlock (see warning below).
- Hold-to-press fix for games (pairs `downTime` on DOWN/UP key events).
- No black press animation, forced normal alpha, silenced spammy logs.
- Stop service: notification removed, process killed cleanly, no auto-resurrect.
- Notification visibility follows actual service state.

See `patches/` (20 patch files) + `new-files/` (4 new files) for every change.
`patches/17-tc-t-unlock.patch` is the premium unlock — the one risky piece.

## ⚠️ USE AT YOUR OWN RISK

- The **premium unlock** patch bypasses the original app's payment. Building = your
  responsibility (Play ToS violation, risk to your Google account). The repo author
  takes no responsibility.
- Tested on **one device + [Shizuku](https://shizuku.rikka.app)**. Other devices, Android versions, or IME mode may differ.
- Your build uses **your own key** → it **cannot install over** the Play version
  (different signature): export your keymaps in the original app first, uninstall it,
  then install this build. Switching build source/key later also requires reinstall.
- Known issue: the OS **three-finger gesture** (screenshot) steals touches and drops
  held keys — turn that gesture off in your phone's Settings.

## Requirements

- Your own **Key Mapper 4.3.1 Play APK** (do not redistribute this file).
  You already have it: it is the app installed on your phone. To get the file,
  install any free **APK Extractor** app from the Play Store, open it, find
  Key Mapper, and save/export its APK — then upload that file to the Codespace.
  No root, no ADB, no PC needed for this step.
- It must be version **4.3.1** — if the Play Store already updated the app past
  it, the patches may fail to apply. Turn off auto-update for Key Mapper first.
- Build with **GitHub Codespaces** (recommended, preconfigured) or any Linux box
  with the tools below.

## Build with Codespaces

1. Fork this repo (or open a Codespace from its page: `Code` → `Codespaces` → `+`).
2. Wait for setup to finish (first run ~5–10 min: downloads apktool, smali, Android build-tools).
3. Drag-drop your APK into the Codespace file explorer (repo root).
4. Run:
   ```bash
   bash tools/build.sh Key_Mapper-4.3.1.apk mybuild
   ```
   (`mybuild` is your build tag, shown inside the app's Log screen as `KMBUILD mybuild`.)
5. Output: `Key_Mapper_4.3.1_fix-mybuild.apk` in the repo root → right-click → Download.
6. On your phone: **export keymaps in the original app first**, uninstall it, install this file.

Later rebuilds reuse the generated key (`debug.keystore`), so they install over
previous builds from the same Codespace without uninstalling.

## Build on your own Linux machine

Install: Java 17+, `apktool` 2.7.0, `smali` 2.5.2, Android build-tools 34.0.0
(`zipalign`, `apksigner`), `python3`, `patch`, `keytool` (ships with the JDK).
Then run `bash tools/build.sh` as above. See `.devcontainer/postCreate.sh`
for exact download locations of every tool.

## Verify after installing

1. App opens, Log screen shows `KMBUILD <your-tag>` → correct build running.
2. Normal taps still fire; sustained holds work in games
   (remember to turn OFF the system three-finger gesture).
3. Stop from the notification → notification gone, service stays stopped.

## License / origin

- Original app: [Key Mapper](https://github.com/sds100/KeyMapper) by [sds100](https://github.com/sds100) (GPL-3.0). Patches here are released under GPL-3.0.
- No APK and no signing keys are included — everyone builds with their own key.
- Native libs (`lib/arm64-v8a/*.so`) are **not** in the Play APK, so the script
  downloads the [official FOSS 4.3.1 release](https://github.com/keymapperorg/KeyMapper/releases/tag/v4.3.1) and takes them from there
  (checksum-verified).
