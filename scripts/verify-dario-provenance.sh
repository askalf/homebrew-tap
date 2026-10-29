#!/usr/bin/env bash
# Verify that a @askalf/dario tarball was built by dario's own release workflow.
# Usage: verify-dario-provenance.sh <version> <tarball>
# The npm registry keeps a signed SLSA provenance attestation for every release. This checks its
# Sigstore signature, that its subject is the sha512 of these exact bytes, and that the signer is
# the workflow below on dario's master branch, run on a GitHub-hosted runner. A release published
# to npm by any other route fails here. If dario moves its release to another workflow or branch,
# change the values below; until then the bump fails closed.
set -euo pipefail

repo="askalf/dario"
signer_workflow="askalf/dario/.github/workflows/cc-drift-auto-release.yml"
source_ref="refs/heads/master"

version="${1:-}"
tarball="${2:-}"
if [[ -z "${version}" ]] || [[ ! -f "${tarball}" ]]
then
  echo "usage: verify-dario-provenance.sh <version> <tarball>" >&2
  exit 2
fi

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

curl -fsSL --retry 3 -o "${work}/attestations.json" \
  "https://registry.npmjs.org/-/npm/v1/attestations/@askalf%2fdario@${version}"
jq -c '.attestations[] | select(.predicateType == "https://slsa.dev/provenance/v1") | .bundle' \
  "${work}/attestations.json" >"${work}/provenance.jsonl"
if [[ ! -s "${work}/provenance.jsonl" ]]
then
  echo "no SLSA provenance attestation for @askalf/dario@${version}" >&2
  exit 1
fi

gh attestation verify "${tarball}" \
  --bundle "${work}/provenance.jsonl" \
  --digest-alg sha512 \
  --repo "${repo}" \
  --signer-workflow "${signer_workflow}" \
  --source-ref "${source_ref}" \
  --deny-self-hosted-runners
echo "provenance verified: @askalf/dario@${version} from ${signer_workflow} on ${source_ref}"
