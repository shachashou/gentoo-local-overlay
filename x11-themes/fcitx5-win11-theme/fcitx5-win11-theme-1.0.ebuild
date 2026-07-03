# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Windows 11 Fluent Design theme for Fcitx5"
HOMEPAGE="https://github.com/local/fcitx5-win11-theme"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="app-i18n/fcitx"

RESTRICT="strip mirror"

src_install() {
	local themedir="/usr/share/fcitx5/themes/fcitx5-win11-theme"
	insinto "${themedir}"
	doins "${FILESDIR}/fcitx5-win11-theme/theme.conf" || die "Failed to install theme.conf"
}

pkg_postinst() {
	einfo ""
	einfo "✔ fcitx5-win11-theme ${PV} has been installed."
	einfo ""
	einfo "To apply this theme, open Fcitx5 configuration:"
	einfo "  fcitx5-configtool"
	einfo ""
	einfo "Then go to: Addons → Classic User Interface → Settings"
	einfo "Set Theme to: fcitx5-win11-theme"
	einfo ""
	einfo "Alternatively, set it in ~/.config/fcitx5/conf/classicui.conf:"
	einfo "  Theme=fcitx5-win11-theme"
	einfo ""
}
