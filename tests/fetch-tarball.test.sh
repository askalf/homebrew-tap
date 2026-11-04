#!/usr/bin/env bash
# fetch-tarball.sh against a local server that answers 404 for its first N requests, then the bytes.
# A fresh release's 404 is retried through to the right bytes, a tarball that never appears fails
# (which stops bump-dario.sh before the formula is rewritten: set -e), and the old options, which
# do not retry a 404, fail the same transient case. brew style lints this file: Homebrew's shell style.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
pid=""
trap '[ -z "${pid}" ] || kill "${pid}" 2>/dev/null || true; rm -rf "${work}"' EXIT
export FETCH_RETRY_DELAY=1

node "${root}/tests/fetch-tarball-server.js" "${work}" &
pid=$!
for _ in {1..50}
do
  [[ -s "${work}/port" ]] && break
  sleep 0.1
done
port="$(cat "${work}/port")"
base="http://127.0.0.1:${port}"

# A 404 that clears: retried through to the right bytes.
bash "${root}/scripts/fetch-tarball.sh" "${base}/2/fresh.tgz" "${work}/fresh.tgz"
fetched="$(cat "${work}/fresh.tgz")"
[[ "${fetched}" == tarball-bytes ]]

# A tarball that never appears: the tries run out and the script fails.
if bash "${root}/scripts/fetch-tarball.sh" "${base}/99/never.tgz" "${work}/never.tgz" 2>/dev/null
then
  echo "a missing tarball should fail" >&2
  exit 1
fi

# The old options fail the transient case: this is the failure the script exists for.
if curl -fsSL --retry 3 --retry-delay 1 -o "${work}/old.tgz" "${base}/2/old.tgz" 2>/dev/null
then
  echo "plain --retry should not retry a 404" >&2
  exit 1
fi

echo "fetch-tarball: ok"
