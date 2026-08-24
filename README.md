# LiquiLens Dev Container Features

[![CI](https://github.com/beepboop2025/liquilens-devcontainer-features/actions/workflows/ci.yml/badge.svg)](https://github.com/beepboop2025/liquilens-devcontainer-features/actions/workflows/ci.yml)

Public, community-authored Dev Container Features for bounded LiquiLens tooling.

## LiquiLens Evidence Carrier

The **liquilens-evidence** Feature installs the offline LiquiLens Evidence
Carrier verifier and its read-only MCP stdio server into a development
container. It exposes:

- **liquilens-evidence** — issue, verify, and project local carrier JSON.
- **liquilens-evidence-mcp** — inspect and project local carrier JSON over
  stdio MCP.

Add it to **.devcontainer/devcontainer.json**:

    {
      "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
      "features": {
        "ghcr.io/beepboop2025/liquilens-devcontainer-features/liquilens-evidence:1": {}
      }
    }

Then rebuild the container and run:

    liquilens-evidence --help
    liquilens-evidence-mcp --version

For an MCP client, use **liquilens-evidence-mcp** as the command and pass
**--root /path/to/allowed/carriers** when the carrier root should be narrower
than the process working directory.

## Reproducible installation

Feature version 1.0.0 installs only this immutable upstream wheel:

| Component | Value |
| --- | --- |
| Carrier release | 0.14.0 |
| Wheel | https://github.com/beepboop2025/liquilens-evidence-carrier/releases/download/v0.14.0/liquilens_evidence-0.14.0-py3-none-any.whl |
| SHA-256 | f0162affab57307c8e20acf91dcefc33840f91e8cf9969a8d5ec8d8df860cd24 |
| Runtime dependencies | None |

The installer downloads that one HTTPS artifact, rejects redirects to
non-HTTPS destinations, enforces a size ceiling, verifies SHA-256 before
installation, and installs with **--no-index --no-deps** into
**/opt/liquilens-evidence**. The public commands are root-owned and executable
by non-root container users.

## Evidence boundary

The installed runtime is offline and fail-closed. It does not collect payloads,
fetch market data, emit telemetry, recommend securities, rate credit, execute
trades, or claim financial authority. It reads only files explicitly supplied
to the CLI or files below the MCP server's configured root. Upstream source
rights and carrier export dispositions remain authoritative.

The network is used only during Feature installation to retrieve the pinned
public wheel and any declared Dev Container dependency. No credential is
required to pull the published Feature.

## Development

The repository follows the official Dev Container Feature layout. Local static
validation does not need Docker:

    bash scripts/validate-static.sh
    npx --yes @devcontainers/cli@0.88.0 features package src --output-folder /tmp/liquilens-feature-package --force-clean-output-folder

Full root and non-root installation tests run in GitHub Actions using the
official Dev Container CLI.

## License and project status

Apache-2.0. This is an independent community Feature. Publication on GHCR or
inclusion in a community index does not imply endorsement by Microsoft,
GitHub, Visual Studio Code, GitHub Codespaces, or the Dev Containers
maintainers.
