#! /bin/sh

import unittest/assert
import install

#teardown_mod() {
#    rm -rf /tmp/mash-tests
#}

create_test_archive() {
    local path_to_dir="$1"
    local filename="$2"
    mkdir -p '/tmp/mash-tests/archives'
    tar cf "/tmp/mash-tests/archives/$filename" -C "$path_to_dir" .
}

test_install_single_file() {
    local test_environment=true
    local file_path="$MASH_HOME/lib/tests/test-data/test-install-single-file/test-file-1"
    local expected_md5=`md5sum $file_path | awk '{print $1}'`
    install_single "$file_path" 'single-file' '1.0'
    local actual_md5=`md5sum /tmp/mash-tests/single-file/current/single-file | awk '{print $1}'`
    assert_equal "$actual_md5" "$expected_md5"
    assert_true [ -L "/tmp/mash-tests/single-file/current" ]
    assert_true [ -L "/tmp/mash-tests/bin/single-file" ]
}

test_install_single_archive_case_1() {
    local test_environment=true
    local dir_path="$MASH_HOME/lib/tests/test-data/test-install-single-archive-1"
    local expected_md5_1=`md5sum $dir_path/test-subdirectory/test-file-1 | awk '{print $1}'`
    local expected_md5_2=`md5sum $dir_path/test-subdirectory/test-file-2 | awk '{print $1}'`
    create_test_archive "$dir_path" 'single-archive-1.tar'
    install_single '/tmp/mash-tests/archives/single-archive-1.tar' 'single-archive-1' '1.0' 'test-file-1'
    local actual_md5_1=`md5sum /tmp/mash-tests/single-archive-1/current/test-file-1 | awk '{print $1}'`
    local actual_md5_2=`md5sum /tmp/mash-tests/single-archive-1/current/test-file-2 | awk '{print $1}'`
    assert_equal "$actual_md5_1" "$expected_md5_1"
    assert_equal "$actual_md5_2" "$expected_md5_2"
    assert_true [ -L "/tmp/mash-tests/single-archive-1/current" ]
    assert_true [ -L "/tmp/mash-tests/bin/test-file-1" ]
}

test_install_single_archive_case_2() {
    local test_environment=true
    local dir_path="$MASH_HOME/lib/tests/test-data/test-install-single-archive-2"
    local expected_md5_1=`md5sum $dir_path/test-file-1 | awk '{print $1}'`
    local expected_md5_2=`md5sum $dir_path/test-file-2 | awk '{print $1}'`
    create_test_archive "$dir_path" 'single-archive-2.tar'
    install_single '/tmp/mash-tests/archives/single-archive-2.tar' 'single-archive-2' '1.0' 'test-file-2'
    local actual_md5_1=`md5sum /tmp/mash-tests/single-archive-2/current/test-file-1 | awk '{print $1}'`
    local actual_md5_2=`md5sum /tmp/mash-tests/single-archive-2/current/test-file-2 | awk '{print $1}'`
    assert_equal "$actual_md5_1" "$expected_md5_1"
    assert_equal "$actual_md5_2" "$expected_md5_2"
    assert_true [ -L "/tmp/mash-tests/single-archive-2/current" ]
    assert_true [ -L "/tmp/mash-tests/bin/test-file-2" ]
}

test_install_multi() {
    local test_environment=true
    local dir_path="$MASH_HOME/lib/tests/test-data/test-install-multi-archive"
    local expected_md5_1=`md5sum $dir_path/test-subdirectory/test-file-1 | awk '{print $1}'`
    local expected_md5_2=`md5sum $dir_path/test-subdirectory/test-file-2 | awk '{print $1}'`
    local expected_md5_3=`md5sum $dir_path/test-subdirectory/test-subdirectory-2/test-file-3 | awk '{print $1}'`
    create_test_archive "$dir_path" 'multi-archive.tar'
    install_multi '/tmp/mash-tests/archives/multi-archive.tar' 'multi-archive' '1.0'
    local actual_md5_1=`md5sum /tmp/mash-tests/multi-archive/current/test-file-1 | awk '{print $1}'`
    local actual_md5_2=`md5sum /tmp/mash-tests/multi-archive/current/test-file-2 | awk '{print $1}'`
    local actual_md5_3=`md5sum /tmp/mash-tests/multi-archive/current/test-subdirectory-2/test-file-3 | awk '{print $1}'`
    assert_equal "$actual_md5_1" "$expected_md5_1"
    assert_equal "$actual_md5_2" "$expected_md5_2"
    assert_equal "$actual_md5_3" "$expected_md5_3"
    assert_true [ -L "/tmp/mash-tests/multi-archive/current" ]
}

test_install_bashrcd_script() {
    local test_environment=true
    local expected_md5=`md5sum $MASH_HOME/lib/tests/test-data/78-multi-archive-test.sh | awk '{print $1}'`
    mkdir -p '/tmp/mash-tests/.bashrc.d'
    install_bashrcd_script 'multi-archive' '78-multi-archive-test.sh' '/tmp/mash-tests/multi-archive/current/test-subdirectory-2'
    local actual_md5=`md5sum /tmp/mash-tests/.bashrc.d/78-multi-archive-test.sh | awk '{print $1}'`
    assert_true [ -f '/tmp/mash-tests/.bashrc.d/78-multi-archive-test.sh' ]
    assert_equal "$actual_md5" "$expected_md5"
}
