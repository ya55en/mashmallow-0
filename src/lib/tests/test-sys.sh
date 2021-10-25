#! /bin/sh

#: Unit tests for `sys.sh` module

# import sys by sys ... but hey, this shows explicitly
# what is under test ;)
import sys
import string
import unittest/assert

setup_mod() {
    _MASH_IMPORT_PATH_OLD="$MASH_IMPORT_PATH"
    __modules_path=
    __test_dir=
}

teardown_mod() {
    MASH_IMPORT_PATH="$_MASH_IMPORT_PATH_OLD"
    unset _MASH_IMPORT_PATH_OLD
    unset __modules_path
    unset __test_dir
}

setup() {
    __modules_path="$(dirname "$_mod_path_")/test-data"
    __test_dir="$(dirname "$_mod_path_")"
}

test__sys__contains_colon__positive() {
    assert_true _sys__contains_colon 'whop:'
    assert_true _sys__contains_colon ':whop'
    assert_true _sys__contains_colon 'w:w'
    assert_true _sys__contains_colon ':'
    assert_true _sys__contains_colon ' : '
}

test__sys__contains_colon__negative() {
    assert_false _sys__contains_colon ''
    assert_false _sys__contains_colon ';'
    assert_false _sys__contains_colon 'whop'
    assert_false _sys__contains_colon '   '
}

test_die__check_rc() {
    (die 123 "Some message" > /dev/null 2>&1)
    assert_equal 123 $?
}

test_die__check_message() {
    local _LOG_FORMAT_TIME_CONSOLE_SAVED="$_LOG_FORMAT_TIME_CONSOLE"
    _LOG_FORMAT_TIME_CONSOLE=
    local stderr_output
    _sys__clear_colors
    stderr_output="$( (die 123 "dying message") 2>&1 )"

    # This would fail when hidden ANSI sequences exist in any of the compared args
    assert_equal "$(len 'FATAL: dying message')" "$(len "$stderr_output")"

    assert_equal 'FATAL: dying message' "$(strip "$stderr_output")"

    # expected='FATAL++: dying message'
    # if [ "$stderr_output" = "$expected" ]; then
    #     echo "EQUAL -- OK!!"
    # else
    #     echo "NOT EQUAL: expected=[$expected] but was stderr_output=[$stderr_output]"
    # fi
    _sys__set_colors
    _LOG_FORMAT_TIME_CONSOLE="$_LOG_FORMAT_TIME_CONSOLE_SAVED"
}

test__sys__process_path__found_case_1() {
    assert_true _sys__process_path "$__modules_path" 'bar'
    assert_equal 'bar_sh_func() called' "$(bar_sh_func)"
}

test__sys__process_path__found_case_2() {
    assert_true _sys__process_path "$__modules_path" 'foorc'
    assert_equal 'foorc_func() called' "$(foorc_func)"
}

test__sys__process_path__found_case_3() {
    assert_true _sys__process_path "$__modules_path" 'foo-pkg/foo-pkg-bar'
    assert_equal 'foo_pkg_bar_sh_func() called' "$(foo_pkg_bar_sh_func)"
}

test__sys__process_path__found_case_4() {
    assert_true _sys__process_path "$__modules_path" 'foo-pkg/foo-pkg-bazzrc'
    assert_equal 'foo_pkg_bazzrc_func() called' "$(foo_pkg_bazzrc_func)"
}

test__sys__process_path__found_case_4() {
    assert_true _sys__process_path "$__modules_path" 'foo-pkg/foo-pkg-bazzrc'
    assert_equal 'foo_pkg_bazzrc_func() called' "$(foo_pkg_bazzrc_func)"
}

test__sys__process_path__not_found_case_1() {
    assert_false _sys__process_path "$__modules_path" 'foo-pkg/nonexistent'
}

test__sys__process_path__not_found_case_2() {
    assert_false _sys__process_path "$__modules_path" 'nonexistent'
}

test__sys__find_module_in_paths__found() {
    local mash_path="$__test_dir/test-data:$__test_dir"
    assert_true _sys__find_module_in_paths "$mash_path" bar
    assert_true _sys__find_module_in_paths "$mash_path" bar.sh # works as well
    assert_true _sys__find_module_in_paths "$mash_path" foo-pkg/foo-pkg-bar
}

test__sys__find_module_in_paths__not_found() {
    local mash_path="$__test_dir/test-data:$__test_dir"
    assert_false _sys__find_module_in_paths "$mash_path" nonexistent
}

test__sys__module_already_imported__standard_case() {
    local _SYS__IMPORTED_MODULES_SAVED="$_SYS__IMPORTED_MODULES"
    _SYS__IMPORTED_MODULES=':one:two:'
    assert_true _sys__module_already_imported one
    assert_true _sys__module_already_imported two
    assert_false _sys__module_already_imported three
    _SYS__IMPORTED_MODULES="$_SYS__IMPORTED_MODULES_SAVED"
}

test__sys__module_already_imported__corner_case() {
    local _SYS__IMPORTED_MODULES_SAVED="$_SYS__IMPORTED_MODULES"
    _SYS__IMPORTED_MODULES=':'
    assert_false _sys__module_already_imported ''
    assert_false _sys__module_already_imported any
    _SYS__IMPORTED_MODULES="$_SYS__IMPORTED_MODULES_SAVED"
}
