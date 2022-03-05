#!/bin/sh

# Install nodejs LTS
# https://nodejs.org/dist/v16.13.0/node-v16.13.0-linux-x64.tar.xz

import logging
import os
import install

import mashrc

#: Print argument with all letters converted to lowercase.
#: (See https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash)
#: TODO: move to stdlib string.sh.
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

download_nodejs_tarball() {
    mkdir -p "$_DOWNLOAD_CACHE"
    if [ -e "$download_path" ]; then
        _warn "Nodejs archive already downloaded/cached, skipping."
        _debug "Tarball exists: [$download_path]"
    else
        _info "Downloading nodejs tarball ($download_url)..."
        curl -fsSL "$download_url" -o "$download_path"
        _debug "Tarball downloaded to [$download_path]."
    fi
}

#: Create environment setup script in ~/.bashrc.d/
create_env_setup_script() {
    local linked_dir="$_LOCAL/opt/${opt_dir}/current"
    local env_file="$HOME/.bashrc.d/76-nodejs-env.sh"

    cat > "$env_file" << EOS
# ~/.bashrc.d/76-nodejs-env.sh - mash: add nodejs/bin to PATH

NODE_HOME='${linked_dir}' ; export NODE_HOME
echo \$PATH | grep -q "\$NODE_HOME/bin" || PATH="\$NODE_HOME/bin:\$PATH"

EOS
    . "$env_file"
}

upgrade_npm() {
    # See https://docs.npmjs.com/try-the-latest-stable-version-of-npm
    # See also https://www.geeksforgeeks.org/how-to-update-npm/

    _info "Current npm version: $(npm -v)"
    _info "Updating npm..."
    # npm install -g npm@latest  # FIXME: bring back the latest stable
    npm install -g npm@7
    _info "Updated npm version: $(npm -v)"
}

install_yarn() {
    # See https://classic.yarnpkg.com/lang/en/docs/install/
    _info "Installing yarn..."
    npm install -g yarn@latest
    _info "Yarn current version: $(yarn -v)"
}

smoke_test() {
    _info 'Running a smoke test for installed software...'
    node -v
    npm -v
    yarn -v
}

inform_user() {
    _info 'SUCCESS!'
    _warn 'You need to **close and reopen** all your terminals now.'
    _warn 'Then you will be able to use node, npm and yarn, like:'
    cat <<EOS

 $ node --help
 $ npm --help
 $ yarm --help

EOS
}

doit() {
    _info "Setting up nodejs $version..."
    download_nodejs_tarball
    install_multi "$download_path" 'nodejs' "$version"
    create_env_setup_script
    upgrade_npm
    install_yarn
    smoke_test
    inform_user
}

undo() {
    # TODO: provide an undo procedure.
    _error 'Not supporting "undo setup" at the moment, apologies.'
}

main() {
    # TODO: get the latest version automagically [1]
    # Looking here for older versions: https://nodejs.org/dist/
    # local version='16.13.0' # FIXME: bring the latest LTS back
    local version='15.14.0'
    local download_url='N/A'
    local download_path='N/A'
    local os_kernel='N/A'
    local arch='N/A'
    local os_name='N/A'
    local archive_main_name='N/A'
    local archive_ext='tar.xz'
    local archive_filename='N/A'
    local opt_dir='nodejs'

    case "$_OS_ARCH" in
    x86_64)
        arch='x64'
        ;;
    *)
        die 33 "Unsupported architecture: [$_OS_ARCH]"
        ;;
    esac

    os_name="$(to_lower $_OS_KERNEL_NAME)"
    archive_main_name="node-v${version}-${os_name}-${arch}"
    archive_filename="${archive_main_name}.${archive_ext}"
    download_url="https://nodejs.org/dist/v${version}/${archive_filename}"
    download_path="$_DOWNLOAD_CACHE/$archive_filename"

    $mash_action
}

main

# [1] the download page at view-source:https://nodejs.org/en/download/ contains
# a section like: ... Latest LTS Version: <strong>16.13.0</strong> (includes npm 8.1.0)
# - using that with a proper regexp should be fine.
