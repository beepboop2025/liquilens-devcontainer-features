# Contributing

Changes must arrive through a pull request and pass the protected CI checks.
Keep external actions pinned to full commit SHAs and all downloaded release
artifacts pinned by cryptographic digest.

Do not add telemetry, market-data fetching, credentials, financial
recommendations, execution authority, or payload upload behavior. Tests must
cover both a root installation and execution by a non-root container user.
