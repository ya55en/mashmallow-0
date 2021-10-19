#!/bin/sh

#: Test modules runner
#: Parse a test module collecting `test_*` methods, also `setup_mod`,
#: `teardown_mod`, `setup` and `teardown`. Source the module and
#: execute all collected methods in proper order.

. "$MASH_HOME/lib/sys.sh"

_name_="$(basename "$0")"
_rnr_name_='runner.sh'

# shellcheck disable=2120
print_pass() {
    passmsg="${1:-passed}"
    printf 'ok %u - %s: %s\n' $no $_curr_test_ "$passmsg"
}

parse_module() {
    filename="$1"

    while IFS='' read -r line; do
        # TODO: use 'import string' when ready, for stripping lines

        case $line in
            test_*\(*\)*\{)
                # printf 'TEST METHOD: %s\n' "${line%(*}"
                test_methods="$test_methods ${line%(*}"
                ;;

            setup_mod\(*\)*\{)
                # printf 'SETUP MOD METHOD: %s\n' "${line%(*}"
                setup_mod_name="${line%(*}"
                ;;

            teardown_mod\(*\)*\{)
                # printf 'TEARDOWN MOD METHOD: %s\n' "${line%(*}"
                teardown_mod_name="${line%(*}"
                ;;

            setup\(*\)*\{)
                # printf 'SETUP METHOD: %s\n' "${line%(*}"
                setup_name="${line%(*}"
                ;;

            teardown\(*\)*\{)
                # printf 'TEARDOWN METHOD: %s\n' "${line%(*}"
                teardown_name="${line%(*}"
                ;;

        esac

    done < "$filename"
}

run() {

    local setup_mod_name=
    local teardown_mod_name=
    local setup_name=
    local teardown_name=
    local test_methods=

    local _curr_test_=
    local _curr_test_rc_=0

    parse_module "$1"

    . "$1"

    [ -n "$setup_mod_name" ] && $setup_mod_name

    local IFS_OLD="$IFS"
    IFS=' '

    for method in $test_methods; do
        [ -n "$setup_name" ] && $setup_name

        _curr_test_=$method
        _curr_test_rc_=0
        no=$(expr $no + 1)
        $method
        [ "$_curr_test_rc_" -eq 0 ] && print_pass

        [ -n "$teardown_name" ] && $teardown_name
    done
    IFS="$IFS_OLD"

    [ -n "$teardown_mod_name" ] && $teardown_mod_name
}

run_many() {
    local no=0
    local IFS_OLD="$IFS"
    IFS=':'

    while [ -n "$test_modules" ]; do

        read -r mod_path test_modules << EOS
$test_modules
EOS

        [ -n "$mod_path" ] && {
            echo "RUN [$mod_path]"
            run "$mod_path"
        }
    done
    IFS="$IFS_OLD"
}

collect() {

    collect_if_name_matches() {
        filename="$1"
        [ -e "$filename" ] || die 33 "Path NOT found: $filename"

        case "$(basename "$filename")" in
            test-*.sh | test_*.sh)
                test_modules="$test_modules:$filename"
                ;;
        esac
    }

    scan_direcroty() {
        path="$1"
        printf '(2) scan_direcroty %s\n' "$path"
        for entry in $path/*; do
            if [ -d "$entry" ]; then
                scan_direcroty "$entry"
            else
                collect_if_name_matches "$entry"
            fi
        done
    }

    for path in "$@"; do

        printf '(1) path=%s\n' "$path"
        if [ -d "$path" ]; then
            scan_direcroty "$path"
        else
            collect_if_name_matches "$path"
        fi
    done
    printf 'COLLECTED: %s\n' "$test_modules"
    # exit 0
}

main() {
    local test_modules

    case "$1" in
        --help | -help | help | -h)
            cat << EOS
Unit test runner v 0.0.0 ;)
USAGE:
  $ $(basename "$0") PATH-to-TEST-ENTRY [PATH-to-TEST-ENTRY ...]

EOS
            exit 0
            ;;
    esac

    collect "$@"
    run_many
}

if [ "$_name_" = "$_rnr_name_" ]; then
    main "$@"
fi
