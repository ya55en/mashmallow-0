#!/bin/sh

import os
import logging
import gh-download
import removal
import install

#: Install shellcheck

download_tarball() {
    #: Download shellcheck tarball into download_cache_dir

    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

#extract_into_tmp() {
#    #: Extract the shellcheck tarball into /tmp/.
#
#    _info "Extracting ${download_target} ..."
#    tar xf "${download_target}" -C "/tmp/" ||
#        die $? "Extracting ${download_target} FAILED (rc=$?)"
#    [ -d "/tmp/shellcheck-v${version}" ] || die 2 "Shellcheck directory NOT found: /tmp/shellcheck-v${version}"
#}

#create_symlink() {
#    #: Create symlink to the shellcheck executable.
#
#    _info "Creating symlink to ${app_fullpath}/bin/shellcheck ..."
#    ln -fs "${app_fullpath}/shellcheck" "$_LOCAL/bin/shellcheck"
#}

smoke_test() {
    _debug "Running a smoke test ..."
    if shellcheck --version; then
        _info "Smoke test passed OK. (shellcheck --version)"
    else
        _error "Smoke test FAILED! Please check the logs."
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
    _debug "Installing shellcheck version=[$version]"
    download_tarball
    # check_hashsum
    install_single "$download_target" 'shellcheck' "$version"
    smoke_test
    instruct_user
    _info 'SUCCESS.'
}

undo() {
    _info "Removing shellcheck version=[$version]:"
    delete_files "Removing symlink $_LOCAL/bin/shellcheck ..." "$_LOCAL/bin/shellcheck"
    delete_directory "Removing directory ${app_fullpath} ..." "${app_fullpath}"
    _info 'shellcheck removed successfully.'
}

main() {
    local raw_version
    local version
    local app_file
    local app_fullpath
    local download_target
    local project_path='koalaman/shellcheck'

    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="shellcheck-${raw_version}.linux.${_OS_ARCH}.tar.xz"
    app_fullpath="${_LOCAL}/opt/shellcheck-v${version}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    $mash_action
}

main
