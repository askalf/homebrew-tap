#!/usr/bin/env bash
# Download a release tarball: fetch-tarball.sh <url> <file>. The release dispatch can land before the
# registry serves the tarball, and plain --retry does not retry a 404 (the bump went red 11 seconds
# after dario 6.20.3 published), so every error is retried, spaced out: about a minute in all.
# FETCH_RETRY_DELAY sets the seconds between tries; the test shortens it.
set -euo pipefail

curl -fsSL --retry 6 --retry-all-errors --retry-delay "${FETCH_RETRY_DELAY:-10}" -o "$2" "$1"
