#!/usr/bin/env bash
# Launcher script for ComfyUI on Gentoo Linux
#
# Uses the Python virtual environment at /opt/comfyui/venv if present.
# Falls back to system python3 if the venv does not exist.
set -euo pipefail

APP_DIR="/opt/comfyui"
VENV_DIR="${APP_DIR}/venv"
VENV_PYTHON="${VENV_DIR}/bin/python3"
VENV_PIP="${VENV_DIR}/bin/pip3"

# If venv doesn't exist yet, print helpful setup instructions
if [[ ! -f "${VENV_PYTHON}" ]]; then
	echo "============================================" >&2
	echo "  ComfyUI venv not found!" >&2
	echo "============================================" >&2
	echo "" >&2
	echo "Please set up the Python virtual environment first:" >&2
	echo "" >&2
	echo "  # 1. Create venv" >&2
	echo "  python3 -m venv ${VENV_DIR}" >&2
	echo "" >&2
	echo "  # 2. Activate" >&2
	echo "  source ${VENV_DIR}/bin/activate" >&2
	echo "" >&2
	echo "  # 3. Install PyTorch (ROCm 7.2 for AMD GPU):" >&2
	echo "  pip3 install torch torchvision \\" >&2
	echo "    --index-url https://download.pytorch.org/whl/rocm7.2" >&2
	echo "" >&2
	echo "  # 4. Install remaining deps:" >&2
	echo "  pip install -r ${APP_DIR}/requirements.txt" >&2
	echo "" >&2
	echo "  # 5. Then launch ComfyUI again" >&2
	echo "" >&2
	exit 1
fi

# Change to the application directory
cd "${APP_DIR}" || {
	echo "Error: ComfyUI directory not found: ${APP_DIR}" >&2
	exit 1
}

# Run ComfyUI with the venv python
exec "${VENV_PYTHON}" "${APP_DIR}/main.py" "$@"
