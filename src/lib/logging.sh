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

#: Color settings for color-enabled terminal
__logging__set_colors() {
    C_BOLD='\e[1m'
    C_OFF='\e[0;00m'

    C_FATAL="${C_BOLD}\e[38;5;196m"
    C_ERROR='\e[38;5;9m'
    C_WARN='\e[38;5;3m'
    C_INFO='\e[38;5;14m'
    C_SAY='\e[38;5;15m'
    C_DEBUG='\e[38;5;6m'
    C_TRACE='\e[38;5;13m'
}

# shellcheck disable=2034
__logging__init_color_vars() {

    C_FATAL=
    C_ERROR=
    C_WARN=
    C_INFO=
    C_SAY=
    C_DEBUG=
    C_TRACE=
    C_BOLD=
    C_OFF=

    case "$TERM" in
        *color*)
            __logging__set_colors
            ;;
    esac
}

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

    _LOG_FORMAT_CONSOLE='${time}${color}${level}${coff}:${func} ${color}${msg}${coff}'
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
    echo "!! ${C_SAY}$msg${C_OFF}"
}

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

    # printf '%s: %s\n' "$level_name" "$msg"
    eval "echo \"$_LOG_FORMAT_CONSOLE\""
}

__logging__init() {

    __logging__init_color_vars
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
