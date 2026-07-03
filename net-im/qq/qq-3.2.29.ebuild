# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Tencent QQ instant messaging client for Linux (QQNT-based)"
HOMEPAGE="https://im.qq.com/index/#/linux"

# QQ Linux x86_64 deb package
# NOTE: The URL path segments (internal version + commit hash) change per release.
# Update both EGIT-style variables below when bumping PV.
QQNT_VER="9.9.31"
QQNT_HASH="00e6a3e7"
QQNT_DATE="260528"
SRC_URI="https://qqdl.gtimg.cn/qqfile/QQNT/${QQNT_VER}/release/${QQNT_HASH}/QQ_${PV}_${QQNT_DATE}_amd64_01.deb"

LICENSE="Tencent-QQ-EULA"
SLOT="0"
KEYWORDS="amd64"

# Electron-based, all deps self-contained in the deb
RDEPEND="
	|| (
		x11-libs/gtk+:3
		>=x11-libs/gtk+-3.0
	)
	dev-libs/nss
	media-libs/alsa-lib
"

# Prebuilt binary package restrictions
RESTRICT="strip mirror bindist"

S="${WORKDIR}"

QA_PREBUILT="opt/QQ/*"

src_install() {
	# Copy extracted deb contents
	cp -a usr/ "${ED}/" || die "Failed to copy usr/"
	cp -a opt/ "${ED}/" || die "Failed to copy opt/"

	# Fix permissions — shared objects need to be executable
	find "${ED}/opt/QQ" -type f \( -name '*.so' -o -name '*.so.*' \) \
		-exec chmod 0755 {} \; || die
	find "${ED}/opt/QQ" -type f -name 'qq' -exec chmod 0755 {} \; || die
	find "${ED}/opt/QQ" -type f -name 'chrome-sandbox' -exec chmod 4755 {} \; || die

	# Link main binary into PATH
	dosym ../../opt/QQ/qq /usr/bin/qq

	# Desktop entry (our own copy, in case upstream's is missing or broken)
	domenu "${FILESDIR}/qq.desktop"

	# Icon
	local icon_size
	for icon_size in 16 24 32 48 64 128 256; do
		if [[ -f "${ED}/usr/share/icons/hicolor/${icon_size}x${icon_size}/apps/qq.png" ]]; then
			newicon -s "${icon_size}" \
				"${ED}/usr/share/icons/hicolor/${icon_size}x${icon_size}/apps/qq.png" \
				qq.png
		fi
	done
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	einfo ""
	einfo "✔ QQ ${PV} has been installed."
	einfo ""
	einfo "Launch:  qq  (or find QQ in Application Menu → Internet / Network)"
	einfo ""
	einfo "NOTE: QQ is governed by the Tencent End User License Agreement."
	einfo "By using this software you agree to the terms at:"
	einfo "  https://rule.tencent.com/rule/202504020001"
	einfo ""
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
