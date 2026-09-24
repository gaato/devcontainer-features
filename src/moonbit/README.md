# MoonBit (moonbit)

Installs the [MoonBit](https://www.moonbitlang.com/) toolchain from the
upstream binaries, using the official install script and verifying the
binaries against the upstream checksum list.

This feature is not affiliated with the MoonBit team.

## Example usage

```jsonc
"features": {
    "ghcr.io/gaato/devcontainer-features/moonbit:1": {}
}
```

Pin an exact upstream version, or follow the nightly toolchain:

```jsonc
"features": {
    "ghcr.io/gaato/devcontainer-features/moonbit:1": {
        "version": "0.10.14+7d59c7ec9"
    }
}
```

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `version` | string | `latest` | `latest`, `nightly`, or an exact upstream version such as `0.10.14+7d59c7ec9` |
| `installNativeDeps` | boolean | `true` | Install gcc and libc headers for the native backend |

## Notes

`latest` and `nightly` are resolved when the container is built. Rebuilding
without cache picks up a newer toolchain; use an exact version to keep builds
reproducible.

The toolchain is installed to `/usr/local/moon`, exported as `MOON_HOME` and
added to `PATH`. The directory is writable by any user because moon keeps its
registry index and caches there.

The js backend runs output with `node`, which this feature does not install.
Base images such as `mcr.microsoft.com/devcontainers/typescript-node` already
have it; otherwise add the Node feature:

```jsonc
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/gaato/devcontainer-features/moonbit:1": {}
}
```

The [MoonBit VS Code extension](https://marketplace.visualstudio.com/items?itemName=moonbit.moonbit-lang)
is installed automatically.

## OS support

Upstream publishes glibc binaries for `x86_64` and `aarch64`, so Alpine and
other musl-based images are not supported. Missing packages are installed
with apt, dnf, or zypper; on other distributions, install `bash`, `curl`,
`git`, `tar`, `gzip`, CA certificates, and (for the native backend) `gcc`
and libc headers in the base image.

Tested on Debian, Ubuntu, Fedora, and openSUSE Tumbleweed.

## License

The feature scripts are under the
[Blue Oak Model License 1.0.0](../../LICENSE.md). That license does not cover
MoonBit itself. Upstream publishes the sources of
[moon](https://github.com/moonbitlang/moon/blob/main/LICENSE) and
[core](https://github.com/moonbitlang/core/blob/main/LICENSE) under
Apache-2.0, and of the
[compiler](https://github.com/moonbitlang/moonbit-compiler/blob/main/LICENSE.TXT)
under the MoonBit Public Source License.
