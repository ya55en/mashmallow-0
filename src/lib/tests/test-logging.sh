#!/bin/sh

# TODO: for automatic checks, run this against predefined
#   setup, store the output to a file and compare it to
#   a file with pre-recorded expected output.

#: Test the logging lib. Except for the `test_logging_unknown_level`
#: test case, the rest of the functionality is tested via a call to
#: the logging aliases (`_info`, `_warn`, etc.) and "recording" the
#: output into a file. Make sure the latest changes are reflected into
#: this file:  `src/lib/tests/logging-sample.output`.
#: To update it:
#:   (a) suppress the temp file deletion in `teardown_mod()`;
#:   (b) run this test suite -- it will (re)create the temp file;
#:   (c) examine the contents of `$__LOGGING__TMP_FILE`;
#:   (d) copy the `$__LOGGING__TMP_FILE` into `$__LOGGING__SAMPLE_FILE`, e.g.:
#:       $ cp -p /tmp/logging-test.output src/lib/tests/test-data/logging-sample.output
#:   (e) restore the temp file deletion in `teardown_mod()`.

import unittest/assert
import logging

__LOGGING__SAMPLE_FILE='src/lib/tests/test-data/logging-sample.output'
__LOGGING__TMP_FILE='/tmp/logging-test.output'

show_aliases() {
    echo "--- Running show_aliases()..."
    alias
}

logging_level_error() {
    local _FUNCNAME=test-logging#logging_level_error
    echo "--- Running $_FUNCNAME()..."
    logging__set_level ERROR

    _fatal "This is a FATAL level message ;)"
    _error "This is an ERROR level message ;)"
    _warn "This is a WARN level message ;)"
    _info "This is an INFO level message: NOT supposed to show up!"
    _say "This is a SAY message that appears only on console."
    _debug "This is a DEBUG level message: NOT supposed to show up!"
}

logging_all_levels() {
    echo "--- Running logging_all_levels()..."
    logging__set_level DEBUG

    _fatal "This is a FATAL level message ;)"
    _error "This is an ERROR level message ;)"
    _warn "This is a WARN level message ;)"
    _info "This is an INFO level message ;)"
    _say "This is a SAY message that appears only on console."
    _debug "This is a DEBUG level message ;)"
}

#: Create a tmp file with logging output coming from
#: standard calls in `logging_all_levels()`, `logging_level_error()`
#: and `show_aliases()` to be compared to a pre-recorded expected
#: output file content.
setup_mod() {
    local _LOG_FORMAT_TIME_CONSOLE_OLD="$_LOG_FORMAT_TIME_CONSOLE"
    _LOG_FORMAT_TIME_CONSOLE=

    {
        logging_all_levels
        logging_level_error
    } > "$__LOGGING__TMP_FILE"

    # Dump on console to show how it works:
    # {
    #     logging_all_levels
    #     logging_level_error
    # }

    _LOG_FORMAT_TIME_CONSOLE="$_LOG_FORMAT_TIME_CONSOLE_OLD"
}

#: Remove the tmp file created by `setup_mod()`.
teardown_mod() {
    # Suppress to keep the $__LOGGING__TMP_FILE for copying to the reference
    # file $__LOGGING__SAMPLE_FILE. (Use a noop like ':' or 'true'.)
    rm -f "$__LOGGING__TMP_FILE"
    # :
}

test_logging_unknown_level() {
    (logging__set_level FOOBAR > /dev/null 2>&1)
    assert_equal 44 $?
}

test_compare_output_with_expected() {
    assert_true diff -u "$__LOGGING__SAMPLE_FILE" "$__LOGGING__TMP_FILE"
}
