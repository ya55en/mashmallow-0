#!/bin/sh

# An 'import' "statement" - a function of a single argument which
# is the name of a 'module' - the filename w/o '.sh' extension of
# a shell library. That shell library is looked up in all paths
# listed in MASH_IMPORT_PATH and sourced if found, othewise
# 'import' exits with a message and rc=5.

_sys__noop 2> /dev/null && return 0 # guard against multiple sourcing

. "$MASH_HOME/lib/logging.sh"

_name_="$(basename "$0")"
_path_="$(dirname "$0")"
_sys_name_='sys.sh'

_SYS__IMPORTED_MODULES=':sys:' # Store imported modules here, colon-delimited
_SYS__MODEXT='.sh'             # default module file extension

#: Terminate execution with given message and rc and.
die() {
    rc=$1
    msg="$2"

    _fatal "$msg" >&2
    #echo "${C_FATAL}FATAL: $msg${C_OFF}" >&2
    exit $rc
}

#: A noop function used to detect whether sys.sh has already been
#: sourced.
_sys__noop() { :; }

#: Color settings for color-enabled terminal
_sys__set_colors() {
    C_BOLD='\033[1m'
    C_BOFF='\033[22m'
    C_OFF='\033[0;00m'

    C_FATAL="\033[38;5;160m"
    C_ERROR='\033[38;5;9m'
    C_WARN='\033[38;5;3m'
    C_INFO='\033[38;5;14m'
    C_SAY='\033[38;5;15m'
    C_DEBUG='\033[38;5;6m'
    C_TRACE='\033[38;5;13m'
    C_OK='\033[38;5;34m'
}

#: Color settings for color-enabled terminal
_sys__clear_colors() {
    C_BOLD=
    C_BOFF=
    C_OFF=

    C_FATAL=
    C_ERROR=
    C_WARN=
    C_INFO=
    C_SAY=
    C_DEBUG=
    C_TRACE=
    C_OK=
}

# shell check disable=2034
_sys__init_color_vars() {

    case "$TERM" in
    *color*)
        _sys__set_colors
        ;;
    *)
        _sys__clear_colors
        ;;
    esac
}

#: Return true if given `$str` contains a colon, false (rc=1) otherwise.
_sys__contains_colon() {
    local str="$1"

    case "$str" in
    *:*)
        return 0
        ;;
    esac
    return 1
}

#: Check if $mod_name (defined in `import()`) or $mod_name${MODEXT}
#: exists in given `$path` and if so -- source it and return true,
#: otherwise return false (rc=1).
_sys__process_path() {
    local path="$1"
    local mod_name="$2"
    _debug "_sys__process_path: path=[$path]  mod_name=[$mod_name]"

    local full_path="${path}/${mod_name}"
    local full_path_ext="${path}/${mod_name}${_SYS__MODEXT}"

    # printf 'full_path=[%s]\n' "$full_path"
    if [ -e "$full_path_ext" ]; then
        . "$full_path_ext" || die 6 "Sourcing FAILED (1:rc=$?) for [$full_path_ext]"
        _debug "_sys__process_path: $mod_name SOURCED."
        return 0

    elif [ -e "$full_path" ]; then
        . "$full_path" || die 6 "Sourcing FAILED (2:rc=$?) for [$full_path]"
        # [ "$DEBUG" = true ] && printf '%s SOURCED.\n' "${mod_name}"
        _debug "_sys__process_path: $mod_name SOURCED."
        return 0

    else
        # printf 'hey, %s not found here.\n' "${mod_filename}"
        return 1
    fi
}

#: Look up module `$mod_filename` (defined in `import()`) in all paths
#: of given colon-delimited `$path_list`. If found -- source that module
#: and return true, otherwise return false (rc=1).
_sys__find_module_in_paths() {
    local path_list="$1"
    local mod_name="$2"

    local IFS_OLD
    local rc=1 # not found (until proven otherwise)

    IFS_OLD="$IFS"
    IFS=':'

    while _sys__contains_colon "$path_list"; do
        read -r path path_list << EOF
$path_list
EOF
        _sys__process_path "$path" "$mod_name" && {
            rc=0 # found!
            break
        }
    done

    [ -n "$path_list" ] && {
        _sys__process_path "$path_list" "$mod_name" && rc=0 # found!
    }

    IFS="$IFS_OLD"
    return $rc
}

#: Return true if module has been imported already; false otherwise.
_sys__module_already_imported() {
    local mod_name="$1"

    case "$_SYS__IMPORTED_MODULES" in
    *:"$mod_name":*)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

#: Looks up for a shell module in MASH_IMPORT_PATH and sources it, if found,
#: otherwise prints an error message and exits rc=5. (See the sys.sh header
#: comment for more details.)
import() {
    local mod_name="$1"
    # local mod_filename="${mod_name}${_SYS__MODEXT}"
    [ -n "$mod_name" ] || die 31 "IMPORT ERROR: empty module name: [$mod_name]"

    if _sys__module_already_imported "$mod_name"; then
        _debug "import: Module ALREADY imported: [$mod_name]"
        return 0
    fi

    if _sys__find_module_in_paths "$MASH_IMPORT_PATH" "$mod_name"; then
        _SYS__IMPORTED_MODULES=":$mod_name:$_SYS__IMPORTED_MODULES"
        _debug "import: _SYS_IMPORTED_MODULES=[$_SYS__IMPORTED_MODULES]"

    else
        # shellcheck disable=2059
        {
            printf "${C_ERROR}IMPORT ERROR: Module ${C_OFF}${C_BOLD}'$mod_name'${C_OFF} ${C_ERROR}"
            printf "NOT found in MASH_IMPORT_PATH${C_OFF}\n"
            printf "MASH_IMPORT_PATH='$MASH_IMPORT_PATH'\n"
        }
        exit 5
    fi
}

#: Initialize the sys module.
_sys__init() {
    _sys__init_color_vars
    [ -z "$_SYS__IMPORTED_MODULES" ] && _SYS__IMPORTED_MODULES=':sys:'
    _debug "_sys_: _name_=[$_name_] _sys_name_=[$_sys_name_]"
}

# main:
if [ "$_name_" = "$_sys_name_" ]; then
    _error "$_sys_name_ is a library - not callable directly."
    exit 1
else
    _sys__init
fi
