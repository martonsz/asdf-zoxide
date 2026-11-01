# asdf-zoxide [![Build](https://github.com/martonsz/asdf-zoxide/actions/workflows/build.yml/badge.svg)](https://github.com/martonsz/asdf-zoxide/actions/workflows/build.yml) [![Lint](https://github.com/martonsz/asdf-zoxide/actions/workflows/lint.yml/badge.svg)](https://github.com/martonsz/asdf-zoxide/actions/workflows/lint.yml)

[zoxide](https://github.com/ajeetdsouza/zoxide) plugin for the [asdf version manager](https://asdf-vm.com).

## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Versions](#versions)
- [Supported platforms](#supported-platforms)
- [How it works](#how-it-works)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

- `bash`, `curl`, `git`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).

zoxide itself has no runtime dependencies: the Linux releases are static musl
binaries.

## Install

Plugin:

```shell
asdf plugin add zoxide https://github.com/martonsz/asdf-zoxide.git
```

zoxide:

```shell
# Show all installable versions
asdf list all zoxide

# Install specific version
asdf install zoxide latest

# Set a version in ~/.tool-versions
asdf set -u zoxide latest

# Now zoxide commands are available
zoxide --version
```

zoxide still has to be hooked into your shell, as described in the
[zoxide readme](https://github.com/ajeetdsouza/zoxide#installation). For
example, add this to the end of `~/.bashrc`:

```shell
eval "$(zoxide init bash)"
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Versions

`asdf list all zoxide` lists the release tags from the
[zoxide repository](https://github.com/ajeetdsouza/zoxide), oldest first, with
the leading `v` removed.

Only zoxide `0.8.2` and newer are listed: from that release on, the release
assets are named `zoxide-<version>-<target>.tar.gz`, which is what this plugin
downloads. Older releases used other naming schemes and are not supported.

## Supported platforms

zoxide publishes a separate binary for each platform. The plugin picks the
release asset from `uname -s` and `uname -m`, following the logic of the
[official install script](docs/zoxide-install.sh):

| OS      | `uname -m`         | Release target                    |
| :------ | :----------------- | :-------------------------------- |
| Linux   | `x86_64`           | `x86_64-unknown-linux-musl`       |
| Linux   | `i386`..`i686`     | `i686-unknown-linux-musl`         |
| Linux   | `aarch64`          | `aarch64-unknown-linux-musl`      |
| Linux   | `armv7l`, `armv8l` | `armv7-unknown-linux-musleabihf`  |
| Linux   | `armv6l`, `arm`    | `arm-unknown-linux-musleabihf`    |
| Linux   | `riscv64`          | `riscv64gc-unknown-linux-musl`    |
| macOS   | `x86_64`           | `x86_64-apple-darwin`             |
| macOS   | `arm64`            | `aarch64-apple-darwin`            |
| Android | `aarch64`          | `aarch64-linux-android`           |
| Android | `armv7l`, `armv8l` | `armv7-linux-androideabi`         |

On Linux, a 32-bit userland on a 64-bit kernel (for example a `linux/386`
container on an amd64 host) is detected and gets the 32-bit binary.

Not every target exists for every version: `i686` binaries start at 0.9.5
and `riscv64gc` at 0.10.0. Installing a version that has no binary for your
platform fails with the URL that was tried.

## How it works

### /bin/download

`bin/download` fetches `zoxide-<version>-<target>.tar.gz` from the release
assets and extracts it into `ASDF_DOWNLOAD_PATH`. The tarball contains the
`zoxide` binary, man pages, and shell completions.

The tarball is downloaded and extracted in a scratch directory first and only
moved into place once that succeeds, so a failed download leaves
`ASDF_DOWNLOAD_PATH` empty.

### /bin/install

`bin/install` runs `zoxide --version` on the downloaded binary and only then
copies it into the install path, so a binary that cannot run leaves the install
path untouched. asdf creates the `zoxide` shim from the `bin` directory:

```text
$ASDF_INSTALL_PATH/
  bin/zoxide
  man/man1/zoxide*.1
  completions/
```

Only `version` installs are supported, not `ref` installs.

All scripts can be run on their own against the `sandbox` directory, and
`scripts/docker-test.bash` runs them in containers of several architectures;
see the [contributing guide](contributing.md).

## Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/martonsz/asdf-zoxide/graphs/contributors)!

## License

See [LICENSE](LICENSE) © [Marton Szucs](https://github.com/martonsz/)
