#!/usr/bin/env bash

# Runs the plugin scripts from the working copy inside Linux containers of
# several architectures, to check that the right zoxide binary is picked.
# Non-native platforms run under Docker's QEMU emulation.

set -euo pipefail

plugin_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

platforms=(linux/amd64 linux/arm64 linux/arm/v7 linux/386)

# shellcheck disable=SC2016 # Expanded inside the container.
test_script='
set -euo pipefail
apt-get update -qq
apt-get install -y -qq --no-install-recommends ca-certificates curl git >/dev/null
cd /plugin
echo "Versions: $(bin/list-all)"
export ASDF_INSTALL_TYPE=version
export ASDF_INSTALL_VERSION="$(bin/latest-stable "")"
export ASDF_DOWNLOAD_PATH=/tmp/download
export ASDF_INSTALL_PATH=/tmp/install
bin/download
bin/install
"$ASDF_INSTALL_PATH/bin/zoxide" --version
'

for platform in "${platforms[@]}"; do
	echo "=== $platform"
	docker run --rm --platform "$platform" -v "$plugin_dir:/plugin:ro" \
		debian:stable-slim bash -c "$test_script"
done

echo "=== All platforms passed"
