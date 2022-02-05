#! /bin/sh

import logging
import assert

_install_name_='install.sh'

#: $1 - path to source, $2 - name, $3 - version, $4 (optional) - relative path to binary (w/o the first dir)
install_single() {
    echo "install_single($1, $2, $3, $4) called!"
    dir_fullpath="$_LOCAL/opt/$2/$3"
    mkdir -p "$dir_fullpath"
    ln -fs  "$dir_fullpath" "$_LOCAL/opt/$2/current"
    cp -pr "$1" "$dir_fullpath/$2"
    if [ -z "$4" ]; then
        path_to_bin="$2"
    else
        path_to_bin="$2/$4"
    fi
    chmod +x "$dir_fullpath/$path_to_bin"
    ln -fs "$_LOCAL/opt/$2/current/$path_to_bin" "$_LOCAL/bin/$2"
}


if [ "$_name_" = "$_install_name_" ]; then
    _error "$_install_name_ is a library to be sourced, not executed."
fi
