#!/bin/sh

import unittest/assert

test_is_num__true() {
    is_num 345 || print_fail "345 not accepted as integer"
    is_num 34 || print_fail "34 not accepted as integer"
    is_num 3 || print_fail "3 not accepted as integer"
    is_num 0 || print_fail "0 not accepted as integer"
    is_num -0 || print_fail "-0 not accepted as integer"
    is_num -345 || print_fail "-345 not accepted as integer"
    is_num +345 || print_fail "+345 not accepted as integer"
}

test_is_num__false() {
    is_num '34a' && print_fail "34a accepted as integer"
    is_num '34.5' && print_fail "34.5 accepted as integer"
    is_num '' && print_fail "empty string accepted as integer"
}

test_assert_equal__positive() {
    assert_equal tata tata
    assert_equal 123 123
    assert_equal '' ''
    assert_equal 'tata 123' 'tata 123'
}

test_assert_equal__negative() {
    assert_equal tata toto 1> /dev/null && print_fail 'assert_equal tata toto DID NOT fail'
    assert_equal '' toto 1> /dev/null && print_fail 'assert_equal '' toto DID NOT fail'
    assert_equal tata '' 1> /dev/null && print_fail 'assert_equal tata '' DID NOT fail'
    assert_equal ' ' '' 1> /dev/null && print_fail 'assert_equal ' ' '' DID NOT fail'
}

test_assert_not_equal__positive() {
    assert_not_equal tata toto
    assert_not_equal '' toto
    assert_not_equal tata ''
    assert_not_equal ' ' ''
}

test_assert_not_equal__negative() {
    assert_not_equal tata tata 1> /dev/null && print_fail 'assert_not_equal tata toto DID NOT fail'
    assert_not_equal 123 123 1> /dev/null && print_fail 'assert_not_equal 123 123 DID NOT fail'
    assert_not_equal '' '' 1> /dev/null && print_fail 'assert_not_equal '' '' DID NOT fail'
}

test_assert_equal_num__positive() {
    assert_equal_num 123 123
    assert_equal_num 123 0123
    assert_equal_num -000123 -0123
    assert_equal_num 0 0
    assert_equal_num -0 +0
    assert_equal_num '123' '123'
    assert_equal_num 123 '123'
    assert_equal_num '123' 123
    assert_equal_num '123 ' ' 123'
}

test_assert_equal_num__negative() {
    # 2> /dev/null
    assert_equal_num 123 124 1> /dev/null && print_fail 'assert_equal_num 123 124 DID NOT fail'
    assert_equal_num -1 1 1> /dev/null && print_fail 'assert_equal_num -1 1 DID NOT fail'
    assert_equal_num 2 2a 1> /dev/null && print_fail 'assert_equal_num 2 2a DID NOT fail'
}

test_assert_not_equal_num__positive() {
    assert_not_equal_num 123 124
    assert_not_equal_num 1 -1
    assert_not_equal_num 1 -1a
}

test_assert_not_equal_num__negative() {
    assert_not_equal_num 123 123 1> /dev/null && print_fail 'assert_not_equal_num 123 123 DID NOT fail'
    assert_not_equal_num 0234 00234 1> /dev/null && print_fail 'assert_not_equal_num 0234 00234 DID NOT fail'
    assert_not_equal_num '  234 ' 0000234 1> /dev/null && print_fail 'assert_not_equal_num ' 234 ' 0000234 DID NOT fail'
}

test_assert_true__positive() {
    assert_true true
    assert_true [ 1 -eq 1 ]
    assert_true [ abc = abc ]
}

test_assert_true__negative() {
    assert_true false 1> /dev/null && print_fail 'assert_true false DID NOT fail'
    assert_true [ 1 -eq 0 ] 1> /dev/null && print_fail 'assert_true [ 1 -eq 0 ] DID NOT fail'
    assert_true [ abc = cba ] 1> /dev/null && print_fail 'assert_true [ abc = cba ] DID NOT fail'
}

test_assert_true__special_case() {
    accepts_complex_string() {
        # echo "accepts_complex_string: arg1=[$1], arg2=[$2]"
        [ "$1" = 'abc def' ]
    }
    assert_true accepts_complex_string 'abc def'
}

test_assert_false__positive() {
    assert_false false
    assert_false [ 1 -eq 2 ]
    assert_false [ abc = asd ]
}

test_assert_false__negative() {
    assert_false true 1> /dev/null && print_fail 'assert_false true DID NOT fail'
    assert_false [ 3 -eq 3 ] 1> /dev/null && print_fail 'assert_false [ 3 -eq 3 ] DID NOT fail'
    assert_false [ asd = asd ] 1> /dev/null && print_fail 'assert_false [ asd = asd ] DID NOT fail'
}

test_assert_false__special_case() {
    accepts_complex_string() {
        assert_equal "$1" 'abc def'
        return 1
    }
    assert_false accepts_complex_string 'abc def'
}

test_assert_rc_equal__positive() {
    assert_rc_equal 1 true
    assert_rc_equal 0 false
    assert_rc_equal 5 return 5
    assert_rc_equal 127 return 127
}
test_assert_rc_equal__negative() {
    assert_rc_equal 1 false 1> /dev/null && print_fail 'assert_rc_equal 1 false DID NOT fail'
    assert_rc_equal 0 true 1> /dev/null && print_fail 'assert_rc_equal 0 true DID NOT fail'
    assert_rc_equal 5 return 6 1> /dev/null && print_fail 'assert_rc_equal 5 return 6 DID NOT fail'
    assert_rc_equal 127 return 126 1> /dev/null && print_fail 'assert_rc_equal 127 return 126 DID NOT fail'
    assert_rc_equal abs return 0 && print_fail 'assert_rc_equal abs return 0 DID NOT fail'
}

test_assert_rc_equal__special_case() {
    accepts_complex_string() {
        [ "$1" = 'abc def' ]
    }
    assert_rc_equal 0 accepts_complex_string 'abc def'
}

# # shellcheck disable=2003,2086
# test() {
#     set +x
#     local no=0

#     test_is_num__true
#     test_is_num__false
#     test_assert_equal__positive
#     test_assert_equal__negative
#     test_assert_not_equal__positive
#     test_assert_not_equal__negative
#     test_assert_equal_num__positive
#     test_assert_equal_num__negative
#     test_assert_not_equal_num__positive
#     test_assert_not_equal_num__negative
#     test_assert_true__positive
#     test_assert_true__negative
#     test_assert_true__special_case
#     test_assert_false__positive
#     test_assert_false__negative
#     test_assert_false__special_case
#     test_assert_rc_equal__positive
#     test_assert_rc_equal__negative
#     test_assert_rc_equal__special_case
# }

# if [ "$_name_" = "$_l4t_name_" ]; then
#     if [ "$1" = test ]; then
#         test
#     else
#         echo "$_l4t_name_ is a library - not callable directly."
#         echo "If you want to run the tests -- use 'test' argument."
#         exit 1
#     fi
# fi
