# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta package for a complete Chinese input environment with Fcitx5 and Win11-inspired theme"
HOMEPAGE="https://github.com/local/chinese-env"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

# --- Fcitx5 core ---
# app-i18n/fcitx is Fcitx 5 (the package was renamed, binary stays fcitx5)
# cloudpinyin USE flag enables cloud pinyin suggestions
# Only Qt IM module needed — KDE Plasma is Qt-based
RDEPEND="
  app-i18n/fcitx
  app-i18n/fcitx-configtool
  app-i18n/fcitx-chinese-addons[cloudpinyin]
  app-i18n/fcitx-qt
  app-i18n/fcitx-gtk
"

# --- Chinese fonts ---
RDEPEND+="
	media-fonts/noto-cjk
	media-fonts/arphicfonts
	media-fonts/win11-fonts
"

# --- Monospace & terminal fonts ---
# FiraCode: monospace/code editor font
# Ubuntu Font Family: terminal/Konsole font (Ubuntu Mono)
RDEPEND+="
	media-fonts/firacode
	media-fonts/ubuntu-font-family
"

# --- Win11 Fluent theme ---
RDEPEND+="
	x11-themes/fcitx5-win11-theme
"

BDEPEND=""

# No source to fetch, we ship configs from FILESDIR
RESTRICT="strip mirror"

S="${WORKDIR}"

src_install() {
	# --- 1. Install fcitx5 config skeleton to /usr/share ---
	local cfgsrc="${FILESDIR}/fcitx5-config"
	local cfgdest="/usr/share/chinese-env/fcitx5-config"

	insinto "${cfgdest}"
	doins "${cfgsrc}/config" || die "Failed to install fcitx5 config"
	doins "${cfgsrc}/profile" || die "Failed to install fcitx5 profile"

	insinto "${cfgdest}/conf"
	doins "${cfgsrc}/conf/classicui.conf" || die "Failed to install classicui.conf"
	doins "${cfgsrc}/conf/pinyin.conf" || die "Failed to install pinyin.conf"

	# --- 2. Install autostart desktop entry ---
	insinto /etc/xdg/autostart
	doins "${FILESDIR}/fcitx5-autostart.desktop" || die "Failed to install autostart entry"

	# --- 3. Install environment variables ---
	insinto /etc/env.d
	doins "${FILESDIR}/99fcitx" || die "Failed to install env.d config"
}

