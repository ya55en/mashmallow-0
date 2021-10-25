#! /bin/sh

import unittest/assert
import string

test_rstrip() {
    assert_equal 'A' "$(rstrip 'A  ')"
    assert_equal 'Word' "$(rstrip 'Word==' '=')"
    assert_equal 'Word' "$(rstrip 'Word==' '==')"
    assert_equal 'Word=' "$(rstrip 'Word===' '==')"
    assert_equal 'asd' "$(rstrip 'asd')"
    assert_equal 'asd' "$(rstrip 'asd' '+')"
    assert_equal 'A B C' "$(rstrip 'A B C  ')"
    assert_equal 'A+B+C' "$(rstrip 'A+B+C+' '+')"
}

test_rstrip__corner_cases() {
    assert_equal '' "$(rstrip '   ')"
    assert_equal '   ' "$(rstrip '   ' '')"
    assert_equal ' ' "$(rstrip ' aaa' 'a')"
}

test_lstrip() {
    assert_equal 'A' "$(lstrip '   A')"
    assert_equal 'Word' "$(lstrip '==Word' '=')"
    assert_equal 'Word' "$(lstrip '==Word' '==')"
    assert_equal '=Word' "$(lstrip '===Word' '==')"
    assert_equal 'asd' "$(lstrip 'asd')"
    assert_equal 'asd' "$(lstrip 'asd' '+')"
    assert_equal 'A B C' "$(lstrip '  A B C')"
    assert_equal 'A+B+C' "$(lstrip '+A+B+C' '+')"
}

test_lstrip__corner_cases() {
    assert_equal '   ' "$(lstrip '   ' '')"
    assert_equal '' "$(lstrip '   ')"
    assert_equal ' ' "$(lstrip 'aaa ' 'a')"
}

test_strip() {
    assert_equal 'A' "$(strip '  A  ')"
    assert_equal 'Word' "$(strip '==Word=' '=')"
    assert_equal 'Word' "$(strip '==Word==' '==')"
    assert_equal '=Word=' "$(strip '===Word=====' '==')"
    assert_equal 'asd' "$(strip 'asd')"
    assert_equal 'asd' "$(strip 'asd' '+')"
    assert_equal 'A B C' "$(strip '  A B C  ')"
    assert_equal 'A+B+C' "$(strip '+A+B+C+' '+')"
}

test_strip__corner_cases() {
    assert_equal '   ' "$(strip '   ' '')"
    assert_equal '' "$(strip '   ')"
    assert_equal ' ' "$(strip 'aa aaa' 'a')"
}

test_reeval__no_spaces() {
    local SOME_VAR='SOME-VAR-VALUE'
    # shellcheck disable=2016
    local some_line='Some+line+with+$SOME_VAR+here.'

    expected='Some+line+with+SOME-VAR-VALUE+here.'
    assert_equal "$expected" "$(reeval "$some_line")"
}

# shellcheck disable=2034,2016
test_reeval__with_spaces() {
    local SOME_VAR='SOME-VAR-VALUE'
    local some_line='"Some line with $SOME_VAR here."'

    expected='Some line with SOME-VAR-VALUE here.'
    assert_equal "$expected" "$(reeval "$some_line")"
}

test_len__empty_string() {
    assert_equal 0 "$(len '')"
}

test_len__non_empty_string() {
    assert_equal 1 "$(len ' ')"
    assert_equal 2 "$(len '  ')"
    assert_equal 3 "$(len 'abc')"
    assert_equal 6 "$(len '123456')"
}
