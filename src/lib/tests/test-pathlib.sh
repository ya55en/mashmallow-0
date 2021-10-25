#! /bin/sh

import unittest/assert
import pathlib

test_relpath_from_dir() {
    assert_equal 'three/four/five' "$(relpath_from_dir '/one/two/three/four/five' 'three')"
    assert_equal 'one/two/three/four/five' "$(relpath_from_dir '/one/two/three/four/five' 'one')"
    assert_equal 'five' "$(relpath_from_dir '/one/two/three/four/five' 'five')"
}

test_relpath_from_dir__corner_case_empty_dir() {
    (relpath_from_dir '/one/two/three/four/five' '' 2> /dev/null) &&
        print_fail 'relpath_from_dir did NOT fail for empty dir'
}

test_relpath_from_dir__corner_cases_empty_path() {
    (relpath_from_dir '' 'asd' 2> /dev/null) &&
        print_fail 'relpath_from_dir did NOT fail for empty path'
}

test_relpath_from_dir__corner_cases_space_only_dir() {
    (relpath_from_dir '/one/two/three/four/five' '  ' 2> /dev/null) &&
        print_fail 'relpath_from_dir did NOT fail for space only dir'
}

test_relpath_from_dir__corner_cases_space_only_path() {
    (relpath_from_dir '   ' 'asd' 2> /dev/null) &&
        print_fail 'relpath_from_dir did NOT fail for space only path'
}
