#!/bin/sh
# Proves the docs check bites: a good tree passes, a broken link fails,
# a missing script and a missing make target in README fail.
set -eu
cd "$(dirname "$0")/.."
here=$PWD
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT INT TERM
fail=0
expect() { # name want(0|1) dir
  if DOCS_ROOT=$3 sh "$here/scripts/docs-check.sh" >"$tmp/out" 2>&1; then got=0; else got=1; fi
  if [ "$got" -eq "$2" ]; then printf 'ok    %s\n' "$1"; else printf 'FAIL  %s\n' "$1"; cat "$tmp/out"; fail=1; fi
}
mk() { rm -rf "$tmp/t"; mkdir -p "$tmp/t/scripts" "$tmp/t/docs"; : > "$tmp/t/scripts/a.sh"; : > "$tmp/t/docs/b.md"
  printf 'all:\n\ttrue\n' > "$tmp/t/Makefile"; printf '```sh\nsh scripts/a.sh\nmake all\n```\n[b](docs/b.md)\n' > "$tmp/t/README.md"; }
mk; expect "good tree passes" 0 "$tmp/t"
mk; printf '[x](docs/gone.md)\n' >> "$tmp/t/README.md"; expect "missing link fails" 1 "$tmp/t"
mk; printf '[x](gone.md)\n' >> "$tmp/t/docs/b.md"; expect "missing link in nested doc fails" 1 "$tmp/t"
mk; rm "$tmp/t/scripts/a.sh"; expect "missing script fails" 1 "$tmp/t"
mk; printf '```sh\nmake nope\n```\n' >> "$tmp/t/README.md"; expect "missing make target fails" 1 "$tmp/t"
mk; printf '[w](https://example.com/x) [a](#top)\n' >> "$tmp/t/README.md"; expect "urls and anchors ignored" 0 "$tmp/t"
[ "$fail" -eq 0 ] || exit 1
printf 'docs check tests passed\n'
