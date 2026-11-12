# homebrew-tap

This repo is the Homebrew tap for the `factory` command line of [KaaS Factory](https://github.com/KaaS-team/KaaS-factory). It is for people who install the factory with Homebrew, and for maintainers who update the formula when a release ships.

Status: the formula still installs the old Bun/TypeScript factory, release v6.2.0 (binaries named `factory-<os>-<arch>`). It has not been moved to the Go rewrite, whose release archives are named differently, so `scripts/bump-formula.sh` would need changes first.

## Install

```sh
brew install KaaS-team/tap/factory
```

The formula downloads one binary for your platform (macOS or Linux, arm64 or x64) from the [KaaS-factory releases](https://github.com/KaaS-team/KaaS-factory/releases) and checks its sha256.

## First command

To see what the maintainer script does without network access, render the formula from the checked-in checksums fixture into a temp file:

```sh
SUMS_URL="file://$PWD/tests/fixtures/SHA256SUMS" OUT=/tmp/factory.rb sh scripts/bump-formula.sh v6.2.0
```

Output:

```
/tmp/factory.rb
```

The script prints the path it wrote. `cmp /tmp/factory.rb Formula/factory.rb` shows no difference.

## Check the repo

```sh
make check
```

`make check` is the gate. It runs three things:

- `scripts/docs-check.sh`: fails if a relative link in any markdown file points to a missing file, or if a `sh` or `bash` block in this README names a script or `make` target that does not exist.
- `tests/docs-check-test.sh`: proves the docs check fails on a broken link, a missing script and a missing make target.
- `tests/formula-check.sh`: checks the formula has four release URLs and four sha256 values, that they match the fixture, and that the bump script gives the same bytes on every run.

No network is used by `make check`.

## Update the formula

```sh
sh scripts/bump-formula.sh v6.2.0
```

This downloads `SHA256SUMS` from that release of `KaaS-team/KaaS-factory` and rewrites `Formula/factory.rb`. The tag must look like `vX.Y.Z`. Set `REPO` to use another release repository and `OUT` to write somewhere else.

An auto-bump workflow is drafted in [docs/auto-bump-workflow.yml.txt](docs/auto-bump-workflow.yml.txt). It is not active. The file explains how to turn it on.

## Where to go next

- [KaaS Factory](https://github.com/KaaS-team/KaaS-factory) for what the factory does and its commands.
- [LICENSE](LICENSE): Apache-2.0.
