#! /bin/sh

. "$MASH_HOME/lib/sys.sh"

import mashrc
import unittest/assert
import os

test_os_vars() {
    local expected_arch="$(uname -p)"
    local expected_os="$(uname -o)"
    local expected_kernel_name="$(uname -s)"

    assert_equal "$expected_arch" "$_OS_ARCH"
    assert_equal "$expected_os" "$_OS_OS"
    assert_equal "$expected_kernel_name" "$_OS_KERNEL_NAME"
}

test_set_arch_short() {
    assert_equal 'amd64' "$(_os__get_arch_short x86_64)"
    assert_equal '386' "$(_os__get_arch_short x86)"
}
