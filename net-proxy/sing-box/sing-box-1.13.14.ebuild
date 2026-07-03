# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module git-r3

DESCRIPTION="The universal proxy platform (sing-box)"
HOMEPAGE="https://github.com/SagerNet/sing-box"

# Clone source from git (tag)
EGIT_REPO_URI="https://github.com/SagerNet/sing-box.git"
EGIT_COMMIT="v${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

BDEPEND="dev-lang/go"

# Go module download needs network
RESTRICT="network-sandbox"

src_compile() {
	ego build \
		-trimpath \
		-ldflags "-s -w -buildid=" \
		-o sing-box \
		./cmd/sing-box || die "go build failed"
}

src_install() {
	dobin sing-box || die "Failed to install sing-box binary"
}

pkg_postinst() {
	einfo ""
	einfo "sing-box ${PV} has been installed (built from source)."
	einfo ""
	einfo "Run 'sing-box version' to verify the installation."
	einfo ""
	einfo "Note: sing-box is a standalone proxy core. To use it with a GUI,"
	einfo "install net-proxy/v2rayn which provides the graphical interface."
	einfo ""
}
