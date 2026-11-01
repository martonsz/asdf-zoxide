#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/ajeetdsouza/zoxide"
TOOL_NAME="zoxide"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+_-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	# Only zoxide 0.8.2 and newer name their release assets
	# zoxide-<version>-<target>.tar.gz, which is what this plugin downloads.
	list_github_tags | awk -F. '$1 > 0 || $2 > 8 || ($2 == 8 && $3 >= 2)'
}

# Prints 32 or 64 depending on the ELF class of the running userland, which can
# differ from the kernel reported by uname -m (e.g. a 32-bit container).
get_bitness() {
	local exe_head
	exe_head=$(head -c 5 /proc/self/exe)
	if [ "$exe_head" = "$(printf '\177ELF\001')" ]; then
		echo 32
	elif [ "$exe_head" = "$(printf '\177ELF\002')" ]; then
		echo 64
	else
		fail "Could not detect platform bitness"
	fi
}

# Prints the Rust target triple of the zoxide release asset for this machine.
# Adapted from get_architecture() in the official zoxide install script.
get_target() {
	local os cpu
	os="$(uname -s)"
	cpu="$(uname -m)"

	case "$os" in
	Linux)
		if [ "$(uname -o 2>/dev/null || true)" = Android ]; then
			os=linux-android
		else
			os=unknown-linux-musl
			if [ "$(get_bitness)" = 32 ]; then
				case "$cpu" in
				x86_64 | amd64) cpu=i686 ;;
				aarch64 | arm64) cpu=armv7l ;;
				esac
			fi
		fi
		;;
	Darwin) os=apple-darwin ;;
	*) fail "Unsupported OS: $os" ;;
	esac

	case "$cpu" in
	x86_64 | amd64) cpu=x86_64 ;;
	i386 | i486 | i586 | i686) cpu=i686 ;;
	aarch64 | arm64) cpu=aarch64 ;;
	armv7l | armv8l)
		cpu=armv7
		if [ "$os" = linux-android ]; then os=linux-androideabi; else os="${os}eabihf"; fi
		;;
	armv6l | arm)
		cpu=arm
		os="${os}eabihf"
		;;
	riscv64) cpu=riscv64gc ;;
	*) fail "Unsupported CPU: $cpu" ;;
	esac

	echo "${cpu}-${os}"
}

download_release() {
	local version filename target url
	version="$1"
	filename="$2"
	target="$(get_target)"

	url="$GH_REPO/releases/download/v${version}/${TOOL_NAME}-${version}-${target}.tar.gz"

	echo "* Downloading $TOOL_NAME release $version for $target..."
	curl "${curl_opts[@]}" -o "$filename" "$url" ||
		fail "Could not download $url ($TOOL_NAME $version may not be built for $target)"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}"
	local download_file="$ASDF_DOWNLOAD_PATH/$TOOL_NAME"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	# Run the binary from the download directory first, so nothing is placed in
	# the install path until the version is known to work.
	test -x "$download_file" ||
		fail "No executable $TOOL_NAME at $download_file. Run bin/download with the same ASDF_DOWNLOAD_PATH first."
	"$download_file" --version >/dev/null 2>&1 ||
		fail "Could not run $download_file."

	{
		mkdir -p "$install_path/bin" &&
			cp "$download_file" "$install_path/bin/$TOOL_NAME" &&
			chmod +x "$install_path/bin/$TOOL_NAME" &&
			cp -R "$ASDF_DOWNLOAD_PATH/man" "$ASDF_DOWNLOAD_PATH/completions" "$install_path/"
	} || {
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	}

	echo "$TOOL_NAME $version installation was successful!"
}
