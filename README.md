# devcontainer-features

[![Test](https://github.com/gaato/devcontainer-features/actions/workflows/test.yaml/badge.svg)](https://github.com/gaato/devcontainer-features/actions/workflows/test.yaml)
[![License](https://img.shields.io/github/license/gaato/devcontainer-features)](LICENSE.md)

[Dev Container Features](https://containers.dev/implementors/features/)
published to `ghcr.io/gaato/devcontainer-features`.

| Feature | Description |
|---|---|
| [moonbit](src/moonbit) | MoonBit toolchain from upstream binaries |

For a ready-made MoonBit image, see
[gaato/moonbit-docker](https://github.com/gaato/moonbit-docker).

## Development

Run the tests locally with the pinned devcontainer CLI:

```fish
mise install
devcontainer features test -f moonbit -i debian:trixie .
```

`devcontainer features test` has no `--docker-path` option. To use Podman,
put a `docker` symlink to it first on `PATH`:

```fish
mkdir -p /tmp/podman-shim; and ln -sf (command -v podman) /tmp/podman-shim/docker
env PATH="/tmp/podman-shim:$PATH" devcontainer features test -f moonbit .
```

Publish with the Release workflow after bumping `version` in
`devcontainer-feature.json`. New upstream MoonBit releases need no
publication.
