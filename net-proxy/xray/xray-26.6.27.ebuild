# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module git-r3

DESCRIPTION="Xray, Penetrates Everything. Core of Project X."
HOMEPAGE="https://github.com/XTLS/Xray-core"

# Clone source from git (tag)
EGIT_REPO_URI="https://github.com/XTLS/Xray-core.git"
EGIT_COMMIT="v${PV}"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="amd64"

BDEPEND="dev-lang/go"
RDEPEND="
	!net-proxy/v2ray
	!net-proxy/v2ray-bin
"

# Go module download needs network
RESTRICT="network-sandbox"

src_compile() {
	ego build \
		-trimpath \
		-ldflags "-s -w -buildid=" \
		-o xray \
		./main || die "go build failed"
}

src_install() {
	dobin xray || die "Failed to install xray binary"

	dodir /etc/xray
	dodir /var/log/xray
	keepdir /var/log/xray
}

pkg_postinst() {
	einfo ""
	einfo "Xray ${PV} has been installed (built from source)."
	einfo ""
	einfo "Please configure /etc/xray/config.json before running."
	einfo ""
	einfo "Geo data files (geoip.dat, geosite.dat) are required."
	einfo "Download them from:"
	einfo "  https://github.com/XTLS/Xray-core/releases/tag/v${PV}"
	einfo "Place them in /usr/share/xray/ or configure path in config.json."
	einfo ""
	einfo "Note: Xray is a standalone proxy core. To use it with a GUI,"
	einfo "install net-proxy/v2rayn which provides the graphical interface."
	einfo ""
}
