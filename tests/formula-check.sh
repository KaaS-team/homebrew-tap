#!/bin/sh
# Checks the formula and the bump script. Run from anywhere in the repo.
#   sh tests/formula-check.sh
set -eu

cd "$(dirname "$0")/.."

FORMULA=${FORMULA:-Formula/factory.rb}
FIXTURE=tests/fixtures/SHA256SUMS
TAG=v6.2.0
fail=0

ok() { printf 'ok    %s\n' "$1"; }
bad() { printf 'FAIL  %s\n' "$1"; fail=1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

[ -f "$FORMULA" ] || { bad "$FORMULA is missing"; exit 1; }
[ -f "$FIXTURE" ] || { bad "$FIXTURE is missing"; exit 1; }

# 1. Four release URLs, one per platform.
n_url=$(grep -c '^ *url "https://github.com/[^"]*/releases/download/v[0-9.]*/factory-[a-z0-9-]*"$' "$FORMULA" || true)
if [ "$n_url" -eq 4 ]; then ok "formula has 4 release url lines"; else bad "formula has $n_url release url lines, want 4"; fi

# 2. Four 64-hex sha256 values.
n_sha=$(grep -cE '^ *sha256 "[0-9a-f]{64}"$' "$FORMULA" || true)
if [ "$n_sha" -eq 4 ]; then ok "formula has 4 sha256 lines of 64 hex digits"; else bad "formula has $n_sha sha256 lines, want 4"; fi

# 3, 4, 6. Checks against the fixture. They apply only while the formula is at the
# fixture's version; a later auto-bump is checked by 1, 2 and 5 instead.
if grep -qx "  version \"${TAG#v}\"" "$FORMULA"; then
  for asset in factory-darwin-arm64 factory-darwin-x64 factory-linux-arm64 factory-linux-x64; do
    want=$(awk -v f="$asset" '$2 == f { print $1; exit }' "$FIXTURE")
    if grep -q "$want" "$FORMULA" && grep -q "/$asset\"" "$FORMULA"; then
      ok "$asset checksum matches $FIXTURE"
    else
      bad "$asset checksum does not match $FIXTURE"
    fi
  done
  ok "version is ${TAG#v}"
  SUMS_URL="file://$PWD/$FIXTURE"
  export SUMS_URL
  OUT="$tmp/fixture.rb" sh scripts/bump-formula.sh "$TAG" >/dev/null
  if cmp -s "$tmp/fixture.rb" "$FORMULA"; then ok "committed formula equals bump-formula.sh output for $TAG"; else bad "committed formula differs from bump-formula.sh output for $TAG"; fi
else
  ok "formula is not at $TAG, fixture comparison skipped"
  SUMS_URL="file://$PWD/$FIXTURE"
  export SUMS_URL
fi

# 5. bump-formula.sh is idempotent: the same tag gives the same bytes, also over an existing file.
OUT="$tmp/a.rb" sh scripts/bump-formula.sh "$TAG" >/dev/null
OUT="$tmp/b.rb" sh scripts/bump-formula.sh "$TAG" >/dev/null
if cmp -s "$tmp/a.rb" "$tmp/b.rb"; then ok "bump-formula.sh gives identical output on two runs"; else bad "bump-formula.sh output differs between runs"; fi
OUT="$tmp/a.rb" sh scripts/bump-formula.sh "$TAG" >/dev/null
if cmp -s "$tmp/a.rb" "$tmp/b.rb"; then ok "re-running over an existing file changes nothing"; else bad "re-run over an existing file changed the output"; fi

# 7. A bad tag is refused.
if OUT="$tmp/c.rb" sh scripts/bump-formula.sh 6.2.0 >/dev/null 2>&1; then bad "bump-formula.sh accepted a tag without v"; else ok "bump-formula.sh refuses a tag without v"; fi

# 8. No em dashes in the files this change owns.
dash=$(printf '\342\200\224')
for f in scripts/bump-formula.sh tests/formula-check.sh "$FORMULA" README.md docs/auto-bump-workflow.yml.txt; do
  [ -f "$f" ] || continue
  if grep -q "$dash" "$f"; then bad "$f contains an em dash"; else ok "$f has no em dash"; fi
done

if [ "$fail" -eq 0 ]; then
  printf 'all checks passed\n'
else
  printf 'some checks failed\n' >&2
  exit 1
fi
