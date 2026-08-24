#!/bin/bash
# shellcheck disable=SC1091,SC2016
set -euo pipefail

source dev-container-features-test-lib

check "test executes as non-root" bash -c 'test "$(id -u)" != "0"'
check "non-root CLI" liquilens-evidence --help
check "non-root MCP executable" bash -c 'test "$(liquilens-evidence-mcp --version)" = "0.14.0"'
check "installation is not user-writable" bash -c 'test ! -w /opt/liquilens-evidence/pyvenv.cfg'
check "public command is not user-writable" bash -c 'test ! -w /usr/local/bin/liquilens-evidence'
check "non-root MCP initialize" python3 - <<'PY'
import json
import subprocess

request = {
    "jsonrpc": "2.0",
    "id": "init",
    "method": "initialize",
    "params": {
        "protocolVersion": "2025-11-25",
        "capabilities": {},
        "clientInfo": {"name": "non-root-test", "version": "1.0.0"},
    },
}
result = subprocess.run(
    ["liquilens-evidence-mcp", "--root", "."],
    input=json.dumps(request) + "\n",
    text=True,
    capture_output=True,
    timeout=10,
    check=True,
)
response = json.loads(result.stdout)
assert response["result"]["serverInfo"]["name"] == (
    "io.github.beepboop2025/liquilens-evidence-carrier"
)
PY

reportResults
