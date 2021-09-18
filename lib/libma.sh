#! /bin/sh
# libmash - Library functions to use from mash scripts (Bourne Shell)

_ARCH=x86_64
_LOCAL="$HOME/.local"

DEBUG=false  # use DEBUG=false to suppress debugging


die() { rc=$1; msg="$2"
    echo "CRITICAL: $msg"
    exit $rc
}


log() { level=$1; msg="$2"
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

into_dir_do() {  dir="$1" script="$2"
    [ -z "${script}" ] && die 42 "into_dir_do() called with empty script: [$script]"

    cwd="$(pwd)" && cd "$dir" && eval "$script" || die 42 "into_dir_do() - script [$script] failed with rc=$?"
    cd "$cwd"
}
