#!/bin/sh

#: Install ungoogled chromium + chromedriver
#: Base repo: https://github.com/macchrome/linchrome/
#: See also https://chromium.woolyss.com/#linux
#: Related links:
#:  - https://github.com/Eloston/ungoogled-chromium/
#:  - https://github.com/ungoogled-software/ungoogled-chromium-portablelinux
#:  - https://ungoogled-software.github.io/ungoogled-chromium-binaries/
#: Also a related source (but points to a googled chromium and also
#: very hard to discover the latest stable):
#:  - https://www.chromium.org/getting-involved/download-chromium

import logging
import gh-download
import install

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

check_hashsum() {
    # TODO: implement
    :
}

smoke_test() {
    _debug "Running a smoke test ..."
    if chromedriver --version && chrome --version; then
        _info "Smoke test passed OK. (chrome --version)"
    else
        _error "Smoke test FAILED! Please check the logs."
        exit 56
    fi
}

instruct_user() {
    _info 'SUCCESS!'
    _warn 'You need to **close and reopen** all your terminals now.'
    _warn 'Then you will be able to use chrome and chromedriver, like:'
    cat << EOS

  $ chromedriver --help

EOS
}

doit() {
    _debug "Installing ungoogled chromium version=[$version]"
    download_tarball
    check_hashsum
    install_multi "$download_target" "ungoogled-chromium" "$version"
    install_bashrcd_script 'ungoogled-chromium' '52-uchromium-path.sh' "${_LOCAL}/opt/ungoogled-chromium/current"
    smoke_test
    instruct_user
}

undo() {
    _error "Undo install ungoogled chromium NOT supported yet, apologies."
}

main() {
    local raw_version
    local version
    local app_file
    local app_basename
    local app_main_dir
    local download_target
    local project_path='macchrome/linchrome'

    # TODO: check os info and fail of not Linux x64

    # Sample archive filename: ungoogled-chromium_96.0.4664.45_1.vaapi_linux.tar.xz
    raw_version="$(gh_latest_raw_version $project_path)"
    _debug "raw_version=[$raw_version]"
    version="${raw_version%%-*}" # remove everything after the dash
    version="${version#v*}"      # remove the leading 'v'
    app_basename="ungoogled-chromium_${version}_1.vaapi_linux"
    app_file_ext='tar.xz'
    app_file="${app_basename}.${app_file_ext}"
    _debug "app_file=[$app_file]"
    app_main_dir="${_LOCAL}/opt/ungoogled-chromium"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    $mash_action
}

main
