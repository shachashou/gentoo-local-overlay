# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Tencent WeChat (Weixin) desktop client for Linux"
HOMEPAGE="https://linux.weixin.qq.com/"

# WeChat Linux universal deb package
SRC_URI="https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"

LICENSE="Tencent-WeChat-EULA"
SLOT="0"
KEYWORDS="amd64"

# Electron-based, all deps self-contained in the deb
RDEPEND="
	x11-libs/gtk+:3
	dev-libs/nss
	media-libs/alsa-lib
"

# Prebuilt binary package restrictions
RESTRICT="strip mirror bindist"

S="${WORKDIR}"

QA_PREBUILT="opt/wechat/*"

src_install() {
	# Copy extracted deb contents
	cp -a usr/ "${ED}/" || die "Failed to copy usr/"
	cp -a opt/ "${ED}/" || die "Failed to copy opt/"

	# Fix permissions — shared objects need to be executable
	find "${ED}/opt/wechat" -type f \( -name '*.so' -o -name '*.so.*' \) \
		-exec chmod 0755 {} \; || die
	find "${ED}/opt/wechat" -type f -name 'wechat' -exec chmod 0755 {} \; || die
	find "${ED}/opt/wechat" -type f -name 'chrome-sandbox' -exec chmod 4755 {} \; || die

	# Link main binary into PATH
	dosym ../../opt/wechat/wechat /usr/bin/wechat

	# Desktop entry and icons already installed via cp -a usr/ above
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	einfo ""
	einfo "✔ WeChat ${PV} has been installed."
	einfo ""
	einfo "Launch:  wechat  (or find WeChat in Application Menu → Internet)"
	einfo ""
	einfo "NOTE: WeChat is governed by the Tencent End User License Agreement."
	einfo "By using this software you agree to the terms of service."
	einfo ""
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
