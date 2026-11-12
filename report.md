BRANCH: cluster/docs
HEAD: 5ba65ff50a2c496e5d303372c3f0e0de9f1cb386
## Summary
README rewritten (about 55 lines) and a docs check added behind a new `make check` gate. The formula still installs the old Bun/TS v6.2.0 binaries and the README says so in one line; I did not move it to the Go release layout.
## Acceptance
- Inventory (README.md, docs/auto-bump-workflow.yml.txt; commands `brew install`, `bump-formula.sh`, `formula-check.sh`) -> run from clean clone -> done. Works: bump-formula.sh with fixture, formula-check.sh. Fixed doc: README "curl or npm installer" link to factory-install removed (unverifiable, targets the old installer), README "first command" now shows real output. The v6.2.0 SHA256SUMS URL returns 200. kaas.team and the releases page could not be checked from here (proxy 403/000), links to the releases page kept.
- README shape (two sentences, install, first command with output, next steps, under 150 lines, no em dashes) -> tests/formula-check.sh em dash check + manual -> done
- Stale content gone -> docs-check.sh -> done. Removed: factory-install link, "npm installer" claim, "Part of KaaS" footer and kaas.team link. v9 behaviour is not described; `git show origin/next:README.md` is still the old TS README, so no v9 command claims were made.
- Docs check in gate, proven to bite -> tests/docs-check-test.sh (5 failing cases plus a pass case); also broke README's LICENSE link once and `make check` exited 2 -> done
- No gate existed, `make check` added and named in README -> done
- Gate passes from clean clone -> make check exit 0 -> done
## Files outside my area
none
## Goldens changed
none
## Gate evidence
ok    missing script fails
ok    missing make target fails
ok    urls and anchors ignored
docs check tests passed
(make check exit 0)
## Learnings
- next:README.md is still the old TS README, so the brief's "describe only what matches it" had little to anchor on; the brief should say which file holds v9 facts.
- The Go release uses factory_<os>_<arch>.tar.gz and checksums.txt, so the formula and bump script need a real code change; that is outside this docs brief.
- gh and the proxy block several external links; a link checker cannot verify those offline.
