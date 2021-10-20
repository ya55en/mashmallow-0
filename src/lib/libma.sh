#! /bin/sh
# libmash - Library functions to use from mash scripts (Bourne Shell)

# shellcheck disable=SC2034  # Varables used in sourced scripts.
_ARCH=x86_64
_LOCAL="$HOME/.local"

import logging

die() {
    rc=$1
    msg="$2"

    echo "FATAL: $msg"
    exit $rc
}

#include() {
#    lib_script="$1"
#
#    # shellcheck disable=SC1090
#    . "${_LIB_DIR}/${lib_script}"
#}

#log() {
#    #: Log the message (conditionally if a debug message)
#
#    level=$1
#    msg="$2"
#    case $level in
#        err*)
#            echo "ERROR: $msg" >> /dev/stderr
#            ;;
#        warn*)
#            echo "WARN: $msg" >> /dev/stderr
#            ;;
#        info*)
#            echo "I: $msg"
#            ;;
#        debug*)
#            [ x$DEBUG = xtrue ] && echo "DEBUG: $msg" >> /dev/stderr
#            ;;
#        testfail)
#            echo "TEST-FAIL: $msg"
#            ;;
#        assertfail)
#            echo "ASSERT-FAIL: $msg"
#            ;;
#        *)
#            die 4 "Unknown log level $level"
#            ;;
#    esac
#}

# into_dir_do "$_LOCAL/bin" 'ln -s $(which python3) python'

into_dir_do() {
    #: Save current working dir (cwd), then `cd` to given dir and execute
    #: the script, then `cd` back to the original dir.

    dir="$1" script="$2"

    [ -z "${script}" ] && die 42 "into_dir_do() called with empty script: [$script]"

    cwd="$(pwd)"
    rc=0
    cd "$dir" || {
        _error "cd into $dir FAILED"
        return $?
    }
    eval "$script" || {
        _error "into_dir_do(): eval FAILED: script=[$script]"
        return $?
    }
    _debug "into_dir_do(): eval rc=$?"
    cd "$cwd" || return 0
}

## string functions

capitalize() {
    #: Echo back a capitalized version of given word.
    # (based on https://stackoverflow.com/questions/12487424)

    word="$1"
    echo "$word" | sed 's/.*/\u&/'
}
