#! /bin/sh

# set -x

import os
import logging
import gh-download
import removal
import install

#: Install VSCodium

# check hashsum
# https://github.com/VSCodium/vscodium/releases/download/1.60.1/VSCodium-linux-x64-1.60.1.tar.gz.sha256

download_tarball() {
    #: Download codium tarball into download_cache_dir

    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

check_hashsum() {
    #: Download codium tarball into download_cache_dir
    # TODO: implement
    /bin/true
}

install_dot_desktop() {
    dot_desktop_fullpath="$_LOCAL/share/applications/${dot_desktop_file}"
    mkdir -p "$_LOCAL/share/applications"
    if [ -e "${dot_desktop_fullpath}" ]; then
        _warn "Dot-desktop file exists, skipping. (${dot_desktop_fullpath})"
    else
        _info "Installing a dot-desktop file ... (${dot_desktop_fullpath})"
        # shellcheck disable=SC1090
        . "${_APPLICATIONS_DIR}/${dot_desktop_file}" > "${dot_desktop_fullpath}"
    fi
}

smoke_test() {
    # codium --version > /dev/null  # || die 25 "Codium NOT working! (rc=$?) :("
    codium --version > /dev/null 2>&1
    rc=$?
    if [ $rc = 0 ]; then
        _info "Smoke Test OK (codium --version)"
    fi
    return $rc
}

doit() {
    _info "Installing vscodium v${version} ($arch_short)..."
    download_tarball
    check_hashsum || die 77 "Hashsum check FAILED! Please check, aborting."
    install_single "$download_target" 'vscodium' "$version" 'bin/codium'
    install_dot_desktop

    smoke_test
}

undo() {
    _info "Removing codium v${version} ($arch_short):"
    delete_files "" "${_LOCAL}/bin/codium"
    delete_directory "" "${_LOCAL}/opt/${app_opt_dirname}"
    delete_files "" "${_LOCAL}/share/applications/${dot_desktop_file}"
    smoke_test && die 99 "Coduim NOT removed, still working"
    _info 'codium removed successfully.'
}

get_arch_short() {
    if [ "$_OS_ARCH" = x86_64 ]; then
        printf 'x64'
    elif [ "$_OS_ARCH" = x86 ]; then
        die 76 "VSCodioum does NOT support arch $_OS_ARCH"
    # TODO: provide mapping for all supported architectures
    else
        die 77 "Architecture not implemented yet: ARCH=[$_OS_ARCH]"
    fi
}

main() {
    local dot_desktop_file
    local project_path
    local raw_version
    local version
    local app_file
    local app_opt_dirname
    local download_target
    local arch_short

    arch_short="$(get_arch_short)"
    dot_desktop_file='com.vscodium.desktop'
    project_path='VSCodium/vscodium'
    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="VSCodium-linux-${arch_short}-${version}.tar.gz"
    app_opt_dirname="vscodium-${version}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    $mash_action
}

main
