#! /bin/sh

# set -x

import logging
import gh-download
# Assumming lib/libma.sh has been sourced already.

_ARCH=x86_64

# Install Wire
DEBUG=true

download_appimage() {
    #: Download and install the app image

    _debug "download_target=[$download_target]"
    if [ -e "${download_target}" ]; then
        _warn "App file already downloaded/cached, skipping."
    else
        _info "Downloading Wire desktop v${version}..."
        curl -sL "$_URL_DOWNLOAD" -o "${download_target}"
    fi
}

check_hashsum() {
    #: Check the app image file hashsum.

    # TODO: check sha512
    true
}

install_app_image() {
    if [ -e "${app_fullpath}" ]; then
        _warn "Installed app file already exists, skipping. (${app_fullpath})"
    else
        _info "Installing app file ... (${app_fullpath})"
        mkdir -p "${_LOCAL}/share/applications"
        mkdir -p "$_LOCAL/opt/wire"
        cp -p "${download_target}" "${app_fullpath}"
        chmod +x "${app_fullpath}"
        ln -fs "${app_fullpath}" "$_LOCAL/bin/wire-desktop"
    fi
}

setup_gnome_assets() {
    #: Create/copy .desktop file and an icon.
    # Copy of their original .desktop file into /share/applications/
    # We still have our own .desktop by the name com.wire.desktop but it is opsolete now.

    [ -e "${_LOCAL}/share/applications/appimagekit-wire-desktop.desktop" ] # && [ -e "${_LOCAL}/opt/wire/${icon_file}" ]

    if [ $? = 0 ]; then
        _info "Gnome assets already installed, skipping."
    else
        _info "Installing gnome assets ..."
        # shellcheck disable=SC1090
        . "$_APPLICATIONS_DIR/appimagekit-wire-desktop.desktop" > "${_LOCAL}/share/applications/appimagekit-wire-desktop.desktop"
        # cp -p "${_ICONS_DIR}/${icon_file}" "${_LOCAL}/opt/wire/${icon_file}"
    fi
}

inform_user() {
    cat << EOS

Completed. You can use Wire Desktop App instantly, like:

  $ wire-desktop

Enjoy! ;)

EOS
}

doit() {
    _info "** Installing Wire:"
    download_appimage
    check_hashsum
    install_app_image
    setup_gnome_assets
    inform_user
}

undo() {
    _info "** Un-installing Wire:"

    local result=''

    # Remove gnome assets
    _info "Removing gnome assets..."
    # rm -f "${_ICONS_DIR}/${icon_file}"
    result="${result}:$?"
    rm -f "${_LOCAL}/share/applications/appimagekit-wire-desktop.desktop"
    result="${result}:$?"

    # Remove symlink
    _info "Removing symlink..."
    rm -f "$_LOCAL/bin/wire-desktop"
    result="${result}:$?"

    # Remove app image file
    _info "Removing wire app image..."
    rm -f "${app_fullpath}"
    result="${result}:$?"

    if [ "$result" = ':0:0:0:0' ]; then
        _info "Successfully un-installed wire."
    else
        _warn "Un-installed wire with errors: codes [${result}]"
    fi
}

main() {
    local version
    local app_file
    local app_fullpath
    local download_target

    version='3.26.2941'
    app_file="Wire-${version}_${_ARCH}.AppImage"
    app_fullpath="$_LOCAL/opt/wire/${app_file}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    # local icon_file
    # icon_file="wire-icon-dark-128.png"

    # https://wire-app.wire.com/linux/Wire-3.26.2941_x86_64.AppImage
    _URL_DOWNLOAD="https://wire-app.wire.com/linux/${app_file}"
    _debug "_URL_DOWNLOAD=[$_URL_DOWNLOAD]"
    _debug "version=[$version]"

    # shellcheck disable=2154
    $mash_action
}

main
