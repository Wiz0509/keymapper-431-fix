#!/usr/bin/env python3
"""Repack: swap classes*.dex into a copy of the original APK,
preserving every other entry byte-for-byte, plus native libs from FOSS APK.
SPDX-License-Identifier: GPL-3.0-or-later"""
import argparse
import zipfile

p = argparse.ArgumentParser()
p.add_argument("--orig", required=True)
p.add_argument("--dex1", required=True)
p.add_argument("--dex2", required=True)
p.add_argument("--dex3", required=True)
p.add_argument("--native-apk", required=True,
               help="FOSS APK to take lib/arm64-v8a/*.so from (Play APK has none)")
p.add_argument("--out", required=True)
a = p.parse_args()

zin = zipfile.ZipFile(a.orig)
items = {}
for n in zin.namelist():
    items[n] = (zin.read(n), zin.getinfo(n).compress_type)

with open(a.dex1, "rb") as f:
    items["classes.dex"] = (f.read(), items["classes.dex"][1])
with open(a.dex2, "rb") as f:
    items["classes2.dex"] = (f.read(), items["classes2.dex"][1])
with open(a.dex3, "rb") as f:
    items["classes3.dex"] = (f.read(), items["classes3.dex"][1])

import os
nz = zipfile.ZipFile(a.native_apk)
for n in nz.namelist():
    if n.startswith("lib/arm64-v8a/") and n.endswith(".so"):
        # STORED (uncompressed), like the device loader expects
        items[n] = (nz.read(n), zipfile.ZIP_STORED)

z = zipfile.ZipFile(a.out, "w")
for n, (d, c) in items.items():
    zi = zipfile.ZipInfo(n)
    zi.compress_type = c
    zi.external_attr = 0o644 << 16
    z.writestr(zi, d)
z.close()
print("entries", len(items))
