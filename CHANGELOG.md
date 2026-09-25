## [0.10.2] - 2026-09-25

### Fixed (F-Droid build-server compatibility)

- **`scripts/build-core.sh`**: the post-build sanity check used `file(1)`,
  which the F-Droid build server does not ship — the build died after the
  Go core had already been produced. The check now verifies the ELF magic
  with `od(1)` (coreutils).
- **`scripts/fetch-go.sh`**: the pinned-toolchain cache (`.go-cache/`) is
  anchored to the repository root via this script's location instead of
  the caller's working directory. `prebuild` and `build` now share one
  cache when the F-Droid metadata runs them from the `app/` subdir.

No user-visible changes.

## [0.10.1] - 2026-09-09

### Security (2026-09-09)

- **HTTPS enforcement for LLM endpoints (Go core)**: `usesCleartextTraffic=false`
  in the manifest covers only the platform network stack — the Go binary's
  `http.Client` was unaffected. A custom provider URL with `http://` sent the
  API key as a cleartext `Authorization` header. `llm.Client.complete` now
  fails closed on non-https base URLs; loopback http stays allowed for local
  proxies. Upstream rebirth commit `40673d9`, vendored at `core/`.
- **Log redaction hardened (Android)**: `CoreProcess.redact` now also masks
  JSON-form `"key":"..."` fields, so custom provider keys without a vendor
  prefix (`sk-`/`nvapi-`) can never reach logcat.

### Changed

- **Dark theme is now unconditional**: `RebirthTheme` no longer reads
  `isSystemInDarkTheme()` (no light palette exists). The terminal/CRT theme
  renders dark regardless of the OS setting; the XML window background
  (`Theme.Rebirth` on `android:Theme.Material.NoActionBar`) keeps the launch
  frame dark, so there is no startup flash in either mode.

## [0.10.0] - 2026-08-25

### Added: standalone Android repository

First release of the standalone Android repo, migrated from the
`android/` subdirectory of github.com/xieguaiwu/rebirth (v0.10.0, single
source of truth for the Go engine remains the rebirth repo — vendored
here at `core/`, refresh via `scripts/sync-core.sh`).

- Compose UI: Home / Create / Timeline / Trauma panel / Settings
- Core-process bridge: execs the Go engine (`librebirth_core.so`, arm64),
  JSON-lines protocol (docs/mobile-protocol.md), 30 s timeouts, crash
  restart with deterministic checkpoint replay
- Multi-provider LLM chain: any number of providers (DeepSeek, OpenRouter,
  OpenAI-compatible), ordered failover, per-provider circuit breakers,
  shared budget; zero providers = fully offline
- Bilingual UI + content (Chinese/English), in-app switch
- Keys encrypted in Android Keystore (AES-GCM envelope), never on disk
- Yearly checkpoints: kill the app, reopen, resume the exact same life
- F-Droid prep: fastlane metadata (en-US + zh-CN), pinned Go toolchain
  fetch with SHA-256, reproducible-build verification (two clean builds →
  identical unsigned APK hashes), fdroiddata draft in docs/fdroiddata.yml
