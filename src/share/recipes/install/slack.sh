#!/bin/sh

import os
import removal

case "$_OS_ARCH" in
x86_64)
    _slk__special_arch=x64
    ;;
*)
    die 33 "CPU architecture $_OS_ARCH is NOT supported"
    ;;
esac

# Download URL:
# https://downloads.slack-edge.com/releases/linux/4.20.0/prod/x64/slack-desktop-4.20.0-amd64.deb

_slk__version='4.20.0'
_slk__filename="slack-desktop-${_slk__version}-${_OS_ARCH_SHORT}.deb"
_slk__download_url="https://downloads.slack-edge.com/releases/linux/${_slk__version}/prod/${_slk__special_arch}/${_slk__filename}"

#: Download into a cache folder.
download_deb_file() {
    if [ -e "$_DOWNLOAD_CACHE/$_slk__filename" ]; then
        _warn "DEB file already downloaded, skipping ($_DOWNLOAD_CACHE/$_slk__filename)"
    else
        _info "Downloading $_slk__filename..."
        mkdir -p "$_DOWNLOAD_CACHE"
        [ -d "$_DOWNLOAD_CACHE" ] || {
            die 33 "Could NOT create download directory! ($_DOWNLOAD_CACHE)"
        }
        _debug "Downloading [$_slk__download_url]..."
        curl -sSL "$_slk__download_url" -o "$_DOWNLOAD_CACHE/$_slk__filename" || {
            die 33 "$_slk__filename download FAILED! (rc=$?)"
        }
        [ -e "$_DOWNLOAD_CACHE/$_slk__filename" ] || {
            die 33 "DEB file NOT found in download cache! ($_DOWNLOAD_CACHE/$_slk__filename)"
        }
        _debug "Downloaded [$_slk__filename] from [$_slk__download_url]"
    fi
}

#: Install the .deb package file.
install_deb_file() {
    _info "Installing (using apt) $_slk__filename..."

    # Will bring up this warning (which is harmless and can be ignored):
    # N: Download is performed unsandboxed as root as file '$_DOWNLOAD_CACHE/$_slk__filename'
    # couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
    sudo apt-get install -y "$_DOWNLOAD_CACHE/$_slk__filename"
    _debug "Installed $_slk__filename from [$_DOWNLOAD_CACHE/$_slk__filename]"
}

doit() {
    download_deb_file
    install_deb_file
    _info 'DONE.'
}

undo() {
    _info "Removing slack-desktop:"
    apt_remove slack-desktop
    _info 'slack-desktop removed successfully.'
}

# shellcheck disable=SC2154
$mash_action
