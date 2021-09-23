#! /bin/sh

# set -x

# Assumming lib/libma.sh has been sourced already.

_ARCH=x86_64
_LOCAL="$HOME/.local"

# Install Bitwarden
_URL_LATEST=https://github.com/bitwarden/desktop/releases/latest
_URL_DOWNLOAD_RE='^location: https://github.com/bitwarden/desktop/releases/tag/v\(.*\)$'
version=$(curl -Is $_URL_LATEST | grep ^location | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")

app_file="Bitwarden-${version}-${_ARCH}.AppImage"
app_fullpath="${_LOCAL}/opt/bitwarden/${app_file}"
download_target="${_DOWNLOAD_CACHE}/${app_file}"

log debug "version=[$version]"
if [ x"$version" = x ]; then die 3 'Failed to get Bitwarden latest version'; fi

_URL_DOWNLOAD="https://github.com/bitwarden/desktop/releases/download/v${version}/${app_file}"

log debug "_URL_DOWNLOAD=[${_URL_DOWNLOAD}]"

download_appimage() {
    #: Download and install the app image

    if [ -e "${download_target}" ]; then
        log warn "App file already downloaded/cached, skipping."
    else
        mkdir -p "${_DOWNLOAD_CACHE}"
        log info "Downloading Bitwarden desktop v${version}..."
        curl -sL "$_URL_DOWNLOAD" -o "${download_target}" || die 25 "Bitwarden download FAILED! (rc=$?)"
    fi
}

check_hashsum() {
    #: Check the app image file hashsum.

    # TODO: check sha512 from https://github.com/bitwarden/desktop/releases/download/v1.28.2/latest-linux.yml
    true
}

install_app_image() {
    if [ -e "${app_fullpath}" ]; then
        log warn "Installed app file already exists, skipping. (${app_fullpath})"
    else
        log info "Installing app file ... (${app_fullpath})"
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
        log info "Gnome assets already installed, skipping."
    else
        log info "Installing gnome assets ..."
        # shellcheck disable=SC1090
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
    log info "** Installing bitwarden:"
    download_appimage
    check_hashsum
    install_app_image
    setup_gnome_assets
    inform_user
}

undo() {
    log info "** Un-installing bitwarden:"

    result=''

    # Remove gnome assets
    log info "Removing gnome assets..."
    rm -f "${_LOCAL}/opt/bitwarden/bitwarden-icon.png"
    result="${result}:$?"
    rm -f "${_LOCAL}/share/applications/com.bitwarden.desktop"
    result="${result}:$?"

    # Remove symlink
    log info "Removing symlink..."
    rm -f "$_LOCAL/bin/bitwarden-desktop"
    result="${result}:$?"

    # Remove app image file
    log info "Removing bitwarden app image..."
    rm -f "${app_fullpath}"
    result="${result}:$?"

    if [ x"$result" = 'x:0:0:0:0' ]; then
        log info "Successfully un-installed bitwarden."
    else
        log warn "Un-installed bitwarden with errors: codes ${result}"
    fi
}

$mash_action
