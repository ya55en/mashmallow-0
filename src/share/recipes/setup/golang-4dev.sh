#!/bin/sh

#: Setup golang for development
#: https://go.dev/doc/install, https://go.dev/dl/

import logging
import os

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

extract_tarball() {
    local target_dir="$_LOCAL/opt/$opt_dir"

    if [ -e "$target_dir/$version" ]; then
        _warn "Current version seems to have been installed in $target_dir/$version"
    else
        mkdir -p "$target_dir"
        _info "Extracting tarball into $target_dir ..."
        tar xf "$_DOWNLOAD_CACHE/$archive_filename" -C "$target_dir"
        mv "$target_dir/go" "$target_dir/${version}"
    fi
}

create_symlink() {
    local target_dir="$_LOCAL/opt/$opt_dir"
    if [ -L "$target_dir/current" ]; then
        _warn "Symlink $target_dir/current has already been created, skipping."
    else
        _info "Creating symlink 'current' to $target_dir/$version ..."
        into_dir_do "$target_dir" "ln -s $version current"
        [ -e "$target_dir/$version" ] || {
            die 33 "Creating symlink 'current' to $target_dir/$version FAILED"
        }
    fi
}

#create_bashrcd_script() {
#    _info "create_bashrcd_script..."
#}
#: Create environment setup script in ~/.bashrc.d/
create_bashrcd_script() {
    local linked_dir="$_LOCAL/opt/${opt_dir}/current"

    env_script_fullpath="$HOME/.bashrc.d/88-golang-path.sh"
    if [ -e "$env_script_fullpath" ]; then
        _warn "Env setup script for golang already exists, skipping ($env_script_fullpath)"
        return 4
    fi

    _info "Creating env setup script ($env_script_fullpath) ..."
    cat > "$env_script_fullpath" << EOS
# $env_script_fullpath - mash: add golang bin to PATH

_GO_HOME='${linked_dir}'
echo \$PATH | grep -q "\$_GO_HOME/bin" || PATH="\$_GO_HOME/bin:\$PATH"

EOS
}

smoke_test() {
    _info "Smoke-testing the installation..."
    . "$env_script_fullpath"

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

doit() {
    # https://go.dev/dl/go1.17.3.linux-amd64.tar.gz
    local _arch
    local dl_base_url='https://go.dev/dl/'
    local version
    local archive_basename
    local archive_ext='tar.gz'
    local archive_filename
    local opt_dir='golang'
    local env_script_fullpath

    get_latest_version
    archive_basename="go${version}.linux-${_OS_ARCH_SHORT}"
    archive_filename="$archive_basename.$archive_ext"

    download_tarball
    extract_tarball
    create_symlink
    create_bashrcd_script
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
