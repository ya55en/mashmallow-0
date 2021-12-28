#! /bin/sh

import unittest/assert
import removal

test_delete_file() {
    touch '/tmp/test-removal-0'
    _delete_file '/tmp/test-removal-0'
    assert_false [ -e '/tmp/test-removal-0' ]
}

test_delete_file_nonexistent() {
    _delete_file '/tmp/test-removal-0'
    assert_equal 0 $?
}

test_delete_files() {
    touch '/tmp/test-removal-1'
    touch '/tmp/test-removal-2'
    touch '/tmp/test-removal-3'
    delete_files '' '/tmp/test-removal-1' '/tmp/test-removal-2' '/tmp/test-removal-3'
    assert_false [ -e '/tmp/test-removal-1' ]
    assert_false [ -e '/tmp/test-removal-2' ]
    assert_false [ -e '/tmp/test-removal-3' ]
}

test_delete_files_nonexistent() {
    delete_files '' '/tmp/test-removal-nonexistent-1' '/tmp/test-removal-nonexistent-2' '/tmp/test-removal-nonexistent-3'
    assert_equal 0 $?
}

test_delete_directory() {
    mkdir /tmp/test-removal-dir-1
    delete_directory '' '/tmp/test-removal-dir-1'
}

test_delete_directory_nonexistent() {
    delete_directory '' '/tmp/test-removal-dir-nonexistent-1'
}

# TODO: Figure out what to do with these
# IMPORTANT: the apt tests are (for now) suppressed:
#   This is because they install an actual (albeit simple and tiny) package.
#   In the case of apt_purge() there is a Y/N prompt (because of issue #19).
#   Use them at your own risk.

__test_apt_remove() {
    sudo apt install -y rolldice
    apt_remove rolldice
}

__test_apt_remove_no_install() {
    apt_remove rolldice
}

__test_apt_purge() {
    sudo apt install -y rolldice
    apt_purge rolldice
}

__test_apt_purge_no_install() {
    apt_purge rolldice
}
