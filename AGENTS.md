# Gentoo Local Overlay — AI Agent Instructions

## What This Is

A Gentoo Linux local ebuild overlay.
All packages are for **amd64** only (`amd64` keyword).

**Source-first policy**: Always prefer building from source (git).
Only fall back to prebuilt packages (.deb, .rpm, AppImage, etc.) when source
builds are genuinely infeasible (e.g., proprietary binaries with no public source).

## Repository Layout

Each package has:
- `<name>-<version>.ebuild` — the build/install recipe
- `metadata.xml` — package metadata (maintainer, description, upstream)
- `files/` (optional) — desktop entries, launcher scripts, patches

## Ebuild Conventions

- **EAPI=8** for all packages — use EAPI 8 for new packages
- **KEYWORDS="amd64"** —  all packages are amd64
- **Source fetching**: always use `git-r3` to clone from git (never use `SRC_URI` tarballs)
  - Go packages: `inherit go-module git-r3`, set `EGIT_REPO_URI` and `EGIT_COMMIT="v${PV}"`
  - .NET packages: `inherit git-r3`, set `EGIT_REPO_URI` and `EGIT_COMMIT="${PV}"`
- **Copyright header**: `# Copyright 1999-2026 Gentoo Authors` + GPL-2 notice
- **Quoting**: all variable values quoted (e.g., `SLOT="0"`, `KEYWORDS="amd64"`)
- **Error handling**: all critical operations use `|| die "message"`
- **Informative pkg_postinst**: every ebuild has `einfo` messages guiding the user

### Dependency Types

| Variable     | Use for                                       |
|-------------|-----------------------------------------------|
| `BDEPEND`   | Build-time deps that run on the build host    |
| `RDEPEND`   | Runtime deps needed after installation        |
| `DEPEND`    | Compile-time deps (rarely used here)          |

Each dependency must appear in **only one** variable (BDEPEND, RDEPEND, or DEPEND).
Portage handles cross-type deduplication automatically — do not repeat the same
atom across multiple variables.

## New Package Checklist

When creating a new package (`<category>/<name>/`), the following files are
mandatory.  Create them all in one pass — never leave a package half-built.

### Package-level (every package)

| File | Required | Notes |
|------|----------|-------|
| `metadata.xml` | ✅ | Maintainer, description, upstream remote-id |
| `<name>-<version>.ebuild` | ✅ | EAPI=8, follows all Ebuild Conventions |
| `Manifest` | ✅ | Run `pkgdev manifest` after ebuild is written |
| `files/` | ⚠️ optional | Desktop entries, launcher scripts, patches |

### Repository-level (create once, verify on each new package)

| File | Required | Notes |
|------|----------|-------|
| `profiles/repo_name` | ✅ | Single line: overlay name |
| `metadata/layout.conf` | ✅ | `masters = gentoo`, hash config |
| `profiles/categories` | ✅ | One category per line |

## Ebuild Self-Check

Before declaring an ebuild done, verify **every** item below:

- [ ] `EAPI=8`
- [ ] `KEYWORDS="amd64"` (with quotes)
- [ ] `SLOT="0"` (or correct slot)
- [ ] `LICENSE` is set to the correct license
- [ ] `HOMEPAGE` points to the upstream project
- [ ] Copyright header: `# Copyright 1999-2026 Gentoo Authors` + GPL-2 notice
- [ ] All variable values are quoted (`SLOT="0"`, not `SLOT=0`)
- [ ] Every critical shell operation uses `|| die "message"`
- [ ] `src_install` ends with `dobin` or `dosym` to expose the binary
- [ ] `pkg_postinst` has `einfo` messages guiding the user
- [ ] `pkg_postrm` exists if `pkg_postinst` registers desktop/icons
- [ ] `Manifest` file exists (run `pkgdev manifest` in the package dir)
- [ ] Source fetching convention matches: `git-r3` for source builds, `SRC_URI` only for prebuilt binaries
- [ ] `RESTRICT` is set appropriately (`network-sandbox` for Go/.NET, `strip mirror` for prebuilt)
