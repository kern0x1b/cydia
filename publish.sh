#!/usr/bin/env bash
# Rebuild the package index and Release from whatever is in debs/.
#
#   ./publish.sh                       reindex what is already here
#   ./publish.sh path/to/foo.deb ...   copy those in first, then reindex
#
# Every index is regenerated from debs/ — never hand-edit Packages or the
# checksum block in Release.
set -euo pipefail
cd "$(dirname "$0")"

for deb in "$@"; do
    [ -f "$deb" ] || { echo "no such file: $deb" >&2; exit 1; }
    cp "$deb" debs/
    echo "added $(basename "$deb")"
done

# -m keeps every version in the index. Without it dpkg-scanpackages emits only
# the newest, and older debs sit in debs/ unreachable through the source.
dpkg-scanpackages -m debs /dev/null > Packages 2>/dev/null

# Cydia on old iOS asks for .bz2 first, then .gz, then plain. Ship all three.
gzip -nkf Packages
bzip2 -kf Packages

# Release carries the checksums of the index files. Rebuild it by keeping the
# metadata header and replacing everything from the first checksum block on.
awk '/^(MD5Sum|SHA1|SHA256):/{exit} {print}' Release > Release.new

hash_block() {
    printf '%s:\n' "$1"
    for f in Packages Packages.gz Packages.bz2; do
        printf ' %s %s %s\n' "$($2 "$f")" "$(wc -c < "$f" | tr -d ' ')" "$f"
    done
}
md5of()    { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
sha1of()   { shasum -a 1   "$1" | cut -d' ' -f1; }
sha256of() { shasum -a 256 "$1" | cut -d' ' -f1; }

hash_block MD5Sum md5of    >> Release.new
hash_block SHA1   sha1of   >> Release.new
hash_block SHA256 sha256of >> Release.new
mv Release.new Release

echo
echo "indexed $(grep -c '^Package:' Packages) package(s):"
awk '/^Package:/{p=$2} /^Version:/{print "  " p " " $2}' Packages
