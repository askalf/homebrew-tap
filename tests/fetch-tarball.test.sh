#!/usr/bin/env bash
# fetch-tarball.sh against a local server that answers 404 for its first N requests, then the bytes.
# A fresh release's 404 is retried through to the right bytes, a tarball that never appears fails
# (which stops bump-dario.sh before the formula is rewritten: set -e), and the old options, which
# do not retry a 404, fail the same transient case.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
pid=""
trap '[ -z "${pid}" ] || kill "${pid}" 2>/dev/null || true; rm -rf "${work}"' EXIT
export FETCH_RETRY_DELAY=1

cat > "${work}/server.js" <<'JS'
const http = require('http');
const fs = require('fs');
const dir = process.argv[2];
http.createServer((req, res) => {
  // /<n>/<name>: 404 for the first n requests of that path, then the tarball's bytes.
  const n = Number(req.url.split('/')[1]);
  seen[req.url] = (seen[req.url] || 0) + 1;
  if (seen[req.url] <= n) { res.statusCode = 404; res.end('not yet'); return; }
  res.end('tarball-bytes');
}).listen(0, '127.0.0.1', function () { fs.writeFileSync(`${dir}/port`, String(this.address().port)); });
const seen = {};
JS
node "${work}/server.js" "${work}" &
pid=$!
for _ in $(seq 1 50); do [ -s "${work}/port" ] && break; sleep 0.1; done
base="http://127.0.0.1:$(cat "${work}/port")"

# A 404 that clears: retried through to the right bytes.
bash "${root}/scripts/fetch-tarball.sh" "${base}/2/fresh.tgz" "${work}/fresh.tgz"
[ "$(cat "${work}/fresh.tgz")" = tarball-bytes ]

# A tarball that never appears: the tries run out and the script fails.
if bash "${root}/scripts/fetch-tarball.sh" "${base}/99/never.tgz" "${work}/never.tgz" 2>/dev/null; then
  echo "a missing tarball should fail" >&2
  exit 1
fi

# The old options fail the transient case: this is the failure the script exists for.
if curl -fsSL --retry 3 --retry-delay 1 -o "${work}/old.tgz" "${base}/2/old.tgz" 2>/dev/null; then
  echo "plain --retry should not retry a 404" >&2
  exit 1
fi

echo "fetch-tarball: ok"
