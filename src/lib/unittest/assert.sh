#! /bin/sh
#
# lib-4tests.py
# Library with test utility functions like `assert_equal()`.
# Should be sourced; execution makes sense only for running its own tests.
# (Use 'test' as first (and only) argument when you want to do do.)

# TODO: currently print_pass executes always,
#   even if one or more of the sub-tests fail.
# TODO: provide a wrapper for test execution.

_name_="$(basename "$0")"
_l4t_name_='lib-4test.sh'
#echo "$_l4t_name_: _name_=[$_name_], _l4t_name_=[$_l4t_name_]"

_curr_test_=''

is_num() {
    [ "$1" -eq "$1" ] 2> /dev/null
}

# shellcheck disable=2120
#print_pass() {
#    passmsg="${1:-passed}"
#    printf 'ok %u - %s: %s\n' $no $_curr_test_ "$passmsg"
#}
print_pass() {
    passmsg="${1:-pass}"
    # printf 'ok %u - %s: %s\n' $no $_curr_test_ "${C_OK}${passmsg}${C_OFF}"
    echo "ok $no - $_curr_test_: ${C_OK}${passmsg}${C_OFF}"
}

print_fail() {
    failmsg="$1"
    # printf 'not ok %u - %s: %s\n' $no $_curr_test_ "$failmsg"
    echo "not ok $no - ${C_ERROR}$_curr_test_: ${failmsg}${C_OFF}"

    # _curr_test_rc_ is local for the test runner and reflects any failed checks
    _curr_test_rc_=$(expr $_curr_test_rc + 1)
}

print_error() {
    failmsg="$1"
    # printf '%s: %s\n' $_curr_test_ "$failmsg" >&2
    echo "${C_ERROR}${_curr_test_}: ${failmsg}${C_OFF}" >&2

    # _curr_test_rc_ is local for the test runner and reflects any failed checks
    _curr_test_rc_=$(expr $_curr_test_rc + 1)
}

check_arg_is_num() {
    local arg="$1"
    local arg_name="$2"

    is_num "$arg" || {
        print_error "$arg_name=[$arg] is NOT an integer"
        return 1
    }
}

check_two_args_are_num() {
    local actual="$1"
    local expected="$2"

    check_arg_is_num "$expected" expected && check_arg_is_num "$actual" actual
}

assert_equal() {
    local actual="$1"
    local expected="$2"
    # printf '===> assert_equal [%s] [%s] called\n' "$actual" "$expected"

    if [ "$actual" != "$expected" ]; then
        print_fail "assert_equal FAILED: '$actual' != '$expected'"
        return 1
    fi
}

assert_equal_num() {
    check_two_args_are_num "$1" "$2" || return 1

    local actual="$1"
    local expected="$2"

    # shellcheck disable=2086
    if [ $actual -ne $expected ] 2> /dev/null; then
        print_fail "assert_equal_num FAILED: '$actual' != '$expected'"
        return 1
    fi
}

assert_not_equal() {
    local actual="$1"
    local expected="$2"

    # shellcheck disable=2003,2086
    if [ "$actual" = "$expected" ]; then
        print_fail "assert_not_equal FAILED: '$actual' = '$expected'"
        return 1
    fi
}

assert_not_equal_num() {
    check_two_args_are_num "$1" "$2" || return 1

    local actual="$1"
    local expected="$2"

    # shellcheck disable=2003,2086
    if [ $actual -eq $expected ]; then
        print_fail "assert_not_equal_num FAILED: '$actual' != '$expected'"
        return 1
    fi
}

assert_true() {
    "$@" || {
        local args_quoted="$1"
        shift
        for arg in "$@"; do args_quoted="$args_quoted '$arg'"; done
        print_fail "assert_true FAILED for [$args_quoted]"
        return 1
    }
}

assert_false() {
    ! "$@" || {
        local args_quoted="$1"
        shift
        for arg in "$@"; do args_quoted="$args_quoted '$arg'"; done
        print_fail "assert_false FAILED for [$*]"
        return 1
    }

    # Trying to provide a way to have a dooubkle ! but failed
    # if "$@"; then
    #     print_fail "assert_false FAILED for [$cmd]"
    #     return 1
    # else
    #     return 0
    # fi
}

assert_rc_equal() {
    local expected_rc="$1"
    check_arg_is_num "$expected_rc" expected_rc || return 1
    shift
    local cmd="$*"

    $cmd
    [ "$?" != "$expected_rc" ]
}
