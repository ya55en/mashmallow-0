#!/bin/sh

_ARCH=x86_64
_LOCAL="$HOME/.local"

# TODO: Determine the latest release (a way similar to the one this is done for Bitwarden would do);
#  WIP

#_URL_LATEST=https://github.com/koalaman/shellcheck/releases/latest
#_URL_DOWNLOAD_RE='^location: https://github.com/koalaman/shellcheck/releases/tag/v\(.*\)$'
#version=$(curl -Is $_URL_LATEST | grep ^location | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")
#
#app_file="Bitwarden-${version}-${_ARCH}.AppImage"
##app_fullpath="${_LOCAL}/opt/bitwarden/${app_file}"
##download_target="${_DOWNLOAD_CACHE}/${app_file}"
#
#log debug "version=[$version]"
#if [ x"$version" = x ]; then die 3 'Failed to get Shellcheck latest version'; fi
#
#_URL_DOWNLOAD="https://github.com/koalaman/shellcheck/releases/download/v${version}/${app_file}
#/v0.7.2/shellcheck-v0.7.2.linux.x86_64.tar.xz"
#
#log debug "_URL_DOWNLOAD=[${_URL_DOWNLOAD}]"

version='0.7.2'
shellcheck_filename="shellcheck-${version}.linux.${_ARCH}.tar.gz"
shellcheck_dir="$_LOCAL/opt/shellcheck-v${version}"
log debug "version=[$version]"
_URL_DOWNLOAD="https://github.com/koalaman/shellcheck/releases/download/v0.7.2/shellcheck-v0.7.2.linux.x86_64.tar.xz"
log debug "_URL_DOWNLOAD=[${_URL_DOWNLOAD}]"

download_tarball() {
    #: Download shellcheck tarball into download_cache_dir
    skip="${1:-no-skip}"

    if [ "$skip" = skip-if-exists ] && [ -f "${_DOWNLOAD_CACHE}/${shellcheck_filename}" ]; then
        log warn "Target archive already downloaded, skipping."
        log warn "File exits: ${_DOWNLOAD_CACHE}/${shellcheck_filename}"
    else
        log debug "_URL_DOWNLOAD=$_URL_DOWNLOAD"
        # log debug "_URL_DOWNLOAD=$_URL_HASHSUM"
        mkdir -p "${_DOWNLOAD_CACHE}"
        log debug "download_cache_dir=$_DOWNLOAD_CACHE"
        log info "Downloading Shellcheck, v${version}..."
        rm -f "${_DOWNLOAD_CACHE}/${shellcheck_filename}"
        curl -sL "$_URL_DOWNLOAD" -o "${_DOWNLOAD_CACHE}/${shellcheck_filename}" ||
            die 9 "Download FAILED. rc=$? (URL: $_URL_DOWNLOAD)"
    fi
}

extract_into_opt() {
    #: Extract the shellcheck tarball into ~/.local/opt/.

    log info "Extracting ${_DOWNLOAD_CACHE}/${shellcheck_filename}..."
    tar xf "${_DOWNLOAD_CACHE}/${shellcheck_filename}" -C "$_LOCAL/opt/" ||
        die $? "Extracting ${_DOWNLOAD_CACHE}/${shellcheck_filename} FAILED (rc=$?)"
    [ -d "${shellcheck_dir}" ] || die 2 "Shellcheck directory NOT found: ${shellcheck_dir}"
}

create_symlink() {
    #: Create symlink to the shellcheck executable.

    log info "Creating symlink to ${shellcheck_dir}/bin/shellcheck ..."
    ln -fs "${shellcheck_dir}/shellcheck" "$_LOCAL/bin/shellcheck"
}

smoke_test() {
    log debug "Running a smoke test ..."
    if shellcheck --version; then
        log info "Smoke test passed OK. (shellcheck --version)"
    else
        log error "Smoke test FAILED! Please check the logs."
        exit 56
    fi
}

instruct_user() {
    cat << EOS

Completed. You can use shellcheck instantly, like:

  $ shellcheck --help

EOS
}

doit() {
    log debug "Installing shellcheck version=[$version]"
    download_tarball skip-if-exists
    # check_hashsum
    extract_into_opt
    create_symlink
    smoke_test
    instruct_user
    log info 'SUCCESS.'
}

undo() {
    log warn "UNinstalling shellcheck version=[$version]"

    log info "Removing symlink $_LOCAL/bin/shellcheck ..."
    rm "$_LOCAL/bin/shellcheck"

    log info "Removing directory ${shellcheck_dir} ..."
    rm -r "${shellcheck_dir}"

    log info 'UNinstallation ended.'
}

$mash_action
