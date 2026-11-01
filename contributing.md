# Contributing

## Running the scripts directly

The plugin scripts are driven by environment variables, so each one can be run
on its own without asdf. The `sandbox` directory is a scratch area for this; its
contents are git-ignored and the scripts create the directories they need, so
there is nothing to set up first.

```shell
# List the installable versions
./bin/list-all

# Resolve the latest stable version
./bin/latest-stable ""

# Download 0.10.0 for this machine's platform into sandbox/download
ASDF_INSTALL_VERSION=0.10.0 \
  ASDF_DOWNLOAD_PATH=./sandbox/download \
  ./bin/download

# Install what the previous step downloaded, into sandbox/install.
# bin/install never downloads; it only copies from ASDF_DOWNLOAD_PATH, so the
# download above has to have succeeded and use the same path.
ASDF_INSTALL_TYPE=version \
  ASDF_INSTALL_VERSION=0.10.0 \
  ASDF_DOWNLOAD_PATH=./sandbox/download \
  ASDF_INSTALL_PATH=./sandbox/install \
  ./bin/install

# Check what was installed
./sandbox/install/bin/zoxide --version

# Start over
rm -rf sandbox/download sandbox/install
```

## Testing other architectures with Docker

zoxide ships a different binary for each platform. `scripts/docker-test.bash`
mounts the working copy into `debian:stable-slim` containers for `linux/amd64`,
`linux/arm64`, `linux/arm/v7` and `linux/386`. In each one it runs `bin/list-all`,
`bin/latest-stable`, `bin/download` and `bin/install`, then `zoxide --version`:

```shell
scripts/docker-test.bash
```

The non-native platforms run under QEMU emulation, which Docker Desktop
provides out of the box. Each container prints the release target it
downloaded, e.g. `i686-unknown-linux-musl` for `linux/386`. The scripts are
called directly rather than through asdf, so the test works before anything is
committed or pushed.

## Testing with asdf

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test zoxide https://github.com/martonsz/asdf-zoxide.git "zoxide --version"
```

To test the working copy rather than the pushed repo, add the plugin from a
local path:

```shell
asdf plugin add zoxide "$PWD"
asdf install zoxide 0.10.0
asdf plugin remove zoxide
```

Tests are automatically run in GitHub Actions on push and PR.

## Running the workflows locally with act

[act](https://github.com/nektos/act) runs the GitHub Actions workflows locally:

```shell
act -j lint
act -j plugin_test
```

On an Apple Silicon Mac the defaults do not work. Put these flags in `.actrc`
in the repository root (the file is git-ignored, so it stays local):

```text
--container-architecture linux/amd64
--container-daemon-socket=unix:///var/run/docker.sock
```

`--container-architecture linux/amd64` is needed because the runner images act
uses are amd64 only.

`--container-daemon-socket -` turns off mounting the Docker socket into the job
container. This is likely specific to Rancher Desktop: its socket lives on the
macOS side at `~/.rd/docker.sock` and the Linux VM cannot bind-mount it, so the
job fails with `operation not supported`. Docker Desktop may not need this flag.

Rancher Desktop on macOS also requires `DOCKER_HOST` to be set, because it does
not use `/var/run/docker.sock`:

```shell
export DOCKER_HOST="unix://$HOME/.rd/docker.sock"
```

That matters doubly here: act uses the container daemon socket to find the
daemon as well as to mount it, so with `--container-daemon-socket -` it falls
back to `/var/run/docker.sock` and cannot connect unless `DOCKER_HOST` says
otherwise.

Two things to expect when running `plugin_test`: act skips the `macos-latest`
leg of the matrix, and `asdf plugin test` clones the plugin from GitHub rather
than from the working copy, so it tests the pushed branch.
