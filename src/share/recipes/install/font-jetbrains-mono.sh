#!/bin/sh

# font-jetbrains-mono.sh
# Install JetBrains Mono
# Home page: https://www.jetbrains.com/lp/mono/
# Requires: unzip

import logging

_jbm__download_link='https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip'
_jbm__filename='JetBrainsMono-2.242.zip'
_jbm__target_dir="$_LOCAL/share/fonts/jetbrains-mono"

#: Download into a cache folder.
download_into_cache() {
    if [ -e "$_DOWNLOAD_CACHE/$_jbm__filename" ]; then
        _warn "Archive already downloaded, skipping ($_DOWNLOAD_CACHE/$_jbm__filename)"
    else
        _info "Downloading $_jbm__filename..."
        curl -sSL "$_jbm__download_link" -o "$_DOWNLOAD_CACHE/$_jbm__filename" || {
            _die 33 "$_jbm__filename download FAILED! (rc=$?)"
        }
        _debug "Downloaded URL: [$_jbm__download_link]"
    fi
}

#: Create target directory
create_target_dir() {
    if [ -e "$_jbm__target_dir" ]; then
        _warn "Target directory already exists, skipping ($_jbm__target_dir)"
    else
        mkdir -p "$_jbm__target_dir"
        [ -d "$_jbm__target_dir" ] || die 33 "Could NOT create target directory $_jbm__target_dir !"
        _debug "Created directory [$_jbm__target_dir]"
    fi
}

#: Unzip ttf fonts into target directory
unzip_into_target_dir() {
    unzip -jn "$_DOWNLOAD_CACHE/$_jbm__filename" fonts/ttf/* -d "$_jbm__target_dir" > /dev/null
    unzip -jn "$_DOWNLOAD_CACHE/$_jbm__filename" AUTHORS.txt -d "$_jbm__target_dir" > /dev/null
    unzip -jn "$_DOWNLOAD_CACHE/$_jbm__filename" OFL.txt -d "$_jbm__target_dir" > /dev/null
    _debug "Unzipped ttf fonts and licence into [$_jbm__target_dir]"
}

#: TODO: somehow smoke-test the result
smoke_test() {
    _debug 'TODO: smoke-test the JetBrains-Mono font installation.'
}

inform_user() {
    _info 'JetBrains Mono font family installed.'
    _say 'You may need to *logout out* and *log back in* so the new fonts become available.'
}

doit() {
    download_into_cache
    create_target_dir
    unzip_into_target_dir
    smoke_test
    inform_user
    _info 'DONE.'
}

undo() {
    _info "Removing JetBrains Mono font family:"
    delete_directory "Removing JetBrains-mono font dir $_jbm__target_dir" "$_jbm__target_dir"
    _info "JetBrains Mono font family removed successfully."
}

$mash_action
