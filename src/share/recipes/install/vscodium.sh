#! /bin/sh

# set -x

import os
import gh-download

#: Install VSCodium

# check hashsum
# https://github.com/VSCodium/vscodium/releases/download/1.60.1/VSCodium-linux-x64-1.60.1.tar.gz.sha256

download_tarball() {
    #: Download codium tarball into download_cache_dir

    log debug "raw version=[$raw_version]"
    log debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    log info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

check_hashsum() {
    #: Download codium tarball into download_cache_dir
    # TODO: implement
    /bin/true
}

extract_to_opt() {
    #: Extract the codium tarball into ~/.local/opt/$app_opt_dirname.

    log info "Extracting ${download_target} ..."
    filename="${download_target}"
    dirname="${_LOCAL}/opt/${app_opt_dirname}"

    mkdir -p "${dirname}"
    tar xf "${filename}" -C "${dirname}" ||
        die $? "Extracting ${filename} FAILED (rc=$?)"
    [ -d "${_LOCAL}/opt/${app_opt_dirname}/bin" ] ||
        die 2 "Bin directory NOT found: ${dirname}/bin"
}

make_symlink_in_local_bin() {
    #: Create symlink to ${_LOCAL}/opt/${app_opt_dirname}/bin/codium in ~/.local/bin/

    log info "Creating a symlink to ${_LOCAL}/opt/${app_opt_dirname}/bin/codium in $_LOCAL/bin/..."
    # shellcheck disable=SC2016  # Need to pass this verbatim to into_dir_do()
    into_dir_do "${_LOCAL}/bin" 'ln -fs "${_LOCAL}/opt/${app_opt_dirname}/bin/codium"'
    linked_binary="${_LOCAL}/bin/codium"
    [ -L "$linked_binary" ] || die 2 "Linked binary NOT found: ${linked_binary}"
}

install_dot_desktop() {
    dot_desktop_fullpath="$_LOCAL/share/applications/${dot_desktop_file}"
    mkdir -p "$_LOCAL/share/applications"
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
    log info "Installing vscodium v${version} ($arch_short)..."
    download_tarball
    check_hashsum || die 77 "Hashsum check FAILED! Please check, aborting."
    extract_to_opt
    install_dot_desktop
    make_symlink_in_local_bin
    smoke_test
}

undo() {
    log info "*UN*installing codium v${version} ($arch_short)..."
    rm "${_LOCAL}/bin/codium" || die 15 "Cannot remove ${_LOCAL}/bin/codium"
    rm -r "${_LOCAL}/opt/${app_opt_dirname}" || die 15 "Cannot remove ${_LOCAL}/opt/${app_opt_dirname}"
    rm "${_LOCAL}/share/applications/${dot_desktop_file}"
    smoke_test && die 99 "Coduim NOT removed, still working"
    echo 'Undo install done.'
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
