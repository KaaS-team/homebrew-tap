# homebrew-tap

The Homebrew tap for [KaaS Team](https://github.com/KaaS-team) command line tools.

## Install

```sh
brew install kaas-team/tap/factory
```

Or add the tap first, then install:

```sh
brew tap kaas-team/tap
brew install factory
```

Check it worked:

```sh
factory --version
```

## What is in the tap

| Formula | What it is |
| --- | --- |
| `factory` | The AI SDLC software factory command line. |
| `kaasbot` | 24/7 AI teammates. Coming soon. |

Formulae live in `Formula/`. Each release of a tool writes its own formula here. Do not edit those files by hand.

## Pull requests

A pull request that changes a file in `Formula/` runs the formula CI workflow (source in [docs/formula-ci.yml.txt](docs/formula-ci.yml.txt), to be placed in `.github/workflows/`):

- `brew style` on the changed formulae.
- `brew audit --strict` on the changed formulae.
- `brew install --build-from-source` on macOS, then `brew test`.

## Check the repo

```sh
make check
```

`make check` checks that every relative link in the markdown files works, and that the scripts and make targets named in this README exist. It needs no network.

## License

[Apache-2.0](LICENSE).
