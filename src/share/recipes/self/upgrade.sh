#! /bin/sh
#: Upgrade mash core.

import logging

# TODO: Some refactoring would be great to have in near furture:
#  - have the section for determining the latest version be a fuction
#    called with base project URL (https://github.com/ya55en/mashmallow-0
#    in this case) and a regexp for extracting the version ('v\(.*\)$' in
#    this case);
#  - get version variables renamed and double-quoted (following SC2086).

V=$(mash --version)
curr_version=${V#*v}

_URL_LATEST=https://github.com/ya55en/mashmallow-0/releases/latest
_URL_DOWNLOAD_RE='^location: https://github.com/ya55en/mashmallow-0/releases/tag/v\(.*\)$'
latest_version=$(curl -ISs $_URL_LATEST | grep ^location | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")

_DOWNLOAD_CACHE=/tmp
_INSTALL_FILENAME="install.sh"
# TODO: switch to main when stable.
# _URL_DOWNLOAD="https://github.com/ya55en/mashmallow-0/raw/main/src/install.sh"
_URL_DOWNLOAD="https://github.com/ya55en/mashmallow-0/raw/48-mash-upgrade/src/install.sh"

check_version() {
    #: Check if the current version is the latest (nothing to do) or not (needs upgrade).

    if [ "${curr_version}" = "${latest_version}" ]; then
        echo "Already up to date." && exit 0
    else
        echo "An update is available - v${latest_version}"
        _info "Downloading ..."
    fi
}

download_update() {
    #: Download the gzipped archive, as well as install.sh from the main branch;

    _info "Updating to v${latest_version}"

    target_file_path="${_DOWNLOAD_CACHE}/${_INSTALL_FILENAME}"
    echo "update_mash(): target_file_path=${target_file_path}"

    if [ -e "${target_file_path}" ]; then
        _info "install.sh already downloaded, overriding."
    else
        _info "Downloading ${target_file_path}..."
    fi
    curl -sSL "$_URL_DOWNLOAD" -o "${target_file_path}" ||
        die 9 "Download failed. (URL: $_URL_DOWNLOAD)"
    chmod 764 "${_DOWNLOAD_CACHE}/${_INSTALL_FILENAME}"
}

install_update() {
    #: Execute install.sh with exec thus terminating mash itself.

    _warn "Installing update."
    sleep 3s
    exec /tmp/install.sh

    # install.sh on its turn will remove the existing installation
    # and install the downloaded one.
}

doit() {
    _info "Mash current version: v${curr_version}"
    _info "Mash latest version: v${latest_version}"
    check_version
    download_update
    install_update
}

undo() {
    echo "We do not support 'undo upgrade' yet..."
}

$mash_action
