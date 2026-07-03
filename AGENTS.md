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
