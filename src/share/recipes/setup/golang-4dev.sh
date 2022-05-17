#!/bin/sh

#: Setup golang for development
#: https://go.dev/doc/install, https://go.dev/dl/

import logging
import os
import install

#: Extract the go version out of the first five lines of the JSON
#: response to the given HTTP GET request.
get_latest_version() {
    local url="${dl_base_url}?mode=json"

    _debug "Doing GET [$url] to obtain latest version..."
    # curl complains on bad output below but otherwise everything works ;)
    version=$(
        curl -sSX GET "$url" | head -5 |
            awk '/"version": "go[0-9]+\.[0-9]+\.[0-9]+"/ {print substr($2, 4)}'
    )
    version=${version%*\",} # rstrip ",
    _info "Go version=[$version] (latest)"
}

download_tarball() {
    if [ -f "$_DOWNLOAD_CACHE/$archive_filename" ]; then
        _info "Tarball already downloaded, skipping. ($_DOWNLOAD_CACHE/$archive_filename)"
    else
        local url="${dl_base_url}${archive_filename}"
        _info "Downloading tarball $url..."
        curl -sSL "$url" -o "$_DOWNLOAD_CACHE/$archive_filename"
        [ -f "$_DOWNLOAD_CACHE/$archive_filename" ] || {
            die 33 "Downloading FAILED for url $url"
        }
    fi
}

smoke_test() {
    _info "Smoke-testing the installation..."
    . "$HOME/.bashrc.d/88-golang-path.sh"

    if go version; then
        _info "Smoke test passed."
    else
        _die 33 "Smoke-testing golang installation FAILED."
    fi
}

inform_user() {
    _info 'SUCCESS!'
    _warn 'You need to **close and reopen** all your terminals now.'
    _warn 'Then you will be able to use go, like:'
    cat << EOS

 $ go version
 $ go help

Enjoy! ;)
EOS
}

# shellcheck disable=SC2039
doit() {
    # https://go.dev/dl/go1.17.3.linux-amd64.tar.gz
    # local _arch
    local dl_base_url='https://go.dev/dl/'
    local version
    local archive_basename
    local archive_ext='tar.gz'
    local archive_filename
    # local opt_dir='golang'
    local env_filename='88-golang-path.sh'

    # get_latest_version
    # or fix a version:
    version='1.17.10'
    archive_basename="go${version}.linux-${_OS_ARCH_SHORT}"
    archive_filename="$archive_basename.$archive_ext"

    download_tarball
    install_multi "$_DOWNLOAD_CACHE/$archive_filename" 'golang' "$version"
    install_bashrcd_script 'golang' "$env_filename"

    smoke_test
    inform_user
}

undo() {
    _error "Undo setup golang-4dev NOT available yet, apologies. "
}

main() {

    $mash_action
}

main
