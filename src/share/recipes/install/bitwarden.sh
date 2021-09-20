#! /bin/sh

# set -x

# Assumming lib/libma.sh has been sourced already.


_ARCH=x86_64
_LOCAL="$HOME/.local"

# Install Bitwarden
_URL_LATEST=https://github.com/bitwarden/desktop/releases/latest
_URL_DOWNLOAD_RE='^location: https://github.com/bitwarden/desktop/releases/tag/v\(.*\)$'
version=$(curl -Is $_URL_LATEST | grep ^location | tr -d '\n\r' | sed  "s|$_URL_DOWNLOAD_RE|\1|")
if [ x"$version" = x ]; then die 3 'Failed to get Bitwarden latest version'; fi

log debug "version=[$version]"

_URL_DOWNLOAD="https://github.com/bitwarden/desktop/releases/download/v${version}/Bitwarden-${version}-${_ARCH}.AppImage"

log debug "_URL_DOWNLOAD=[$_URL_DOWNLOAD]"

# Download and install:
log info "Downloading Bitwarden desktop v${version}..."
mkdir -p "$_LOCAL/opt/bitwarden"
# curl -sL "$_URL_DOWNLOAD" -o $_LOCAL/opt/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage__OFF

# TODO: check sha512 from https://github.com/bitwarden/desktop/releases/download/v1.28.2/latest-linux.yml

# mv -f "$_LOCAL/opt/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage__OFF" "$_LOCAL/opt/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage"
chmod +x "$_LOCAL/opt/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage"
ln -fs "$_LOCAL/opt/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage" "$_LOCAL/bin/bitwarden-desktop"
cp -p "${_ICONS_DIR}/bitwarden-icon.png" "${_LOCAL}/opt/bitwarden/bitwarden-icon.png"

# shellcheck disable=SC1090
. "$_APPLICATIONS_DIR/com.bitwarden.desktop" > "${_LOCAL}/share/applications/com.bitwarden.desktop"
# /home/yassen/Work/mashmallow-0.1/src/share/applications/com.bitwarden.desktop

    cat << EOS

Completed. You can use Bitwarden Desktop App instantly, like:

  $ bitwarden-desktop

Enjoy! ;)

EOS
