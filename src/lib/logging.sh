#!/bin/sh
#: Logging library for the mashmallow-0 project.

#: Features:
#: Log levels: DEBUG, INFO, NOTE/SAY, WARN, ERROR, FATAL
#: Colorful output in case the terminal supports colors.
#: Output goes to:
#: - console (if configured)
#: - file  (if configured) - TODO
#:
#: Functions that need their name shown in the log should assign that
#: to a `local _FUNCNAME` (very important to use a local variable!).
#: See `src/lib/tests/test-logging.sh` for an example.

# Default level if not configured otherwise is INFO
MASH_LOG_LEVEL=${MASH_LOG_LEVEL:-INFO}

# If DEBUG is set to true - tune the level to DEBUG
[ "$DEBUG" = true ] && MASH_LOG_LEVEL=DEBUG

# shellcheck disable=2034
__logging__set_global_vars() {

    _LOG_LEVEL_FATAL=50
    _LOG_LEVEL_ERROR=40
    _LOG_LEVEL_WARN=30
    _LOG_LEVEL_INFO=20
    _LOG_LEVEL_DEBUG=10

    _LOG_LEVEL_50=FATAL
    _LOG_LEVEL_40=ERROR
    _LOG_LEVEL_30=WARN
    _LOG_LEVEL_20=INFO
    _LOG_LEVEL_10=DEBUG

    # Level tag actually shown on the console log output:
    _LOG_LEVEL_C_50=FATAL
    _LOG_LEVEL_C_40=E
    _LOG_LEVEL_C_30=W
    _LOG_LEVEL_C_20=I
    _LOG_LEVEL_C_10=D

    _LOG_CONSOLE=/dev/stdout    # or empty
    _LOG_FILE=/var/log/mash.log # or empty

    _LOG_FORMAT_CONSOLE='${time}${color}${level}:${C_BOLD}${func}${C_BOFF} ${msg}${coff}'
    _LOG_FORMAT_FILE='${time}${level}: ${msg}'
    _LOG_FORMAT_TIME_FILE='%d %b %H:%M:%S'
    _LOG_FORMAT_TIME_CONSOLE='%H:%M:%S'
}

logging__level_for() {
    eval "echo \$_LOG_LEVEL_${1}"
}

logging__set_level() {
    local level_name="$1"

    case "$level_name" in
        FATAL | ERROR | WARN | INFO | DEBUG)
            _LOG_LEVEL=$(logging__level_for "$1")
            ;;
        *)
            die 44 "Illegal log level name: [$level_name]"
            ;;
    esac
}

logging__say() {
    local msg="$1"
    echo "!! ${C_SAY}${msg}${C_OFF}"
}

# TODO: When printing on console, make `_fatal` and `_error` print to stderr
#   and the rest print to stdout

logging__log() {
    # printf '\nTRACE: msg_level=[%s] _LOG_LEVEL=[%s]\n' "$1" "$_LOG_LEVEL"
    [ "$1" -ge "$_LOG_LEVEL" ] || return 0

    local msg_level="$1"
    local msg="$2"
    local level_name
    local level

    eval "level_name="\$_LOG_LEVEL_${msg_level}""
    eval "level="\$_LOG_LEVEL_C_${msg_level}""

    local func=
    local time=
    [ -n "$_FUNCNAME" ] && func=" ${_FUNCNAME}:"
    [ -n "$_LOG_FORMAT_TIME_CONSOLE" ] && time="$(date "+$_LOG_FORMAT_TIME_CONSOLE") "
    local coff=$C_OFF
    local color=
    eval "color=\$C_${level_name}"
    eval "echo \"$_LOG_FORMAT_CONSOLE\""
}

__logging__init() {
    __logging__set_global_vars
    logging__set_level "$MASH_LOG_LEVEL"

    # shellcheck disable=2139
    {
        alias _fatal="logging__log $_LOG_LEVEL_FATAL"
        alias _warn="logging__log $_LOG_LEVEL_WARN"
        alias _error="logging__log $_LOG_LEVEL_ERROR"
        alias _info="logging__log $_LOG_LEVEL_INFO"
        alias _debug="logging__log $_LOG_LEVEL_DEBUG"
        alias _say="logging__say"
    }

}

__logging__init
