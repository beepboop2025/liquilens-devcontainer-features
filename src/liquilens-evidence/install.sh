#!/bin/sh
set -eu

umask 022

FEATURE_VERSION="1.0.0"
CARRIER_VERSION="0.14.0"
WHEEL_URL="https://github.com/beepboop2025/liquilens-evidence-carrier/releases/download/v0.14.0/liquilens_evidence-0.14.0-py3-none-any.whl"
WHEEL_SHA256="f0162affab57307c8e20acf91dcefc33840f91e8cf9969a8d5ec8d8df860cd24"
INSTALL_DIR="/opt/liquilens-evidence"

find_python() {
    for candidate in \
        /usr/local/python/current/bin/python3 \
        /usr/local/bin/python3 \
        /usr/bin/python3
    do
        if [ -x "$candidate" ] && "$candidate" -c \
            'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)'
        then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    if command -v python3 >/dev/null 2>&1; then
        candidate="$(command -v python3)"
        if "$candidate" -c \
            'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)'
        then
            printf '%s\n' "$candidate"
            return 0
        fi
    fi
    return 1
}

PYTHON_BIN="$(find_python || true)"
if [ -z "$PYTHON_BIN" ]; then
    echo "liquilens-evidence: Python 3.11 or newer is required" >&2
    exit 1
fi

DOWNLOAD_DIR="$(mktemp -d /tmp/liquilens-evidence-feature.XXXXXX)"
STAGED_DIR="${INSTALL_DIR}.staged.$$"
BACKUP_DIR="${INSTALL_DIR}.previous.$$"
WHEEL_PATH="${DOWNLOAD_DIR}/liquilens_evidence-${CARRIER_VERSION}-py3-none-any.whl"

cleanup() {
    rm -rf -- "$DOWNLOAD_DIR" "$STAGED_DIR"
}
trap cleanup EXIT HUP INT TERM

"$PYTHON_BIN" - \
    "$WHEEL_PATH" "$WHEEL_URL" "$WHEEL_SHA256" "$FEATURE_VERSION" <<'PY'
from __future__ import annotations

import hashlib
import os
import sys
import urllib.request
from pathlib import Path

MAX_BYTES = 10 * 1024 * 1024

destination = Path(sys.argv[1])
wheel_url, expected_sha, feature_version = sys.argv[2:]
request = urllib.request.Request(
    wheel_url,
    headers={"User-Agent": f"liquilens-devcontainer-feature/{feature_version}"},
)
hasher = hashlib.sha256()
size = 0

with urllib.request.urlopen(request, timeout=60) as response:
    resolved = response.geturl()
    if not resolved.startswith("https://"):
        raise SystemExit("liquilens-evidence: release redirect was not HTTPS")
    with destination.open("xb") as output:
        while chunk := response.read(64 * 1024):
            size += len(chunk)
            if size > MAX_BYTES:
                raise SystemExit("liquilens-evidence: release wheel exceeded size limit")
            hasher.update(chunk)
            output.write(chunk)

actual = hasher.hexdigest()
if actual != expected_sha:
    destination.unlink(missing_ok=True)
    raise SystemExit(
        "liquilens-evidence: wheel SHA-256 mismatch "
        f"(expected {expected_sha}, got {actual})"
    )
os.chmod(destination, 0o444)
print(f"Verified LiquiLens Evidence Carrier wheel: sha256:{actual}")
PY

if [ -e "$STAGED_DIR" ] || [ -e "$BACKUP_DIR" ]; then
    echo "liquilens-evidence: unexpected staged installation path exists" >&2
    exit 1
fi

"$PYTHON_BIN" -m venv "$STAGED_DIR"
PIP_DISABLE_PIP_VERSION_CHECK=1 PIP_NO_CACHE_DIR=1 \
    "$STAGED_DIR/bin/python" -m pip install \
    --no-index --no-deps "$WHEEL_PATH"

"$STAGED_DIR/bin/python" - "$FEATURE_VERSION" "$CARRIER_VERSION" <<'PY'
from importlib.metadata import entry_points, version
import sys

feature_version, expected = sys.argv[1:]
actual = version("liquilens-evidence")
if actual != expected:
    raise SystemExit(
        f"liquilens-evidence: installed {actual}, expected {expected}"
    )
commands = {item.name for item in entry_points(group="console_scripts")}
required = {"liquilens-evidence", "liquilens-evidence-mcp"}
if not required <= commands:
    raise SystemExit(
        "liquilens-evidence: installed package is missing required commands"
    )
print(
    f"Prepared LiquiLens Evidence Carrier {actual} "
    f"from Dev Container Feature {feature_version}"
)
PY

chmod -R a+rX "$STAGED_DIR"
if [ -e "$INSTALL_DIR" ]; then
    if [ ! -f "$INSTALL_DIR/pyvenv.cfg" ]; then
        echo "liquilens-evidence: refusing to replace non-venv path $INSTALL_DIR" >&2
        exit 1
    fi
    mv -- "$INSTALL_DIR" "$BACKUP_DIR"
fi
mv -- "$STAGED_DIR" "$INSTALL_DIR"
rm -rf -- "$BACKUP_DIR"

ln -sfn "$INSTALL_DIR/bin/liquilens-evidence" /usr/local/bin/liquilens-evidence
ln -sfn "$INSTALL_DIR/bin/liquilens-evidence-mcp" /usr/local/bin/liquilens-evidence-mcp

"$INSTALL_DIR/bin/liquilens-evidence" --help >/dev/null
test "$("$INSTALL_DIR/bin/liquilens-evidence-mcp" --version)" = "$CARRIER_VERSION"

echo "Installed LiquiLens Evidence Carrier $CARRIER_VERSION"
echo "Runtime boundary: offline, read-only evidence verification; no telemetry or financial authority."
