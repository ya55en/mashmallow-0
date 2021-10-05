#! /bin/sh

# set -x

# Assumming lib/libma.sh has been sourced already.

DEBUG=true
_ARCH=x86_64
_LOCAL="$HOME/.local"

# Install Wire
version='3.26.2941'
app_file="Wire-${version}_${_ARCH}.AppImage"
app_fullpath="$_LOCAL/opt/wire/${app_file}"
download_target="${_DOWNLOAD_CACHE}/${app_file}"
icon_file="wire-icon-dark-128.png"
mkdir -p "${_DOWNLOAD_CACHE}"

log debug "version=[$version]"

# https://wire-app.wire.com/linux/Wire-3.26.2941_x86_64.AppImage
_URL_DOWNLOAD="https://wire-app.wire.com/linux/${app_file}"

log debug "_URL_DOWNLOAD=[$_URL_DOWNLOAD]"

download_appimage() {
    #: Download and install the app image

    log debug "download_target=[$download_target]"
    if [ -e "${download_target}" ]; then
        log warn "App file already downloaded/cached, skipping."
    else
        log info "Downloading Wire desktop v${version}..."
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
        log warn "Installed app file already exists, skipping. (${app_fullpath})"
    else
        log info "Installing app file ... (${app_fullpath})"
        mkdir -p "${_LOCAL}/share/applications"
        mkdir -p "$_LOCAL/opt/wire"
        cp -p "${download_target}" "${app_fullpath}"
        chmod +x "${app_fullpath}"
        ln -fs "${app_fullpath}" "$_LOCAL/bin/wire-desktop"
    fi
}

setup_gnome_assets() {
    #: Create/copy .desktop file and an icon.

    [ -e "${_LOCAL}/share/applications/com.wire.desktop" ] && [ -e "${_LOCAL}/opt/wire/${icon_file}" ]

    if [ $? = 0 ]; then
        log info "Gnome assets already installed, skipping."
    else
        log info "Installing gnome assets ..."
        # shellcheck disable=SC1090
        . "$_APPLICATIONS_DIR/com.wire.desktop" > "${_LOCAL}/share/applications/com.wire.desktop"
        cp -p "${_ICONS_DIR}/${icon_file}" "${_LOCAL}/opt/wire/${icon_file}"
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
    log info "** Installing Wire:"
    download_appimage
    check_hashsum
    install_app_image
    setup_gnome_assets
    inform_user
}

undo() {
    log info "** Un-installing Wire:"

    result=''

    # Remove gnome assets
    log info "Removing gnome assets..."
    rm -f "${_LOCAL}/opt/wire/wire-icon.png"
    result="${result}:$?"
    rm -f "${_LOCAL}/share/applications/com.wire.desktop"
    result="${result}:$?"

    # Remove symlink
    log info "Removing symlink..."
    rm -f "$_LOCAL/bin/wire-desktop"
    result="${result}:$?"

    # Remove app image file
    log info "Removing wire app image..."
    rm -f "${app_fullpath}"
    result="${result}:$?"

    if [ "$result" = ':0:0:0:0' ]; then
        log info "Successfully un-installed wire."
    else
        log warn "Un-installed wire with errors: codes [${result}]"
    fi
}

# shellcheck disable=2154
$mash_action
