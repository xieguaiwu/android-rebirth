#!/usr/bin/env bash
# Builds the Go core (cmd/mobile) into android/app/src/main/jniLibs/arm64-v8a/.
#
# ABI scope: arm64-v8a ONLY. Verified with Go 1.25 (official + distro
# toolchains): android/amd64, android/arm and android/386 all require cgo
# (external linking) since Go 1.24/1.25; arm64 is the sole pure-Go target.
# cgo + NDK would break F-Droid reproducibility, so 32-bit and x86_64
# variants are intentionally not shipped (arm64 covers ~all current devices).
#
# F-Droid reproducibility: fixed Go toolchain (fetch-go.sh) + -trimpath +
# -buildvcs=false make the ELF byte-reproducible.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$REPO_ROOT/app/src/main/jniLibs"

# Ensure a Go toolchain is present: sourcing fetch-go.sh keeps its exports
# (GOROOT/PATH) in THIS shell. On the F-Droid buildserver (no Go installed)
# this downloads the pinned toolchain; locally it is a no-op when Go is
# already in PATH.
# shellcheck source=fetch-go.sh
source "$(dirname "${BASH_SOURCE[0]}")/fetch-go.sh"

cd "$REPO_ROOT"

out="$OUT_DIR/arm64-v8a/librebirth_core.so"
mkdir -p "$(dirname "$out")"
echo "==> building arm64-v8a -> $out"
# The Go core is vendored at core/ (module rebirth); see scripts/sync-core.sh.
cd "$REPO_ROOT/core"
GOOS=android GOARCH=arm64 CGO_ENABLED=0 GOFLAGS="-trimpath" \
  go build -buildvcs=false -ldflags="-s -w" -o "$out" ./cmd/mobile
cd "$REPO_ROOT"

ls -l "$out"
# Sanity-check the artifact: ELF magic via coreutils od(1). The F-Droid
# build server does not ship file(1), which made the build fail here even
# though the cross-compile itself had succeeded.
magic="$(od -An -N4 -tx1 "$out" | tr -d ' \n')"
if [ "$magic" != "7f454c46" ]; then
  echo "ERROR: $out is not an ELF file" >&2
  exit 1
fi
echo "OK: arm64 core built."
