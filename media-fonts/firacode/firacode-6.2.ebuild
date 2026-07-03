# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Free monospaced font with programming ligatures"
HOMEPAGE="https://github.com/tonsky/FiraCode"
SRC_URI="https://github.com/tonsky/FiraCode/releases/download/${PV}/Fira_Code_v${PV}.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="amd64"

BDEPEND="app-arch/unzip"

RESTRICT="strip"

src_unpack() {
	default
	mv "Fira_Code_v${PV}" "${P}" || die "Failed to rename source directory"
}

src_install() {
	local fontdir="/usr/share/fonts/firacode"

	insinto "${fontdir}"

	# Install TrueType fonts (.ttf)
	doins "${S}/ttf/"*.ttf || die "Failed to install TTF fonts"

	# Install OpenType fonts (.otf)
	doins "${S}/otf/"*.otf || die "Failed to install OTF fonts"

	# Install WOFF/WOFF2 for web usage
	doins "${S}/woff/"*.woff || die "Failed to install WOFF fonts"
	doins "${S}/woff2/"*.woff2 || die "Failed to install WOFF2 fonts"

	# Install fontconfig configuration
	insinto /etc/fonts/conf.avail
	doins "${FILESDIR}/60-firacode.conf" || die "Failed to install fontconfig conf"

	dodoc "${S}/LICENSE" || die "Failed to install LICENSE"
}

pkg_postinst() {
	einfo ""
	einfo "✔ Fira Code ${PV} has been installed."
	einfo ""
	einfo "Font files are installed to /usr/share/fonts/firacode/:"
	einfo "  - TTF (TrueType)"
	einfo "  - OTF (OpenType)"
	einfo "  - WOFF / WOFF2 (web fonts)"
	einfo ""
	einfo "To register Fira Code as the preferred monospace font:"
	einfo "  eselect fontconfig enable 60-firacode.conf"
	einfo ""
	einfo "Then refresh the font cache:"
	einfo "  fc-cache -fv"
	einfo ""
	einfo "To enable ligatures in your editor, select 'Fira Code' as the"
	einfo "monospace font and enable font ligatures / contextual alternates."
	einfo "See: https://github.com/tonsky/FiraCode/wiki"
	einfo ""
}

pkg_postrm() {
	if [ -h /etc/fonts/conf.d/60-firacode.conf ]; then
		ewarn "Fontconfig symlink still present. Disable it with:"
		ewarn "  eselect fontconfig disable 60-firacode.conf"
	fi

	einfo ""
	einfo "Fira Code has been removed. Run 'fc-cache -fv' to refresh"
	einfo "the font cache."
	einfo ""
}
