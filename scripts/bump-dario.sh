#!/usr/bin/env bash
# Rewrite Formula/dario.rb to the latest @askalf/dario on the npm registry.
# Prints "changed=<version>" when the formula moved and "changed=" when it did not,
# so the workflow can decide whether there is anything to test and commit, and
# "latest=<version>" on every run, so the workflow can close pull requests for any other version.
set -euo pipefail

formula="Formula/dario.rb"
latest="$(npm view @askalf/dario version)"
current="$(sed -nE 's#.*dario-([0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?)\.tgz.*#\1#p' "${formula}" | head -1)"

if [[ -z "${latest}" ]] || [[ -z "${current}" ]]
then
  echo "could not read versions (latest='${latest}', current='${current}')" >&2
  exit 1
fi
echo "latest=${latest}" >>"${GITHUB_OUTPUT:-/dev/null}"
if [[ "${latest}" == "${current}" ]]
then
  echo "formula already at ${current}"
  echo "changed=" >>"${GITHUB_OUTPUT:-/dev/null}"
  exit 0
fi

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
url="https://registry.npmjs.org/@askalf/dario/-/dario-${latest}.tgz"
curl -fsSL --retry 3 -o "${work}/dario.tgz" "${url}"

# The registry publishes a sha512 integrity string; the downloaded bytes must match it
# before any digest of them goes into the formula.
expected="$(npm view "@askalf/dario@${latest}" dist.integrity)"
actual="sha512-$(openssl dgst -sha512 -binary "${work}/dario.tgz" | base64 | tr -d '\n')"
if [[ "${expected}" != "${actual}" ]]
then
  echo "integrity mismatch for ${url}" >&2
  echo "  registry: ${expected}" >&2
  echo "  download: ${actual}" >&2
  exit 1
fi
# Integrity only proves the bytes are what the registry serves. Provenance proves the registry
# got them from dario's release workflow, so a release published any other way is never tapped.
bash scripts/verify-dario-provenance.sh "${latest}" "${work}/dario.tgz"
sha256="$(openssl dgst -sha256 "${work}/dario.tgz" | sed 's/^.*= //')"

sed -i.bak -E \
  -e "s#dario-${current}\.tgz#dario-${latest}.tgz#" \
  -e "s#sha256 \"[0-9a-f]{64}\"#sha256 \"${sha256}\"#" \
  "${formula}"
rm -f "${formula}.bak"

grep -q "dario-${latest}.tgz" "${formula}"
grep -q "sha256 \"${sha256}\"" "${formula}"
echo "formula ${current} -> ${latest} (sha256 ${sha256})"
echo "changed=${latest}" >>"${GITHUB_OUTPUT:-/dev/null}"
