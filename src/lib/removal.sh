#! /bin/sh

import logging
import assert

_rm_name_='removal.sh'

_delete_file() {
    if [ -e "$1" ]
    then
        _debug "Removing $1.."
        rm "$1"
        rc=$? # saving rc for the error message
        if [ $rc -ne 0 ]; then
            _error "'rm $1' failed! rc=$rc"
            return 1
        fi
    else
        _warn "Trying to remove $1 but it does not exist! Skipping."
    fi
}

delete_files() {
    failed=0
    if ! [ -z "$1" ]; then # skip printing the message if empty
        _info "$1"
    fi
    shift  # first argument must always be info string to print, the rest of the arguments are files
    for var in "$@"
    do
        _delete_file "$var"
        failed=$(($failed + $?))
    done
    return "$failed"
}

delete_directory() {
    if ! [ -z "$1" ]; then # skip printing the message if empty
        _info "$1"
    fi
    shift  # first argument must always be info string to print, the second is the directory
    if [ -d "$1" ]; then
        _debug "Removing directory $1.."
        rm -r "$1"
        rc=$? # saving rc for the error message
        if [ $rc -ne 0 ]; then
            _error "'rm -r $1' failed! rc=$rc"
            return 1
        fi
    else
        _warn "Trying to remove directory $1 but it does not exist (or is a file)! Skipping."
    fi
}

apt_remove() {
    if dpkg -s $1; then
        _info "Removing $1..."
        sudo apt remove -y $1
    else
        _warn "Attempting to remove package(s) $1 but they were not installed! Skipping."
    fi
}

apt_purge() {
    if dpkg -s $1; then
        _info "Purging $1..."
        sudo apt purge $1 # not using -y here because of issue #19
    else
        _warn "Attempting to purge package(s) $1 but they were not installed! Skipping."
    fi
}

if [ "$_name_" = "$_rm_name_" ]; then
    _error "$_rm_name_ is a library to be sourced, not executed."
fi
