#! /bin/sh

import os
import gh-download

#: Install github cli

download_tarball() {
    #: Download gh cli tarball into download_cache_dir

    log debug "raw version=[$raw_version]"
    log debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    log info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

# TODO: check hash (no hash provided by upstream; make up one)

extract_into_opt() {
    #: Extract the github-cli tarball into ~/.local/opt/.

    log info "Extracting ${download_target} ..."
    tar xf "${download_target}" -C "$_LOCAL/opt/" ||
        die $? "Extracting ${download_target} FAILED (rc=$?)"
    [ -d "${app_fullpath}/bin" ] || die 2 "Bin directory NOT found: ${app_fullpath}/bin"
}

create_symlink() {
    #: Create symlink to the gh executable.

    log info "Creating symlink to ${app_fullpath}/bin/gh ..."
    ln -fs "${app_fullpath}/bin/gh" "$_LOCAL/bin/gh"
}

smoke_test() {
    #: Smoke-test the new installation

    log debug "Running a smoke test ..."
    if gh --version; then
        log info "Smoke test passed OK. (gh --version)"
    else
        log error "Smoke test FAILED! Please check the logs."
        exit 56
    fi
}

instruct_user() {
    cat << EOS

Completed. You can use github cli instantly, like:

  $ gh --help

EOS
}

doit() {
    log debug "Installing ghcli version=[$version]"
    download_tarball
    # check_hashsum
    extract_into_opt
    create_symlink
    smoke_test
    instruct_user
    log info 'SUCCESS.'
}

undo() {
    log warn "UNinstalling github-cli version=[$version]"

    log info "Removing symlink $_LOCAL/bin/gh ..."
    rm "$_LOCAL/bin/gh"

    log info "Removing directory ${app_fullpath} ..."
    rm -r "${app_fullpath}"

    log info 'UNinstallation ended.'
}

main() {
    local raw_version
    local version
    local app_file
    local app_fullpath
    local download_target
    local project_path='cli/cli'

    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="gh_${version}_linux_${_OS_ARCH_SHORT}.tar.gz"
    app_fullpath="$_LOCAL/opt/gh_${version}_linux_${_OS_ARCH_SHORT}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"
    log debug "Version: [${version}]"
    log debug "Download URL: [${_DOWNLOAD_URL}]"

    $mash_action
}

main
