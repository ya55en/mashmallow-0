#! /bin/sh

# pycharm-community.sh
# Install Pycharm Community edition

# Assumming lib/libma.sh has been sourced already.

import logging
import removal
import install

version='2022.1.1'
flavor='community'

pycharm_filename="pycharm-${flavor}-${version}.tar.gz"
pycharm_dir="$_LOCAL/opt/pycharm-${flavor}-${version}"
dot_desktop_file_src='com.jetbrains.pycharm-any.desktop'
dot_desktop_file_dst="com.jetbrains.pycharm-${flavor}.desktop"

_URL_DOWNLOAD="https://download-cdn.jetbrains.com/python/${pycharm_filename}"
_URL_HASHSUM="https://download-cdn.jetbrains.com/python/${pycharm_filename}.sha256"

download_tarball() {
    #: Download pycharm tarball into $_DOWNLOAD_CACHE
    skip="${1:-no-skip}"

    if [ "x$skip" = xskip-if-exists ] && [ -f "${_DOWNLOAD_CACHE}/${pycharm_filename}" ]; then
        _warn "File exits: ${_DOWNLOAD_CACHE}/${pycharm_filename}"
        _warn "Target archive already downloaded, skipping."
    else
        _debug "_URL_DOWNLOAD=$_URL_DOWNLOAD"
        _debug "_URL_DOWNLOAD=$_URL_HASHSUM"
        _debug "_DOWNLOAD_CACHE=$_DOWNLOAD_CACHE"
        _info "Downloading Pycharm ${flavor} edition, v${version}..."
        rm -f "${_DOWNLOAD_CACHE}/${pycharm_filename}"
        curl -sSL "$_URL_DOWNLOAD" -o "${_DOWNLOAD_CACHE}/${pycharm_filename}" ||
            die 9 "Download failed. (URL: $_URL_DOWNLOAD)"
    fi
}

check_hashsum() {
    # TODO: check sha256 from $_URL_HASHSUM
    #   sha256sum -c pycharm-community-2021.2.2.tar.gz.sha256
    /bin/true
}

install_dot_desktop() {
    dot_desktop_fullpath="$_LOCAL/share/applications/${dot_desktop_file_dst}"
    mkdir -p "$_LOCAL/share/applications"
    if [ -e "${dot_desktop_fullpath}" ]; then
        _warn "Dot-desktop file exists, skipping. (${dot_desktop_fullpath})"
    else
        _info "Installing a dot-desktop file ... (${dot_desktop_fullpath})"
        # shellcheck disable=SC1090
        . "${_APPLICATIONS_DIR}/${dot_desktop_file_src}" > "${dot_desktop_fullpath}"
    fi
}

smoke_test() {
    #: Smoke-test the installation invoking 'printenv.py' from
    #: pycharm's bin/ directory.

    # shellcheck disable=SC1090
    . "$HOME/.bashrc.d/42-pycharm-${flavor}.sh"
    fsnotifier --version || die 9 "Smoke test running 'fsnotifier --version' FAILED."
    _debug "Smoke Test: OK (fsnotifier --version)"
}

instruct_user() {
    cat << EOS

In order to have all your terminals know about the add-to-path change,
you need to:
  - EITHER source the add-top-path script (see below) in all open terminals,
  - OR log out, then log back in.

To source the add-to-path script, do (note the dot in front):

 $ . "~/.bashrc.d/42-pycharm-${flavor}.sh"

 Pycharm should be then accessible from anywhere on the command line,
 with:

  $ pycharm.sh

EOS
}

doit() {
    _debug "Installing pycharm version=[$version], flavor=${flavor}"
    download_tarball skip-if-exists
    check_hashsum
    install_multi "$_DOWNLOAD_CACHE/$pycharm_filename" "pycharm-$flavor" "$version"
    install_bashrcd_script "pycharm-$flavor" "42-pycharm-$flavor.sh"
    install_dot_desktop
    smoke_test
    instruct_user
    _info 'SUCCESS.'
}

undo() {

    _info "Removing pycharm version=[$version], flavor=${flavor}:"
    delete_files "Removing $HOME/.bashrc.d/42-pycharm-${flavor}.sh..." "$HOME/.bashrc.d/42-pycharm-${flavor}.sh"
    delete_files "Removing $_LOCAL/opt/pycharm-${flavor} symlink..." "$_LOCAL/opt/pycharm-${flavor}"
    delete_files "Removing dot-desktop $_LOCAL/share/applications/${dot_desktop_file_dst} ..." "$_LOCAL/share/applications/${dot_desktop_file_dst}"
    delete_directory "Removing $pycharm_dir..." "$pycharm_dir"
    cat << EOS

In order to have all your terminals know about the add-to-path change,
you need to close (and re-open) all open terminals, OR log out, then log
back in.

pycharm removed successfully.

EOS
}

$mash_action
