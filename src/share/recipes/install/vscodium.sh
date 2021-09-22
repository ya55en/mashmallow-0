#! /bin/sh

# Install Visual Studio Code
# Current download URL is:
#   https://az764295.vo.msecnd.net/stable/83bd43bc519d15e50c4272c6cf5c1479df196a4d/code-stable-x64-1631295096.tar.gz

# download tarball to cache dir
# https://github.com/VSCodium/vscodium/releases/download/1.60.1/VSCodium-linux-x64-1.60.1.tar.gz
# check hashsum
# https://github.com/VSCodium/vscodium/releases/download/1.60.1/VSCodium-linux-x64-1.60.1.tar.gz.sha256
# extract into .local/opt
# make a symlink in .local/bin/codium to .local/opt/vscodium-1.60.1/bin/vscodium

# TODO: Provide a .desktop file; clean up above notes

# set -x

version='1.60.1'
ARCH_SHORT=x64

_URL_DOWNLOAD="https://github.com/VSCodium/vscodium/releases/download/${version}/VSCodium-linux-${ARCH_SHORT}-${version}.tar.gz"
_URL_HASHSUM="https://github.com/VSCodium/vscodium/releases/download/${version}/VSCodium-linux-${ARCH_SHORT}-${version}/.tar.gz.sha256"

vscodium_filename="VSCodium-linux-${ARCH_SHORT}-${version}.tar.gz"
vscodium_opt_dirname="vscodium-${version}"
dot_desktop_file='com.vscodium.desktop'
download_cache_dir="$HOME/.cache/mash/downloads"
mkdir -p "${download_cache_dir}"

download_tarball() {
    #: Download codium tarball into download_cache_dir

    # TODO: implement download skip if file already there and having proper hashsum

    log debug "_URL_DOWNLOAD=$_URL_DOWNLOAD"
    log debug "_URL_DOWNLOAD=$_URL_HASHSUM"
    log debug "download_cache_dir=$download_cache_dir"
    log info "Downloading VSCodium, v${version}..."
    rm -f "${download_cache_dir}/${vscodium_filename}"
    curl -sL "$_URL_DOWNLOAD" -o "${download_cache_dir}/${vscodium_filename}" ||
        die 9 "Download failed. (URL: $_URL_DOWNLOAD)"

}

check_hashsum() {
    #: Download codium tarball into download_cache_dir
    # TODO: implement
    /bin/true
}

extract_to_opt() {
    #: Extract the codium tarball into ~/.local/opt/$vscodium_opt_dirname.

    log info "Extracting ${download_cache_dir}/${vscodium_filename}..."
    filename="${download_cache_dir}/${vscodium_filename}"
    dirname="${_LOCAL}/opt/${vscodium_opt_dirname}"

    mkdir -p "${dirname}"
    tar xf "${filename}" -C "${dirname}" ||
        die $? "Extracting ${filename} FAILED (rc=$?)"
    [ -d "${_LOCAL}/opt/${vscodium_opt_dirname}/bin" ] ||
        die 2 "Bin directory NOT found: ${dirname}/bin"
}

make_symlink_in_local_bin() {
    #: Create symlink to ${_LOCAL}/opt/${vscodium_opt_dirname}/bin/codium in ~/.local/bin/

    log info "Creating a symlink to ${_LOCAL}/opt/${vscodium_opt_dirname}/bin/codium in $_LOCAL/bin/..."
    # shellcheck disable=SC2016  # Need to pass this verbatim to into_dir_do()
    into_dir_do "${_LOCAL}/bin" 'ln -fs "${_LOCAL}/opt/${vscodium_opt_dirname}/bin/codium"'
    linked_binary="${_LOCAL}/bin/codium"
    [ -L "$linked_binary" ] || die 2 "Linked binary NOT found: ${linked_binary}"
}

install_dot_desktop() {
    dot_desktop_fullpath="$_LOCAL/share/applications/${dot_desktop_file}"
    if [ -e "${dot_desktop_fullpath}" ]; then
        log warn "Dot-desktop file exists, skipping. (${dot_desktop_fullpath})"
    else
        log info "Installing a dot-desktop file ... (${dot_desktop_fullpath})"
        # shellcheck disable=SC1090
        . "${_APPLICATIONS_DIR}/${dot_desktop_file}" > "${dot_desktop_fullpath}"
    fi
}

smoke_test() {
    # codium --version > /dev/null  # || die 25 "Codium NOT working! (rc=$?) :("
    codium --version > /dev/null 2>&1
    rc=$?
    if [ $rc = 0 ]; then
        log info "Smoke Test OK (codium --version)"
    fi
    return $rc
}

doit() {
    log info "Installing codium ${version} (${ARCH_SHORT})..."
    download_tarball
    check_hashsum || die 77 "Hashsum check FAILED! Please check, aborting."
    extract_to_opt
    install_dot_desktop
    make_symlink_in_local_bin
    smoke_test
}

undo() {
    log info "*UN*installing codium ${version} (${ARCH_SHORT})..."
    rm "${_LOCAL}/bin/codium" || die 15 "Cannot remove ${_LOCAL}/bin/codium"
    rm -r "${_LOCAL}/opt/${vscodium_opt_dirname}" || die 15 "Cannot remove ${_LOCAL}/opt/${vscodium_opt_dirname}"
    rm "${_LOCAL}/share/applications/${dot_desktop_file}"
    smoke_test && die 99 "Coduim NOT removed, still working"
    echo 'Undo install done.'
}

$mash_action
