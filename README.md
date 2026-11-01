# homebrew-tap

The Homebrew tap for [KaaS Factory](https://github.com/KaaS-team/KaaS-factory).

## Install

```sh
brew install KaaS-team/tap/factory
```

The formula points at the binaries and `SHA256SUMS` of a [KaaS-factory release](https://github.com/KaaS-team/KaaS-factory/releases). Without Homebrew, use the [curl or npm installer](https://github.com/KaaS-team/factory-install).

## Updating the formula

```sh
sh scripts/bump-formula.sh v6.2.0   # rewrites Formula/factory.rb from that release's SHA256SUMS
sh tests/formula-check.sh           # checks URLs, checksums and idempotency
```

An auto-bump workflow is drafted in [docs/auto-bump-workflow.yml.txt](docs/auto-bump-workflow.yml.txt). It is not active yet.

## Part of KaaS

More at [kaas.team](https://kaas.team). Licensed Apache-2.0.
