# Muse (`com.facebook.aura`) — static recon

Target build: **18.0.0.8.161** (versionCode 1062301896), package `com.facebook.aura`.
APK SHA-256: `f2f9acb0dc0d8cc60d2322e3de6f02a0fb9b74c8b07eecb7d34c92c6ae5a51d3`

## Contents

| file | what |
|---|---|
| `RECON.md` | Full write-up: settings screen, session/token storage, multi-account paths, per-DEX package map, smali excerpts |
| `smali_selected_part1.zip` … `part7.zip` | Selected apktool smali (`com/facebook/**`, `X/**`, `com/meta/**`, `com/instagram/**`), split so each part is < 35 MB |
| `apk.sha256` | Hash of the analysed APK |

## The archives

They are **one tree split by DEX**, not separate projects. Unzip all seven into the same
directory (an `apktool_out/` root) and the original layout is restored:

```
smali/            smali_classes2/  …  smali_classes7/
```

Only these were kept: `com/facebook/**`, `X/**` (obfuscated top-level), `com/meta/**`,
`com/instagram/**`. Framework/library code (`androidx/`, `kotlin/`, `okhttp3/`, `org/`, …)
and `secondary/` (Redex `Canary` stubs) are omitted.

The APK itself is **not** included and was never modified — extract it from your own copy
of the build and compare against `apk.sha256`.

## Tooling

apktool 3.0.3 · jadx 1.5.1 · OpenJDK 21.0.13.1
