#!/bin/sh

#: Install KeePassXC
#: Home: https://keepassxc.org/
#: Downloads: https://keepassxc.org/download/
#: Github: https://github.com/keepassxreboot/keepassxc/

import os
import logging
import gh-download

#: Download the app image
download_appimage() {
    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path} app-image ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

#: Check the app image file hashsum.
check_hashsum() {
    # TODO: check hash sum, possibly signature
    true
}

install_app_image() {
    if [ -e "${app_fullpath}" ]; then
        _warn "Installed app file already exists, skipping. (${app_fullpath})"
    else
        _info "Installing app file ... (${app_fullpath})"
        mkdir -p "$_LOCAL/opt/keepassxc"
        cp -p "${download_target}" "${app_fullpath}"
        chmod +x "${app_fullpath}"
        ln -fs "${app_fullpath}" "$_LOCAL/bin/keepassxc"
    fi
}

setup_gnome_assets() {
    #: Create/copy .desktop file and an icon.
    keepassxc_icon='keepassxc-icon.png'

    [ -e "${_LOCAL}/share/applications/org.keepassxc.desktop" ] && [ -e "${_LOCAL}/opt/keepassxc/${keepassxc_icon}" ]

    if [ $? = 0 ]; then
        _info "Gnome assets already installed, skipping."
    else
        _info "Installing gnome assets ..."
        mkdir -p "${_LOCAL}/share/applications"
        # shellcheck disable=SC1091
        . "$_APPLICATIONS_DIR/org.keepassxc.desktop" > "${_LOCAL}/share/applications/org.keepassxc.desktop"
        cp -p "${_ICONS_DIR}/${keepassxc_icon}" "${_LOCAL}/opt/keepassxc/${keepassxc_icon}"
    fi
}

inform_user() {
    cat << EOS

Completed. You can use KeePassXC App instantly, like:

  $ keepassxc

Enjoy! ;)

EOS

}

doit() {
    _info "** Installing KeePassXC v${version}:"
    download_appimage
    check_hashsum
    install_app_image
    setup_gnome_assets
    inform_user
}

undo() {
    _info "Removing keepassxc:"
    delete_files "Removing gnome assets..." "${_LOCAL}/opt/keepassxc/keepassxc-icon.png" "${_LOCAL}/share/applications/org.keepassxc.desktop"
    delete_files "Removing symlink..." "$_LOCAL/bin/keepassxc"
    delete_files "Removing keepassxc app image..." "${app_fullpath}"
    delete_directory "Removing the opt directory..." "$_LOCAL/opt/keepassxc"
    _info "keepassxc removed successfully."
}

main() {
    local raw_version
    local version
    local app_file
    local app_fullpath
    local download_target
    local project_path='keepassxreboot/keepassxc'

    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="KeePassXC-${version}-${_OS_ARCH}.AppImage"
    # https://github.com/keepassxreboot/keepassxc/releases/download/2.6.6/KeePassXC-2.6.6-x86_64.AppImage

    app_fullpath="${_LOCAL}/opt/keepassxc/${app_file}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    # shellcheck disable=2154
    $mash_action
}

main
