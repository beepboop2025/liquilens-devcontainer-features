#!/bin/bash
set -euo pipefail

test "$(id -u)" != "0"
test "$(liquilens-evidence-mcp --version)" = "0.14.0"
liquilens-evidence --help | grep -F "verify carrier identity and policy"
test ! -w /opt/liquilens-evidence/pyvenv.cfg

python3 - <<'PY'
import json
import subprocess

requests = [
    {
        "jsonrpc": "2.0",
        "id": "init",
        "method": "initialize",
        "params": {
            "protocolVersion": "2025-11-25",
            "capabilities": {},
            "clientInfo": {"name": "anonymous-consumer", "version": "1.0.0"},
        },
    },
    {
        "jsonrpc": "2.0",
        "method": "notifications/initialized",
        "params": {},
    },
    {"jsonrpc": "2.0", "id": "resources", "method": "resources/list", "params": {}},
]
result = subprocess.run(
    ["liquilens-evidence-mcp", "--root", "."],
    input="".join(json.dumps(item) + "\n" for item in requests),
    text=True,
    capture_output=True,
    timeout=10,
    check=True,
)
responses = [json.loads(line) for line in result.stdout.splitlines()]
assert len(responses) == 2, responses
assert responses[0]["result"]["serverInfo"]["version"] == "0.14.0"
assert len(responses[1]["result"]["resources"]) == 3
print("Anonymous consumer verified CLI, MCP, and non-root execution.")
PY
