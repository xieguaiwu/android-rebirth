#!/usr/bin/env bash
# Downloads a pinned Go toolchain (official tarball, SHA-256 verified) for
# the F-Droid build server, which does not ship Go. Idempotent: caches the
# tarball under $ANDROID_BUILD_TOP or the repository root (anchored to this
# script's location, so the same cache is found regardless of the caller's
# working directory — the F-Droid metadata runs it from the app/ subdir).
#
# Usage: fetch-go.sh [version]   (default 1.25.10 — pin when bumping!)
# Exports GOROOT and prepends $GOROOT/bin to PATH in the calling shell.
set -euo pipefail

VERSION="${1:-1.25.10}"
TARBALL="go${VERSION}.linux-amd64.tar.gz"
# SHA-256 of the official release tarball. Source of truth: https://go.dev/dl/?mode=json
# (verified 2026-09-06 against the official JSON API).
#
# The pin is keyed by VERSION: an unknown version has NO hash and therefore
# aborts rather than silently building an untrusted toolchain. Passing
# GO_TARBALL_SHA256=... overrides (used when bumping VERSION).
PINNED_SHA256_1_25_10="42d4f7a32316aa66591eca7e89867256057a4264451aca10570a715b3637ba70"
case "$VERSION" in
  1.25.10) PINNED_SHA256="$PINNED_SHA256_1_25_10" ;;
  *)       PINNED_SHA256="" ;;
esac
# Verify by default. Set GO_TARBALL_SHA256 to override; there is no longer a
# "skip verification" path — an unpinned version without an explicit hash fails.
SHA256="${GO_TARBALL_SHA256-$PINNED_SHA256}"
if [ -z "$SHA256" ]; then
  echo "ERROR: no SHA-256 pinned for Go $VERSION." >&2
  echo "       Set GO_TARBALL_SHA256=<sha256> (from https://go.dev/dl/?mode=json)." >&2
  exit 1
fi

# Repository root = parent of this script's directory. Anchoring there
# (instead of $PWD) keeps one shared cache when invoked from a subdirectory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${ANDROID_BUILD_TOP:-$(dirname "$SCRIPT_DIR")}/.go-cache"
DEST_DIR="$CACHE_DIR/go-$VERSION"
mkdir -p "$CACHE_DIR"

if [ ! -x "$DEST_DIR/bin/go" ]; then
  echo "==> downloading Go $VERSION"
  curl -fsSL --retry 3 -o "$CACHE_DIR/$TARBALL" "https://go.dev/dl/$TARBALL"
  if [ -n "$SHA256" ]; then
    echo "$SHA256  $CACHE_DIR/$TARBALL" | sha256sum -c -
  fi
  tar -C "$CACHE_DIR" -xzf "$CACHE_DIR/$TARBALL"
  mv "$CACHE_DIR/go" "$DEST_DIR"
  rm -f "$CACHE_DIR/$TARBALL"
fi

export GOROOT="$DEST_DIR"
export PATH="$DEST_DIR/bin:$PATH"
echo "==> Go $(go version) at $GOROOT"
