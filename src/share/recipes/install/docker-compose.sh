#! /bin/sh

import os
import logging
import gh-download

#: Install Docker Compose

download_into_cache() {
    #: Download into a cache folder.

    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

copy_into_bin_loc() {
    #: Copy from $HOME/.cache/mash/downloads to $HOME/.local/bin .

    if [ -e "${bin_loc}/${app_file}" ]; then
        _warn "Already in $HOME/.local/bin, skipping."
    else
        _info "Copying ${app_file} to ${bin_loc} ..."
        cp "${download_target}" "${bin_loc}"
        chmod +x "${bin_loc}"
    fi
}

smoke_test() {
    #: Run a smoke test.

    _info "Running a smoke test ..."
    docker-compose --version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        _info 'docker-compose installation successful.'
        docker-compose --version
    else
        _error 'docker-compose installation FAILED.'
    fi
}

inform_user() {
    cat << EOS

Completed. You can use docker-compose instantly, like:

  $ docker-compose --help

Enjoy! ;)

EOS
}

doit() {
    download_into_cache
    copy_into_bin_loc
    smoke_test
    inform_user
}

undo() {
    _warn "Removing docker-compose ..."

    _info "Removing binary from ${bin_loc}"
    rm "${bin_loc}" || die 65 "Could not remove ${bin_loc}/${app_file} !"
    _info "docker-compose removed successfully."
}

main() {
    # TODO: Versions 2.x follow different URL/ARCH naming convention and need different handling

    local bin_loc
    local raw_version
    local version
    local app_file
    local download_target
    local project_path='docker/compose'

    bin_loc="${_LOCAL}/bin/docker-compose"
    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    app_file="docker-compose-${_OS_KERNEL_NAME}-${_OS_ARCH}"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    _debug "Version: [${version}]"
    _debug "Download URL: [${_DOWNLOAD_URL}]"

    $mash_action
}

main
