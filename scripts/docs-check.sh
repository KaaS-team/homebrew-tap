#!/bin/sh
# Docs check. Fails when:
#   1. a relative link in any tracked markdown file points to a missing file;
#   2. a fenced sh/bash block in README.md runs a script under scripts/ or tests/
#      that does not exist, or a `make` target that is not in the Makefile.
# Run from anywhere:  sh scripts/docs-check.sh
# DOCS_ROOT overrides the directory to check (used by the tests).
set -eu

root=${DOCS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
cd "$root"
fail=0
bad() { printf 'FAIL  %s\n' "$1"; fail=1; }

files=$(find . -name '*.md' -not -path './.git/*' | sort)

# 1. Relative links: [text](target), skipping URLs, anchors and mailto.
for f in $files; do
  dir=$(dirname "$f")
  grep -o ']([^)]*)' "$f" | sed 's/^](//; s/)$//' | while IFS= read -r link; do
    case $link in
      http://*|https://*|mailto:*|'#'*|'') continue ;;
    esac
    target=${link%%#*}
    [ -n "$target" ] || continue
    [ -e "$dir/$target" ] || printf 'FAIL  %s: link to missing file %s\n' "$f" "$link"
  done
done > "${TMPDIR:-/tmp}/docs-check.$$"
if [ -s "${TMPDIR:-/tmp}/docs-check.$$" ]; then cat "${TMPDIR:-/tmp}/docs-check.$$"; fail=1; fi
rm -f "${TMPDIR:-/tmp}/docs-check.$$"

# 2. Commands in fenced sh/bash blocks of README.md.
if [ -f README.md ]; then
  awk '
    /^```(sh|bash)[ \t]*$/ { inb = 1; next }
    /^```/ { inb = 0; next }
    inb { print }
  ' README.md | while IFS= read -r line; do
    for w in $line; do
      case $w in
        scripts/*.sh|tests/*.sh)
          [ -f "$w" ] || printf 'FAIL  README.md: script %s does not exist\n' "$w" ;;
      esac
    done
    case $line in
      make\ *)
        t=$(printf '%s\n' "$line" | awk '{print $2}')
        grep -q "^$t:" Makefile 2>/dev/null || printf 'FAIL  README.md: make target %s is not in the Makefile\n' "$t" ;;
    esac
  done > "${TMPDIR:-/tmp}/docs-check2.$$"
  if [ -s "${TMPDIR:-/tmp}/docs-check2.$$" ]; then cat "${TMPDIR:-/tmp}/docs-check2.$$"; fail=1; fi
  rm -f "${TMPDIR:-/tmp}/docs-check2.$$"
fi

if [ "$fail" -eq 0 ]; then printf 'docs check passed\n'; else exit 1; fi
