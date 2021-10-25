#! /bin/sh
# Non-executable: string lib

_strip() {
    local special="$1"
    local str="$2"
    local chars="${3:- }"
    local res="$str"
    local res_old

    while true; do
        res_old="$res"
        # shellcheck disable=1083,2086
        eval "res="\${res${special}${chars}}""
        [ "$res_old" = "$res" ] && break
    done
    printf '%s' "$res"
}

#: TODO: doc
lstrip() {
    local _FUNCNAME=lstrip
    _debug "\$#=[$#]" >&2

    [ "$#" = 2 ] && [ -z "$2" ] && {
        printf '%s' "$1"
        return 0
    }

    _strip '#' "$1" "$2"
}

#: TODO: doc
rstrip() {
    local _FUNCNAME=rstrip
    _debug "\$#=[$#]" >&2

    [ "$#" = 2 ] && [ -z "$2" ] && {
        printf '%s' "$1"
        return 0
    }

    _strip '%' "$1" "$2"
}

#: TODO: doc
strip() {
    local _FUNCNAME=strip
    _debug "\$#=[$#]" >&2

    [ "$#" = 2 ] && [ -z "$2" ] && {
        printf '%s' "$1"
        return 0
    }

    local str="$1"
    local chars="${2:- }"
    local lstripped
    local rstripped

    lstripped=$(lstrip "$str" "$chars")
    rstripped=$(rstrip "$lstripped" "$chars")
    printf '%s' "$rstripped"
}

#: Evaluates the string argument and prints the resulting string.
reeval() {
    eval "printf '%s' $1"
}


#: Print length of given argument to stdout.
len() {
    printf '%u' ${#1}
}
