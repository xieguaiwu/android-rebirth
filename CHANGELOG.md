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
