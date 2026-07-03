# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Windows 11 Chinese Simplified system fonts"
HOMEPAGE="https://github.com/liblaf/win-fonts"
SRC_URI="https://github.com/liblaf/win-fonts/releases/download/Win11/Win11-Chinese_Simplified.zip -> Win11-Chinese_Simplified-${PV}.zip"

LICENSE="MSttfEULA"
SLOT="0"
KEYWORDS="amd64"

BDEPEND="app-arch/unzip"

RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die "Failed to create source directory"

	cd "${S}" || die "Failed to enter source directory"

	unzip -q "${DISTDIR}/Win11-Chinese_Simplified-${PV}.zip" \
		|| die "Failed to unpack Chinese Simplified fonts"
}

src_install() {
	local fontdir="/usr/share/fonts/win11"

	insinto "${fontdir}"

	# Install TrueType fonts
	local ttf_count=$(ls -1 "${S}"/*.ttf 2>/dev/null | wc -l)
	if [[ ${ttf_count} -gt 0 ]]; then
		doins "${S}"/*.ttf || die "Failed to install TTF fonts"
	fi

	# Install TrueType Collection fonts
	local ttc_count=$(ls -1 "${S}"/*.ttc 2>/dev/null | wc -l)
	if [[ ${ttc_count} -gt 0 ]]; then
		doins "${S}"/*.ttc || die "Failed to install TTC fonts"
	fi

	# Install fontconfig configuration
	insinto /etc/fonts/conf.avail
	doins "${FILESDIR}/60-win11-chinese.conf" || die "Failed to install fontconfig conf"
}

pkg_postinst() {
	einfo ""
	einfo "✔ Windows 11 Chinese Simplified fonts installed to /usr/share/fonts/win11"
	einfo ""
	einfo "To register these fonts as the preferred Chinese font fallback:"
	einfo "  eselect fontconfig enable 60-win11-chinese.conf"
	einfo ""
	einfo "Then refresh the font cache:"
	einfo "  fc-cache -fv"
	einfo ""
	einfo "To verify installed fonts:"
	einfo "  fc-list | grep -i win11"
	einfo ""
}

pkg_postrm() {
	if [ -h /etc/fonts/conf.d/60-win11-chinese.conf ]; then
		ewarn "Fontconfig symlink still present. Disable it with:"
		ewarn "  eselect fontconfig disable 60-win11-chinese.conf"
	fi

	einfo ""
	einfo "Windows 11 Chinese fonts have been removed."
	einfo "Run 'fc-cache -fv' to refresh the font cache."
	einfo ""
}
