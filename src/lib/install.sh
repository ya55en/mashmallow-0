#! /bin/sh

import logging
import assert

_install_name_='install.sh'

install_single() {
    echo "install_single($1, $2, $3, $4) called!"
    # $1 - path to source, $2 - name, $3 - version, $4 - relative path to binary
    dir_fullpath="$_LOCAL/opt/$2/$3"
    mkdir -p "$dir_fullpath"
    ln -fs  "$dir_fullpath" "$_LOCAL/opt/$2/current"
    cp -pr "$1" "$dir_fullpath"
    chmod +x "$dir_fullpath/$4"
    ln -fs "$_LOCAL/opt/$2/current/$4" "$_LOCAL/bin/$2"
}


if [ "$_name_" = "$_install_name_" ]; then
    _error "$_install_name_ is a library to be sourced, not executed."
fi
