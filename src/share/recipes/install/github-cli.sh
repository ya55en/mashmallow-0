#! /bin/sh

import os
import logging
import gh-download
import removal
import install

#: Install github cli

download_tarball() {
    #: Download gh cli tarball into download_cache_dir

    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

# TODO: check hash (no hash provided by upstream; make up one)

#extract_into_opt() {
#    #: Extract the github-cli tarball into ~/.local/opt/.
#
#    _info "Extracting ${download_target} ..."
#    tar xf "${download_target}" -C "$_LOCAL/opt/" ||
#        die $? "Extracting ${download_target} FAILED (rc=$?)"
#    [ -d "${app_fullpath}/bin" ] || die 2 "Bin directory NOT found: ${app_fullpath}/bin"
#}
extract_into_tmp() {
    #: Extract the github-cli tarball into /tmp/.

    _info "Extracting ${download_target} ..."
    tar xf "${download_target}" -C "/tmp/" ||
        die $? "Extracting ${download_target} FAILED (rc=$?)"
    [ -d "/tmp/gh_${version}_linux_${_OS_ARCH_SHORT}/bin" ] || die 2 "Bin directory NOT found: /tmp/gh_${version}_linux_${_OS_ARCH_SHORT}/bin"
}

#create_symlink() {
#    #: Create symlink to the gh executable.
#
#    _info "Creating symlink to ${app_fullpath}/bin/gh ..."
#    ln -fs "${app_fullpath}/bin/gh" "$_LOCAL/bin/gh"
#}

smoke_test() {
    #: Smoke-test the new installation

    _debug "Running a smoke test ..."
    if gh --version; then
        _info "Smoke test passed OK. (gh --version)"
    else
        _error "Smoke test FAILED! Please check the logs."
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
    _debug "Installing ghcli version=[$version]"
    download_tarball
    # check_hashsum
#    extract_into_opt
#    create_symlink
    extract_into_tmp
    install_single "/tmp/gh_${version}_linux_${_OS_ARCH_SHORT}" 'gh' "$version" "bin/gh"
    smoke_test
    instruct_user
    _info 'SUCCESS.'
}

undo() {
    _info "Removing github-cli version=[$version]:"
    delete_files "Removing symlink $_LOCAL/bin/gh ..." "$_LOCAL/bin/gh"
    delete_directory "Removing directory ${app_fullpath} ..." "${app_fullpath}"
    _info "github-cli removed successfully."
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
    _debug "Version: [${version}]"
    _debug "Download URL: [${_DOWNLOAD_URL}]"

    $mash_action
}

main
