# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg git-r3

DESCRIPTION="A powerful and modular stable diffusion GUI and backend (node-based)"
HOMEPAGE="https://github.com/Comfy-Org/ComfyUI"

EGIT_REPO_URI="https://github.com/Comfy-Org/ComfyUI.git"
EGIT_COMMIT="v${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

# System-level runtime deps only — Python packages are installed via pip in a venv.
# - Python: to create the venv and run ComfyUI
# - mesa/libglvnd: OpenGL support for GUI previews
# - libdrm: GPU device access (ROCm/PyTorch needs this)
RDEPEND="
	dev-lang/python
	media-libs/mesa
	media-libs/libglvnd
	x11-libs/libdrm
"

BDEPEND=""

# Git clone needs network
RESTRICT="network-sandbox strip"

S="${WORKDIR}/${P}"

src_install() {
	local appdir="/opt/comfyui"

	dodir "${appdir}"

	# Copy all source files to /opt/comfyui
	cp -a "${S}/." "${ED}${appdir}/" || die "Failed to copy source to ${appdir}"

	# Ensure main.py is readable and executable
	chmod 0755 "${ED}${appdir}/main.py" || die

	# Fix permissions: dirs 755, files 644
	find "${ED}${appdir}" -type d -exec chmod 0755 {} \;
	find "${ED}${appdir}" -type f -exec chmod 0644 {} \;
	find "${ED}${appdir}" -name '*.py' -exec chmod 0755 {} \;

	# Launcher script → /usr/bin/comfyui
	exeinto /usr/bin
	newexe "${FILESDIR}/comfyui-launcher.sh" comfyui || die

	# Desktop entry
	domenu "${FILESDIR}/comfyui.desktop" || die

	# Keep model/custom_nodes dirs writable by users in the 'comfyui' group
	keepdir "${appdir}/models"
	keepdir "${appdir}/custom_nodes"
	keepdir "${appdir}/input"
	keepdir "${appdir}/output"
	keepdir "${appdir}/user"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	einfo ""
	einfo "=================================================================="
	einfo "  ✔ ComfyUI ${PV} has been installed to /opt/comfyui"
	einfo "=================================================================="
	einfo ""
	einfo "  NEXT STEPS — Set up the Python virtual environment:"
	einfo ""
	einfo "  1. Create and enter the venv:"
	einfo "     python3 -m venv /opt/comfyui/venv"
	einfo "     source /opt/comfyui/venv/bin/activate"
	einfo ""
	einfo "  2. Install PyTorch with ROCm 7.2 support (AMD GPU):"
	einfo "     pip3 install torch torchvision \\"
	einfo "       --index-url https://download.pytorch.org/whl/rocm7.2"
	einfo ""
	einfo "  3. Install remaining Python dependencies:"
	einfo "     pip install -r /opt/comfyui/requirements.txt"
	einfo ""
	einfo "  4. (Optional) For NVIDIA GPUs, replace step 2 with:"
	einfo "     pip3 install torch torchvision torchaudio"
	einfo ""
	einfo "  5. Download model checkpoints to /opt/comfyui/models/"
	einfo "     See: https://comfydocs.org/docs/installation/models"
	einfo ""
	einfo "  After setup, launch ComfyUI:"
	einfo "    comfyui"
	einfo "  Or find 'ComfyUI' in Application Menu → Graphics"
	einfo ""
	einfo "  The web UI will be available at: http://127.0.0.1:8188"
	einfo ""
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	einfo ""
	einfo "ComfyUI has been removed from /opt/comfyui."
	einfo "Note: The Python venv and downloaded models were NOT removed."
	einfo "To clean up completely, delete /opt/comfyui manually."
	einfo ""
}
