#!/bin/sh
# Renders Formula/factory.rb for one KaaS Factory release tag.
#
#   scripts/bump-formula.sh v6.2.0
#
# Downloads the release SHA256SUMS, takes the four binary checksums from it and
# writes the formula from a here-doc template. The same tag always produces the
# same bytes, so running it twice is a no-op.
#
# Environment:
#   REPO      release repository (default KaaS-team/KaaS-factory)
#   SUMS_URL  where to fetch SHA256SUMS (default: the release for the tag);
#             a file:// URL works for local testing
#   OUT       output path (default Formula/factory.rb)
set -eu

REPO=${REPO:-KaaS-team/KaaS-factory}
OUT=${OUT:-Formula/factory.rb}

die() { printf 'bump-formula: %s\n' "$*" >&2; exit 1; }

[ "$#" -eq 1 ] || die "usage: bump-formula.sh <tag>"
tag=$1
printf '%s\n' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' || die "bad tag $tag, want vX.Y.Z"
version=${tag#v}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

SUMS_URL=${SUMS_URL:-https://github.com/$REPO/releases/download/$tag/SHA256SUMS}
curl -fsSL "$SUMS_URL" -o "$tmp/SHA256SUMS" || die "could not download $SUMS_URL"

# sha_for <asset>: the checksum line for one asset, or fail.
sha_for() {
  s=$(awk -v f="$1" '$2 == f || $2 == "*" f { print $1; exit }' "$tmp/SHA256SUMS")
  printf '%s\n' "$s" | awk 'length($0) == 64 && /^[0-9a-f]+$/ { ok = 1 } END { exit !ok }' \
    || die "no valid sha256 listed for $1"
  printf '%s\n' "$s"
}

sha_darwin_arm64=$(sha_for factory-darwin-arm64)
sha_darwin_x64=$(sha_for factory-darwin-x64)
sha_linux_arm64=$(sha_for factory-linux-arm64)
sha_linux_x64=$(sha_for factory-linux-x64)

url_base="https://github.com/$REPO/releases/download/$tag"

cat > "$tmp/formula.rb" <<EOF
class Factory < Formula
  desc "KaaS Factory command line"
  homepage "https://kaas.team"
  version "$version"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "$url_base/factory-darwin-arm64"
      sha256 "$sha_darwin_arm64"
    end
    on_intel do
      url "$url_base/factory-darwin-x64"
      sha256 "$sha_darwin_x64"
    end
  end

  on_linux do
    on_arm do
      url "$url_base/factory-linux-arm64"
      sha256 "$sha_linux_arm64"
    end
    on_intel do
      url "$url_base/factory-linux-x64"
      sha256 "$sha_linux_x64"
    end
  end

  def install
    bin.install Dir["factory-*"].first => "factory"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/factory --version")
  end
end
EOF

mkdir -p "$(dirname "$OUT")"
mv "$tmp/formula.rb" "$OUT"
printf '%s\n' "$OUT"
