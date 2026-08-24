# Security

## Supported versions

Only the newest published major version of each Feature is supported.

## Reporting

Report a suspected vulnerability privately through this repository's GitHub
Security Advisory interface. Do not attach financial evidence payloads,
credentials, private carrier files, or proprietary market data to a public
issue.

## Supply-chain boundary

The **liquilens-evidence** installer accepts exactly one upstream release wheel
and verifies its fixed SHA-256 before installation. A checksum mismatch, an
oversized response, an unsupported Python runtime, or a non-HTTPS redirect is
a hard installation failure.
