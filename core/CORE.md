# Vendored Go core

The simulation engine (`cmd/mobile` daemon + `internal/` packages, module
`rebirth`) is vendored here from the canonical repo
https://github.com/xieguaiwu/rebirth so this repository builds
self-contained on the F-Droid buildserver (no cross-repo checkout).

- Source commit: `fd9f588b4719d197faceb088201c0eb64d553437` (see CORE_SOURCE_COMMIT)
- Refresh: `bash scripts/sync-core.sh` (needs the rebirth repo checked out
  locally, or pass a path: `bash scripts/sync-core.sh /path/to/rebirth`)
- Protocol contract: docs/mobile-protocol.md (frozen; both sides reference it)
