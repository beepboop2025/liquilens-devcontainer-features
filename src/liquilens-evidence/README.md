# LiquiLens Evidence Carrier

Installs LiquiLens Evidence Carrier 0.14.0 as two root-owned commands available
to every container user:

- **liquilens-evidence**
- **liquilens-evidence-mcp**

## Usage

    {
      "features": {
        "ghcr.io/beepboop2025/liquilens-devcontainer-features/liquilens-evidence:1": {}
      }
    }

The Feature depends on the official Python Feature configured for Python 3.11.
The LiquiLens package itself has zero third-party runtime dependencies.

The release wheel is pinned to SHA-256
**f0162affab57307c8e20acf91dcefc33840f91e8cf9969a8d5ec8d8df860cd24**.
Installation fails before executing package code if the retrieved bytes do not
match.

## MCP boundary

Run:

    liquilens-evidence-mcp --root /workspace/carriers

The server communicates over stdio and reads only explicit JSON paths within
the configured root. It exposes read-only verification and projection tools
and protocol resources. It performs no network retrieval, payload collection,
telemetry, financial recommendation, rating, or execution.

This independent community Feature is not a Microsoft, GitHub, Visual Studio
Code, Codespaces, or Dev Containers endorsement.
