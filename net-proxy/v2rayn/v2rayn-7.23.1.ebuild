# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg git-r3

DESCRIPTION="A GUI client for Windows, Linux and macOS, support Xray and sing-box"
HOMEPAGE="https://github.com/2dust/v2rayN"

EGIT_REPO_URI="https://github.com/2dust/v2rayN.git"
EGIT_COMMIT="${PV}"
# GlobalHotKeys is a git submodule referenced by the project
EGIT_SUBMODULES=(
	'v2rayN/GlobalHotKeys'
)

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

# Build dependency: .NET 10.0 SDK
# NOTE: If dev-dotnet/dotnet-sdk-10.0 is not yet in the Gentoo tree,
# install it manually before emerging:
#   wget https://dot.net/v1/dotnet-install.sh
#   chmod +x dotnet-install.sh
#   ./dotnet-install.sh --channel 10.0 --install-dir /opt/dotnet
#   export DOTNET_ROOT=/opt/dotnet PATH="/opt/dotnet:${PATH}"
BDEPEND="
	>=dev-dotnet/dotnet-sdk-10.0
"

# Runtime dependencies:
# - Xray / sing-box are the backend proxy cores
# - fontconfig + freetype for Avalonia UI text rendering
# - X11 libs needed by the self-contained .NET runtime
RDEPEND="
	net-proxy/xray
	net-proxy/sing-box
	media-libs/fontconfig
	media-libs/freetype
	x11-libs/libX11
	x11-libs/libICE
	x11-libs/libSM
"

# NuGet restore during build needs network access
RESTRICT="network-sandbox"

S="${WORKDIR}/${P}"

src_prepare() {
	default
}

src_configure() {
	export DOTNET_CLI_TELEMETRY_OPTOUT=1
	export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
	export DOTNET_NOLOGO=1
}

src_compile() {
	local project_dir="v2rayN/v2rayN.Desktop"
	local project_file="${project_dir}/v2rayN.Desktop.csproj"
	local rid="linux-x64"

	# Verify project file
	if [[ ! -f "${project_file}" ]]; then
		project_file=$(find . -maxdepth 4 -name "v2rayN.Desktop.csproj" -print -quit)
		[[ -n "${project_file}" ]] || die "Cannot locate v2rayN.Desktop.csproj"
		project_dir=$(dirname "${project_file}")
	fi

	einfo "Project: ${project_file}"
	einfo "Target RID: ${rid}"

	# Clean & restore
	dotnet clean "${project_file}" -c Release || die "dotnet clean failed"
	rm -rf "${project_dir}/bin/Release" || true

	einfo "Restoring NuGet packages..."
	dotnet restore "${project_file}" || die "dotnet restore failed"

	# Publish self-contained
	einfo "Publishing (this may take a while)..."
	dotnet publish "${project_file}" \
		-c Release \
		-r "${rid}" \
		-p:PublishSingleFile=false \
		-p:SelfContained=true \
		-p:UseAppHost=true \
		|| die "dotnet publish failed"
}

src_install() {
	local project_dir="v2rayN/v2rayN.Desktop"
	local project_file="${project_dir}/v2rayN.Desktop.csproj"
	local rid="linux-x64"
	local publish_dir

	if [[ ! -f "${project_file}" ]]; then
		project_file=$(find . -maxdepth 4 -name "v2rayN.Desktop.csproj" -print -quit)
		[[ -n "${project_file}" ]] || die "Cannot locate project file"
		project_dir=$(dirname "${project_file}")
	fi

	publish_dir="${project_dir}/bin/Release/net10.0/${rid}/publish"

	if [[ ! -d "${publish_dir}" ]]; then
		publish_dir=$(find "${project_dir}/bin/Release" -type d -name "publish" -print -quit)
		[[ -n "${publish_dir}" ]] || die "Publish output not found"
	fi

	einfo "Installing from: ${publish_dir}"

	# /opt/v2rayN
	local appdir="/opt/v2rayN"
	dodir "${appdir}"
	cp -a "${publish_dir}/." "${ED}${appdir}/" || die "cp failed"

	# Fix permissions
	find "${ED}${appdir}" -type d -exec chmod 0755 {} \;
	find "${ED}${appdir}" -type f -exec chmod 0644 {} \;
	for exe in v2rayN v2rayN.Desktop; do
		[[ -f "${ED}${appdir}/${exe}" ]] && chmod 0755 "${ED}${appdir}/${exe}"
	done

	# Launcher → /usr/bin/v2rayn
	exeinto /usr/bin
	newexe "${FILESDIR}/v2rayn-launcher.sh" v2rayn

	# Desktop entry
	domenu "${FILESDIR}/v2rayn.desktop"

	# App icon
	local icon_src="${project_dir}/v2rayN.png"
	[[ -f "${icon_src}" ]] && newicon -s 256 "${icon_src}" v2rayn.png

	# Keep core binary dirs (user places xray / sing-box there or they use PATH)
	keepdir "${appdir}/bin/xray"
	keepdir "${appdir}/bin/sing_box"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	einfo ""
	einfo "✔ v2rayN ${PV} installed to /opt/v2rayN"
	einfo ""
	einfo "Backend cores (install at least one):"
	einfo "  emerge net-proxy/xray       # Xray core"
	einfo "  emerge net-proxy/sing-box   # sing-box core"
	einfo ""
	einfo "Launch:  v2rayn  (or find v2rayN in Application Menu → Network)"
	einfo ""
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
