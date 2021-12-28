#! /bin/sh

# set -x

import os
import logging
import gh-download
import removal

#: Install Bitwarden

download_appimage() {
    #: Download the app image

    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path} app-image ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

check_hashsum() {
    #: Check the app image file hashsum.

    # TODO: check sha512 from https://github.com/bitwarden/desktop/releases/download/v1.28.2/latest-linux.yml
    true
}

install_app_image() {
    if [ -e "${app_fullpath}" ]; then
        _warn "Installed app file already exists, skipping. (${app_fullpath})"
    else
        _info "Installing app file ... (${app_fullpath})"
        mkdir -p "$_LOCAL/opt/bitwarden"
        cp -p "${download_target}" "${app_fullpath}"
        chmod +x "${app_fullpath}"
        ln -fs "${app_fullpath}" "$_LOCAL/bin/bitwarden-desktop"
    fi
}

setup_gnome_assets() {
    #: Create/copy .desktop file and an icon.
    bitwarden_icon='bitwarden-icon-128.png'

    [ -e "${_LOCAL}/share/applications/com.bitwarden.desktop" ] && [ -e "${_LOCAL}/opt/bitwarden/${bitwarden_icon}" ]

    if [ $? = 0 ]; then
        _info "Gnome assets already installed, skipping."
    else
        _info "Installing gnome assets ..."
        mkdir -p "${_LOCAL}/share/applications"
        # shellcheck disable=SC1091
        . "$_APPLICATIONS_DIR/com.bitwarden.desktop" > "${_LOCAL}/share/applications/com.bitwarden.desktop"
        cp -p "${_ICONS_DIR}/${bitwarden_icon}" "${_LOCAL}/opt/bitwarden/${bitwarden_icon}"
    fi
}

inform_user() {
    cat << EOS

Completed. You can use Bitwarden Desktop App instantly, like:

  $ bitwarden-desktop

Enjoy! ;)

EOS

}

doit() {
    _info "** Installing bitwarden v${version}:"
    download_appimage
    check_hashsum
    install_app_image
    setup_gnome_assets
    inform_user
}

undo() {
    _info "Removing bitwarden:"
    delete_files 'Removing gnome assets...' "${_LOCAL}/opt/bitwarden/bitwarden-icon.png" "${_LOCAL}/share/applications/com.bitwarden.desktop"
    delete_files 'Removing symlink...' "$_LOCAL/bin/bitwarden-desktop"
    delete_files 'Removing bitwarden app image...' "${app_fullpath}"
    _info "bitwarden removed successfully."
}

main() {
    local raw_version
    local version
    local app_file
    local app_fullpath
    local download_target
    local project_path='bitwarden/desktop'

    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="Bitwarden-${version}-${_OS_ARCH}.AppImage"
    app_fullpath="${_LOCAL}/opt/bitwarden/${app_file}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    # shellcheck disable=2154
    $mash_action
}

main
