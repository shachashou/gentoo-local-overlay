# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo git-r3 systemd xdg

DESCRIPTION="Linux GPU Configuration And Monitoring Tool"
HOMEPAGE="https://github.com/ilya-zlobintsev/LACT"

EGIT_REPO_URI="https://github.com/ilya-zlobintsev/LACT.git"
EGIT_COMMIT="v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	gui-libs/gtk:4
	gui-libs/libadwaita
	x11-libs/libdrm
	sys-apps/hwdata
	dev-libs/libdisplay-info
"

BDEPEND="
	dev-lang/rust
	virtual/pkgconfig
	sys-devel/clang
	sys-devel/make
"

# Cargo needs network to fetch crate dependencies
RESTRICT="network-sandbox"

src_compile() {
	cargo build --release --package lact || die "cargo build failed"
}

src_install() {
	dobin "target/release/lact" || die "Failed to install lact binary"

	# systemd service
	systemd_dounit "res/lactd.service" || die "Failed to install systemd service"

	# desktop entry
	domenu "res/io.github.ilya_zlobintsev.LACT.desktop" || die "Failed to install desktop entry"

	# icons
	newicon -s 512 "res/io.github.ilya_zlobintsev.LACT.png" "io.github.ilya_zlobintsev.LACT.png"
	newicon -s scalable "res/io.github.ilya_zlobintsev.LACT.svg" "io.github.ilya_zlobintsev.LACT.svg"

	# metainfo
	insinto /usr/share/metainfo
	doins "res/io.github.ilya_zlobintsev.LACT.metainfo.xml" || die "Failed to install metainfo"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	einfo ""
	einfo "✔ LACT ${PV} has been installed (built from source)."
	einfo ""
	einfo "To use LACT, first enable and start the daemon:"
	einfo "  systemctl enable --now lactd"
	einfo ""
	einfo "Then launch the GUI:"
	einfo "  lact gui"
	einfo ""
	einfo "Socket permissions: LACT uses the 'wheel' or 'sudo' group for"
	einfo "unix socket ownership. Make sure your user is in one of these"
	einfo "groups, or edit /etc/lact/config.yaml to set admin_user."
	einfo ""
	einfo "For AMD overclocking, see:"
	einfo "  https://github.com/ilya-zlobintsev/LACT/wiki/Overclocking-(AMD)"
	einfo ""
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
