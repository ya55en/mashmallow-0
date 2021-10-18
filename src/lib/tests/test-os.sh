#! /bin/sh

. "$MASH_HOME/lib/sys.sh"

_name_="$(basename "$0")"
_tos_name_='test-os.sh'

import lib-4test
import os
import mashrc

test_os_vars() {
    _curr_test_=test_os_vars
    # shellcheck disable=2003,2086
    no=$(expr $no + 1)

    local expected_arch="$(uname -p)"
    local expected_os="$(uname -o)"
    local expected_kernel_name="$(uname -s)"

    assert_equal "$expected_arch" "$_OS_ARCH"
    assert_equal "$expected_os" "$_OS_OS"
    assert_equal "$expected_kernel_name" "$_OS_KERNEL_NAME"

    print_pass
}

test_set_arch_short() {
    _curr_test_=test_set_arch_short
    # shellcheck disable=2003,2086
    no=$(expr $no + 1)

    assert_equal 'amd64' "$(_os__get_arch_short x86_64)"
    assert_equal '386' "$(_os__get_arch_short x86)"

    print_pass
}

test() {
    set -e
    local no=0

    test_os_vars
    test_set_arch_short

    # Exits with die() ; suppressed.
    # _os__get_arch_short foo_bar
}

if [ "$_name_" = "$_tos_name_" ]; then
    test
fi
