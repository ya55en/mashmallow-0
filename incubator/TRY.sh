#! /bin/sh

# Testing framework, also see:
# - https://github.com/zandev/shunit2
# - http://manpages.ubuntu.com/manpages/trusty/man1/shunit2.1.html


set -e

. ./libma.sh

# str='abcd'
# echo "${str: -1}"

# echo -n $str | tail -c 2


str_tail() {  str="$1" count=$2
    echo -n "$str" | $tail_b -c $count
}


# fn assert(cond, msg, rc=9) {
#     if $cond; then:; else
#         log testfail
#     fi
# }


assert() {  cond="$1" msg="$2" rc=${3:-11}
    if [ $cond ] ; then : ; else
        log assertfail "$msg"
    fi
}


test_assert_pass() {
    assert '1 = 1'
}

test_assert_fail() {
    assert '1 = 0', 'expected failure'
}


test_str_tail() {
    assert 'str_tail abcd 1 = d'
}


main() {
    test_assert_pass
    test_assert_fail
}

main
