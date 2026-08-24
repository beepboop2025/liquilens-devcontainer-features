#!/bin/bash
# shellcheck disable=SC1091,SC2016
set -euo pipefail

source dev-container-features-test-lib

check "CLI is on PATH" command -v liquilens-evidence
check "MCP server is on PATH" command -v liquilens-evidence-mcp
check "carrier version" bash -c 'test "$(liquilens-evidence-mcp --version)" = "0.14.0"'
check "CLI help" bash -c 'liquilens-evidence --help | grep -F "verify carrier identity and policy"'
check "root-owned CLI" bash -c 'test "$(stat -c %u /opt/liquilens-evidence/bin/liquilens-evidence)" = "0"'
check "MCP initialize and list" python3 - <<'PY'
import json
import subprocess

messages = [
    {
        "jsonrpc": "2.0",
        "id": "init",
        "method": "initialize",
        "params": {
            "protocolVersion": "2025-11-25",
            "capabilities": {},
            "clientInfo": {"name": "devcontainer-test", "version": "1.0.0"},
        },
    },
    {
        "jsonrpc": "2.0",
        "method": "notifications/initialized",
        "params": {},
    },
    {"jsonrpc": "2.0", "id": "tools", "method": "tools/list", "params": {}},
]
result = subprocess.run(
    ["liquilens-evidence-mcp", "--root", "."],
    input="".join(json.dumps(item) + "\n" for item in messages),
    text=True,
    capture_output=True,
    timeout=10,
    check=True,
)
responses = [json.loads(line) for line in result.stdout.splitlines()]
assert len(responses) == 2, responses
assert responses[0]["result"]["protocolVersion"] == "2025-11-25"
assert responses[0]["result"]["serverInfo"]["version"] == "0.14.0"
tools = responses[1]["result"]["tools"]
assert [tool["name"] for tool in tools] == ["verify_carrier", "project_carrier"]
assert all(tool["annotations"]["readOnlyHint"] for tool in tools)
assert all(not tool["annotations"]["openWorldHint"] for tool in tools)
PY

reportResults
