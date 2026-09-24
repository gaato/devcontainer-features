#!/bin/sh
# POSIX sh so unsupported images (Alpine without bash) get a clear error
# instead of "not found".
set -eu

VERSION="${VERSION:-latest}"
INSTALLNATIVEDEPS="${INSTALLNATIVEDEPS:-true}"
# Must match containerEnv in devcontainer-feature.json.
MOON_HOME=/usr/local/moon

die() {
    echo "moonbit feature: $*" >&2
    exit 1
}

[ "$(id -u)" -eq 0 ] || die "must run as root"

case "$(uname -m)" in
    x86_64 | aarch64) ;;
    *) die "unsupported architecture $(uname -m); upstream publishes x86_64 and aarch64" ;;
esac

# Upstream binaries are linked against glibc.
if [ -e /etc/alpine-release ] || ldd --version 2>&1 | grep -qi musl; then
    die "musl-based images are not supported; upstream binaries require glibc"
fi

# Reject anything else so the value cannot alter the download URL.
case "$VERSION" in
    latest | nightly) ;;
    *)
        printf '%s\n' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\+[0-9a-f]+$' \
            || die "invalid version '$VERSION'; use latest, nightly, or an exact version such as 0.10.14+7d59c7ec9"
        ;;
esac

if command -v apt-get >/dev/null 2>&1; then
    pm=apt libc_dev=libc6-dev
elif command -v dnf >/dev/null 2>&1; then
    pm=dnf libc_dev=glibc-devel
elif command -v microdnf >/dev/null 2>&1; then
    pm=microdnf libc_dev=glibc-devel
elif command -v zypper >/dev/null 2>&1; then
    pm=zypper libc_dev=glibc-devel
else
    pm="" libc_dev=libc-dev
fi

packages=""
need() {
    # need COMMAND PACKAGE
    command -v "$1" >/dev/null 2>&1 || packages="$packages $2"
}
need bash bash
need curl curl
need git git
need tar tar
need gzip gzip
need sha256sum coreutils
# Debian, Fedora, and openSUSE bundle paths respectively.
[ -e /etc/ssl/certs/ca-certificates.crt ] || [ -e /etc/pki/tls/certs/ca-bundle.crt ] \
    || [ -e /etc/ssl/ca-bundle.pem ] || packages="$packages ca-certificates"
if [ "$INSTALLNATIVEDEPS" = "true" ]; then
    need gcc gcc
    [ -e /usr/include/stdio.h ] || packages="$packages $libc_dev"
fi

if [ -n "$packages" ]; then
    # shellcheck disable=SC2086
    case "$pm" in
        apt)
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y --no-install-recommends $packages
            rm -rf /var/lib/apt/lists/*
            ;;
        dnf | microdnf)
            "$pm" install -y --setopt=install_weak_deps=0 $packages
            "$pm" clean all
            ;;
        zypper)
            zypper --non-interactive install --no-recommends $packages
            zypper clean --all
            ;;
        *)
            die "missing packages:$packages; install them in the base image (apt, dnf, and zypper are handled automatically)"
            ;;
    esac
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL https://cli.moonbitlang.com/install/unix.sh -o "$tmp/install.sh"
# A scratch HOME and a shell it does not recognize keep the upstream script
# from editing root's shell rc files; containerEnv sets PATH instead.
HOME="$tmp" SHELL=/bin/sh MOON_HOME="$MOON_HOME" MOONBIT_INSTALL_VERSION="$VERSION" \
    bash "$tmp/install.sh"

# Verify the installed binaries against the upstream checksum list.
url_version="$(printf '%s' "$VERSION" | sed 's/+/%2B/g')"
curl -fsSL "https://cli.moonbitlang.com/binaries/${url_version}/moonbit-linux-$(uname -m).sha256" \
    | (cd "$MOON_HOME/bin" && sha256sum -c --quiet -)

# moon writes its registry index and caches under MOON_HOME, and the remote
# user's UID may be changed after build (updateRemoteUserUID).
chmod -R a+rwX "$MOON_HOME"

PATH="$MOON_HOME/bin:$PATH" moon version --all
