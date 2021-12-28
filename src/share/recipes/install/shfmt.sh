#!/bin/bash

import os
import logging
import gh-download
import removal

#: Install shfmt

download_into_cache() {
    #: Download into the download cache.

    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

move_into_opt() {
    #: Create ./local/opt/shfmt/ and put the versioned binary
    #: (e.g. shfmt_v3.3.1_linux_amd64) there.

    _info "Creating ${app_fullpath} ..."
    mkdir -p "${app_fullpath}"
    _info "Copying ${download_target} into opt ..."
    cp -p "${download_target}" "${app_fullpath}" ||
        die $? "Moving ${download_target} FAILED (rc=$?)"
    [ -d "$app_fullpath" ] || die 63 "Shfmt directory NOT found: ${app_fullpath}"
    chmod 755 "${app_fullpath}/${app_file}"
}

create_symlink() {
    #: Create a symlink in ./local/bin named shfmt.

    _info "Creating symlink in ./local/bin named shfmt ..."
    ln -fs "${app_fullpath}/${app_file}" "${_LOCAL}/bin/shfmt"
}

smoke_test() {
    #: Do a smoke test with shfmt.

    _debug "Running a smoke test ..."
    if shfmt --version; then
        _info "Smoke test passed OK. (shfmt --version)"
    else
        _error "Smoke test FAILED! Please check the logs."
        exit 58
    fi
}

instruct_user() {
    cat << EOS

Completed. You can use instantly, shfmt like:

  $ shfmt --help

EOS
}

doit() {
    download_into_cache
    move_into_opt
    create_symlink
    smoke_test
    instruct_user
    _info 'SUCCESS.'
}

undo() {
    _info "Removing shfmt version=[$version]:"
    delete_files "Removing symlink $_LOCAL/bin/shfmt ..." "$_LOCAL/bin/shfmt"
    delete_files "Removing shfmt binary ..." "${app_fullpath}/${app_file}"

    # TODO: the previous logic deleted the directory only if empty, the new one deletes regardless
    delete_directory "Removing directory ${app_fullpath} ..." "${app_fullpath}"
#    if [ -d "${app_fullpath}" ]; then
#        _info "Removing directory ${app_fullpath} ..."
#        rmdir "${app_fullpath}"
#        [ -d "${app_fullpath}" ] &&
#            _warn "shfmt directory not empty, so not deleted: ${app_fullpath}"
#    else
#        _info "Directory already removed: ${app_fullpath}."
#    fi
    _info 'shfmt removed successfully.'
}

main() {
    local raw_version
    local version
    local app_file
    local app_fullpath
    local download_target
    local project_path='mvdan/sh'

    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="shfmt_v${version}_linux_${_OS_ARCH_SHORT}"
    app_fullpath="$_LOCAL/opt/shfmt"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    _debug "Version: [${version}]"
    _debug "Download URL: [${_DOWNLOAD_URL}]"

    $mash_action
}

main