pkg_postinst() {
	# Update environment
	if command -v env-update &>/dev/null; then
		env-update
	fi

	# --- Configure existing users ---
	local cfg_src="/usr/share/chinese-env/fcitx5-config"
	local user user_home cfg_dir uid gid

	einfo ""
	einfo "Setting up Fcitx5 config for existing users..."

	for user_home in /home/*; do
		[ -d "${user_home}" ] || continue
		user=$(basename "${user_home}")

		# Validate that this is a real user
		id "${user}" &>/dev/null || continue

		cfg_dir="${user_home}/.config/fcitx5"
		mkdir -p "${cfg_dir}" || continue

		# Only copy if files don't exist — never overwrite user's custom config
		if [ ! -f "${cfg_dir}/config" ]; then
			cp "${cfg_src}/config" "${cfg_dir}/config" || true
			einfo "  → Created config for user '${user}'"
		else
			einfo "  → Skipped '${user}' (config already exists)"
		fi

		[ -f "${cfg_dir}/profile" ] || cp "${cfg_src}/profile" "${cfg_dir}/profile" || true

		mkdir -p "${cfg_dir}/conf" || true
		[ -f "${cfg_dir}/conf/classicui.conf" ] || cp "${cfg_src}/conf/classicui.conf" "${cfg_dir}/conf/classicui.conf" || true
		[ -f "${cfg_dir}/conf/pinyin.conf" ] || cp "${cfg_src}/conf/pinyin.conf" "${cfg_dir}/conf/pinyin.conf" || true

		# Fix ownership to the target user
		uid=$(id -u "${user}" 2>/dev/null)
		gid=$(id -g "${user}" 2>/dev/null)
		if [ -n "${uid}" ] && [ -n "${gid}" ]; then
			chown -R "${uid}:${gid}" "${user_home}/.config/fcitx5" 2>/dev/null || true
		fi
	done

	# ====================================================================
	# KDE Font Auto-Configuration
	# ====================================================================
	# Font assignment:
	#   - General UI / desktop:  Microsoft YaHei (win11-fonts)
	#   - Monospace / code:      Fira Code (firacode)
	#   - Terminal / Konsole:    Ubuntu Mono (ubuntu-font-family)
	# ====================================================================

	einfo ""
	einfo "Configuring KDE fonts for existing users..."

	local kdeglobals konsole_profile konsolerc

	for user_home in /home/*; do
		[ -d "${user_home}" ] || continue
		user=$(basename "${user_home}")
		id "${user}" &>/dev/null || continue

		uid=$(id -u "${user}" 2>/dev/null)
		gid=$(id -g "${user}" 2>/dev/null)

		# --- 1. KDE global font settings (~/.config/kdeglobals) ---
		kdeglobals="${user_home}/.config/kdeglobals"
		mkdir -p "${user_home}/.config" || continue

		if [ ! -f "${kdeglobals}" ] || ! grep -q '^\[General\]' "${kdeglobals}" 2>/dev/null; then
			# No existing [General] section — safe to write
			cat >> "${kdeglobals}" <<- 'KDE_FONTS_EOF'
			[General]
			font=Microsoft YaHei,10,-1,5,50,0,0,0,0,0,Regular
			fixed=Fira Code,10,-1,5,50,0,0,0,0,0,Regular
			smallestReadableFont=Microsoft YaHei,8,-1,5,50,0,0,0,0,0,Regular
			toolBarFont=Microsoft YaHei,9,-1,5,50,0,0,0,0,0,Regular
			menuFont=Microsoft YaHei,10,-1,5,50,0,0,0,0,0,Regular
			KDE_FONTS_EOF
			einfo "  → Wrote KDE font defaults for user '${user}'"
		else
			# Existing [General] section — update only if font/fixed not already set
			if ! grep -q '^font=' "${kdeglobals}" 2>/dev/null; then
				sed -i '/^\[General\]/a font=Microsoft YaHei,10,-1,5,50,0,0,0,0,0,Regular' "${kdeglobals}"
			fi
			if ! grep -q '^fixed=' "${kdeglobals}" 2>/dev/null; then
				sed -i '/^\[General\]/a fixed=Fira Code,10,-1,5,50,0,0,0,0,0,Regular' "${kdeglobals}"
			fi
			einfo "  → Merged KDE font settings for user '${user}'"
		fi

		# --- 2. Konsole profile: Ubuntu Mono for terminal ---
		konsole_profile="${user_home}/.local/share/konsole"
		mkdir -p "${konsole_profile}" || continue
		konsole_profile="${konsole_profile}/ChineseEnv.profile"

		if [ ! -f "${konsole_profile}" ]; then
			cat > "${konsole_profile}" <<- 'KONSOLE_PROFILE_EOF'
			[Appearance]
			ColorScheme=BlackOnWhite
			Font=Ubuntu Mono,12,-1,5,50,0,0,0,0,0,Regular

			[General]
			Name=ChineseEnv
			Parent=FALLBACK/

			[Scrolling]
			ScrollBarPosition=2
			KONSOLE_PROFILE_EOF
		fi

		# --- 3. Set ChineseEnv as default Konsole profile ---
		konsolerc="${user_home}/.config/konsolerc"
		if [ ! -f "${konsolerc}" ] || ! grep -q 'DefaultProfile=ChineseEnv' "${konsolerc}" 2>/dev/null; then
			cat >> "${konsolerc}" <<- 'KONSOLERC_EOF'
			[Desktop Entry]
			DefaultProfile=ChineseEnv.profile

			[MainWindow]
			DefaultProfile=ChineseEnv.profile
			KONSOLERC_EOF
			einfo "  → Set Konsole default profile for user '${user}'"
		fi

		# Fix ownership
		if [ -n "${uid}" ] && [ -n "${gid}" ]; then
			chown -R "${uid}:${gid}" "${user_home}/.config/kdeglobals" 2>/dev/null || true
			chown -R "${uid}:${gid}" "${user_home}/.config/konsolerc" 2>/dev/null || true
			chown -R "${uid}:${gid}" "${user_home}/.local/share/konsole" 2>/dev/null || true
		fi
	done

	einfo ""
	einfo "=================================================================="
	einfo "  ✔ Chinese input environment has been installed!"
	einfo "=================================================================="
	einfo ""
	einfo "  What was installed:"
	einfo "    • Fcitx5 input method framework (core, configtool, addons)"
	einfo "    • Qt IM module for KDE/Qt application integration"
	einfo "    • Chinese fonts: Noto CJK, Arphic, Win11 Chinese Simplified"
	einfo "    • Monospace fonts: Fira Code (code editors / IDEs)"
	einfo "    • Terminal fonts: Ubuntu Mono (Konsole / shell)"
	einfo "    • Win11 Fluent Design theme for Fcitx5"
	einfo ""
	einfo "  What was configured:"
	einfo "    • Ctrl+Space  → toggle input method on/off"
	einfo "    • Shift       → switch between Chinese/English (MS Pinyin style)"
	einfo "    • , and .     → page up/down through candidates"
	einfo "    • 5 candidates per page"
	einfo "    • Inline preedit (type at cursor, not in a floating window)"
	einfo "    • Cloud pinyin enabled for better suggestions"
	einfo "    • Auto-start via /etc/xdg/autostart/ (KDE Phase 1)"
	einfo "    • Environment variables: GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS"
	einfo ""
	einfo "  KDE Font auto-configuration:"
	einfo "    • KDE UI font  → Microsoft YaHei 10pt"
	einfo "    • Monospace    → Fira Code 10pt (kdeglobals fixed=)"
	einfo "    • Konsole      → Ubuntu Mono 12pt (ChineseEnv.profile)"
	einfo "    • (existing kdeglobals/konsolerc are merged, not overwritten)"
	einfo ""
	einfo "  Per-user Fcitx5 config files were placed in ~/.config/fcitx5/"
	einfo "  for existing users (existing configs were NOT overwritten)."
	einfo ""
	einfo "  NEXT STEPS for each user:"
	einfo "    1. Log out and log back in (or reboot)."
	einfo "    2. After login, Fcitx5 should auto-start in the system tray."
	einfo "    3. Press Ctrl+Space to activate Chinese input."
	einfo "    4. If the theme doesn't apply, run: fcitx5-configtool"
	einfo "       → Addons → Classic User Interface → Theme → fcitx5-win11-theme"
	einfo ""
}

pkg_postrm() {
	# Remove autostart and env.d files — they are owned by this package
	# so Portage removes them automatically.  We just warn about
	# residual per-user config.

	if [ -d /home ]; then
		einfo ""
		einfo "Note: Per-user Fcitx5 configs in ~/.config/fcitx5/ were"
		einfo "NOT removed.  If you wish to clean up completely, delete"
		einfo "them manually for each user."
		einfo ""
	fi

	if command -v env-update &>/dev/null; then
		env-update
	fi
}
