#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

jq -e '
  .id == "liquilens-evidence"
  and .version == "1.0.0"
  and .dependsOn["ghcr.io/devcontainers/features/python:1"].version == "3.11"
  and .dependsOn["ghcr.io/devcontainers/features/python:1"].installTools == false
' src/liquilens-evidence/devcontainer-feature.json >/dev/null

bash -n src/liquilens-evidence/install.sh
bash -n test/liquilens-evidence/test.sh
bash -n test/liquilens-evidence/non_root.sh
shellcheck \
  src/liquilens-evidence/install.sh \
  test/liquilens-evidence/test.sh \
  test/liquilens-evidence/non_root.sh \
  scripts/validate-static.sh

grep -Fq \
  'https://github.com/beepboop2025/liquilens-evidence-carrier/releases/download/v0.14.0/liquilens_evidence-0.14.0-py3-none-any.whl' \
  src/liquilens-evidence/install.sh
grep -Fq \
  'f0162affab57307c8e20acf91dcefc33840f91e8cf9969a8d5ec8d8df860cd24' \
  src/liquilens-evidence/install.sh
grep -Fq -- '--no-index --no-deps' src/liquilens-evidence/install.sh

while IFS= read -r use; do
    ref="${use##*@}"
    if ! [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
        echo "Action is not pinned to a full commit SHA: $use" >&2
        exit 1
    fi
done < <(grep -RhoE 'uses:[[:space:]]+[^[:space:]]+' .github/workflows)

echo "Static validation passed."
