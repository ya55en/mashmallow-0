#!/bin/sh

import gh-download

download_tarball() {
    #: Download shellcheck tarball into download_cache_dir

    log debug "raw version=[$raw_version]"
    log debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    log info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

extract_into_opt() {
    #: Extract the shellcheck tarball into ~/.local/opt/.

    log info "Extracting ${download_target} ..."
    tar xf "${download_target}" -C "$_LOCAL/opt/" ||
        die $? "Extracting ${download_target} FAILED (rc=$?)"
    [ -d "${app_fullpath}" ] || die 2 "Shellcheck directory NOT found: ${app_fullpath}"
}

create_symlink() {
    #: Create symlink to the shellcheck executable.

    log info "Creating symlink to ${app_fullpath}/bin/shellcheck ..."
    ln -fs "${app_fullpath}/shellcheck" "$_LOCAL/bin/shellcheck"
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
    download_tarball
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

    log info "Removing directory ${app_fullpath} ..."
    rm -r "${app_fullpath}"

    log info 'UNinstallation ended.'
}

main() {
    _ARCH=x86_64
    local raw_version
    local version
    local app_file
    local app_fullpath
    local download_target
    local project_path='koalaman/shellcheck'

    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="shellcheck-${raw_version}.linux.${_ARCH}.tar.xz"
    app_fullpath="${_LOCAL}/opt/shellcheck-v${version}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    $mash_action
}

main
