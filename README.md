<img src="CydiaIcon.png" width="96" height="96" alt="repo icon">

# Legacy iOS Tweaks — Cydia repo

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-iOS%205.0%2B-lightgrey)

A single Cydia source aggregating MobileSubstrate tweaks for jailbroken
legacy iOS devices. Pure distribution point — no tweak source code lives
here, only built `.deb`s and the package index.

## Install

Cydia → Sources → Edit → Add:

```
https://kern0x1b.github.io/cydia/
```

## Published tweaks

| Package | Source repo | Fixes |
|---|---|---|
| `space.kern0x1b.expectfix` — Kindle Whispersync Fix | [kindle-sync-fix](https://github.com/kern0x1b/kindle-sync-fix) | Amazon Kindle app sync failing with 417 Expectation Failed |
| `space.kern0x1b.soundcloudfix` — SoundCloud iOS 6 Fix | [soundcloud-fix](https://github.com/kern0x1b/soundcloud-fix) (private) | SoundCloud 2.7.2 broken by the v1 API deprecation and dead password OAuth grant |

## Repo layout

```
publish.sh               rebuilds every index below from debs/
Packages                 dpkg-scanpackages index over debs/
Packages.gz/.bz2         the same index, compressed — clients fetch these
Release                  repo metadata + checksums of the three index files
CydiaIcon.png            repo icon
debs/                    built .deb files
depictions/              per-package pages Cydia shows instead of plain text
```

Old Cydia asks for `Packages.bz2` first, then `.gz`, then plain, so all three
are published. The index is built with `-m`, which keeps every version of a
package rather than only the newest.

## Publishing a new tweak here

1. Build the `.deb` in the tweak's own repo (see that repo's README).
2. From here:
   ```
   ./publish.sh <tweak-repo>/dist/*.deb
   git add -A && git commit -m "Publish <tweak-name> <version>" && git push
   ```
   `publish.sh` copies the `.deb` in, rebuilds `Packages`, `Packages.gz`,
   `Packages.bz2` and the checksum block in `Release`, then prints what it
   indexed. Run it with no arguments to just reindex what is already in `debs/`.
3. Add a row to the table above, and a page under `depictions/` if the package
   sets `Depiction:`.

Never hand-edit `Packages` or the checksum block in `Release` — both are
generated, and edits are overwritten on the next publish.

## Contributing

Want your tweak listed here? Open a PR adding a row to the table above with
your `.deb` published under `debs/` and its own source repo linked.

## License

This repo (index, icon, tooling) is MIT, see [LICENSE](LICENSE). Each
published tweak carries its own license in its own source repo.
