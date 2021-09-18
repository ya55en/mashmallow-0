#! /bin/sh
# libmash - Library functions to use from mash scripts (Bourne Shell)

# shellcheck disable=SC2034  # Varables used in sourced scripts.
_ARCH=x86_64
_LOCAL="$HOME/.local"

DEBUG=false # use DEBUG=false to suppress debugging

die() {
    rc=$1
    msg="$2"
    echo "CRITICAL: $msg"
    exit $rc
}

log() {
    level=$1
    msg="$2"
    #: Log the message (conditionally if a debug message)
    case $level in
        err*)
            echo "ERROR: $msg"
            ;;
        warn*)
            echo "WARN: $msg"
            ;;
        info*)
            echo "I: $msg"
            ;;
        debug*)
            $DEBUG && echo "DEBUG: $msg"
            ;;
        testfail)
            echo "TEST-FAIL: $msg"
            ;;
        assertfail)
            echo "ASSERT-FAIL: $msg"
            ;;
        *)
            die 4 "Unknown log level $level"
            ;;
    esac
}

# into_dir_do "$_LOCAL/bin" 'ln -s $(which python3) python'

into_dir_do() {
    #: Save current working dir (cwd), then `cd` to given dir and execute
    #: the script, then `cd` back to the original dir.

    dir="$1" script="$2"

    [ -z "${script}" ] && die 42 "into_dir_do() called with empty script: [$script]"

    cwd="$(pwd)"
    rc=0
    cd "$dir" || {
        log error "cd into $dir FAILED"
        return $?
    }
    eval "$script" || {
        log error "into_dir_do(): eval FAILED: script=[$script]"
        return $?
    }
    cd "$cwd" || return 0
}
