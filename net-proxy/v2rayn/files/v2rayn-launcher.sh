#!/usr/bin/env bash
# Launcher script for v2rayN on Gentoo Linux
set -euo pipefail

APP_DIR="/opt/v2rayN"

# Change to the application directory
cd "${APP_DIR}" || {
	echo "Error: v2rayN application directory not found: ${APP_DIR}" >&2
	exit 1
}

# Try to find and execute the main binary
if [[ -x "${APP_DIR}/v2rayN" ]]; then
	exec "${APP_DIR}/v2rayN" "$@"
fi

if [[ -f "${APP_DIR}/v2rayN" ]]; then
	exec "${APP_DIR}/v2rayN" "$@"
fi

# Fallback: use dotnet to run the DLL
for dll in v2rayN.Desktop.dll v2rayN.dll; do
	if [[ -f "${APP_DIR}/${dll}" ]]; then
		exec /usr/bin/dotnet "${APP_DIR}/${dll}" "$@"
	fi
done

echo "v2rayN launcher: no executable found in ${APP_DIR}" >&2
ls -l "${APP_DIR}" >&2 || true
exit 1
