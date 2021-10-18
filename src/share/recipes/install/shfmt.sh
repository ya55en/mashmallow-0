#!/bin/bash

import os
import gh-download

#: Install shfmt

download_into_cache() {
    #: Download into the download cache.

    log debug "raw version=[$raw_version]"
    log debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    log info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

move_into_opt() {
    #: Create ./local/opt/shfmt/ and put the versioned binary
    #: (e.g. shfmt_v3.3.1_linux_amd64) there.

    log info "Creating ${app_fullpath} ..."
    mkdir -p "${app_fullpath}"
    log info "Copying ${download_target} into opt ..."
    cp -p "${download_target}" "${app_fullpath}" ||
        die $? "Moving ${download_target} FAILED (rc=$?)"
    [ -d "$app_fullpath" ] || die 63 "Shfmt directory NOT found: ${app_fullpath}"
    chmod 755 "${app_fullpath}/${app_file}"
}

create_symlink() {
    #: Create a symlink in ./local/bin named shfmt.

    log info "Creating symlink in ./local/bin named shfmt ..."
    ln -fs "${app_fullpath}/${app_file}" "${_LOCAL}/bin/shfmt"
}

smoke_test() {
    #: Do a smoke test with shfmt.

    log debug "Running a smoke test ..."
    if shfmt --version; then
        log info "Smoke test passed OK. (shfmt --version)"
    else
        log error "Smoke test FAILED! Please check the logs."
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
    log info 'SUCCESS.'
}

undo() {
    log warn "Removing shfmt version=[$version]"
    log info "Removing symlink $_LOCAL/bin/shfmt ..."
    rm "$_LOCAL/bin/shfmt"

    log info "Removing shfmt binary ..."
    rm "${app_fullpath}/${app_file}"

    if [ -d "${app_fullpath}" ]; then
        log info "Removing directory ${app_fullpath} ..."
        rmdir "${app_fullpath}"
        [ -d "${app_fullpath}" ] &&
            log warn "shfmt directory not empty, so not deleted: ${app_fullpath}"
    else
        log info "Directory already removed: ${app_fullpath}."
    fi
    log info 'shfmt removed successfully.'
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

    log debug "Version: [${version}]"
    log debug "Download URL: [${_DOWNLOAD_URL}]"

    $mash_action
}

main
