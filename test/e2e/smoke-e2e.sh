#! /bin/sh

# TODO:
# Make sure ~/.local/share/applications exists.

ESC=$(printf "\033")
COFF="${ESC}[0m"
CRED="${ESC}[91m"
CGRN="${ESC}[92m"
CYEL="${ESC}[93m"
CBLU="${ESC}[94m"

ok=0
nok=0

failed=''
mod_global='doit'

testrun() {
    if [ "$mod_global" = doit ]; then mod=''; else mod="$mod_global "; fi
    mod="$([ "$mod_global" = doit ] && printf '' || printf '%s ' $mod_global)"
    verb=$1
    recipe=$2

    tmpl='\n\n----- %s %s ------------------------------------------------\n\n'
    # shellcheck disable=2059
    printf "$tmpl" "$verb" "$recipe"

    # shellcheck disable=2086
    if mash ${mod}${verb} $recipe; then
        ok=$(expr $ok + 1)
    else
        nok=$(expr $nok + 1)
        failed="$failed $recipe"
        printf "\n\n%sFAILED RECIPE: %s !!  FAILED RECIPE: %s !!%s\n\n" \
            "$CRED" "$recipe" "$recipe" "$COFF"
    fi
}

full_test() {
    standard_test
    testrun install dev-essentials
    testrun install docker
    #testrun install firefox
    #testrun install pycharm-pro
}

standard_test() {
    testrun install bitwarden
#    testrun install wire

    #testrun install dev-essentials
    testrun install docker-compose
    #testrun install docker

    #testrun install firefox

    testrun install github-cli
    testrun install pipx-local
    testrun install pycharm-community

    #testrun install pycharm-pro

    testrun install shell-check
    testrun install shfmt
    testrun install vscodium
    testrun setup python-dev
    testrun setup fail
}

quick_test() {
    testrun install shell-check
    testrun install shfmt
}

recap() {
    total=$(expr "$ok" + "$nok")

    if [ "$nok" -gt 0 ]; then COL=$CRED; else COL=$CGRN; fi

    printf "\n\n\nE2E TEST RESULTS: **************************\n"
    echo "TOTAL: $total,  Passed: $ok,  ${COL}FAILED: ${nok}${COFF}"
    [ "$nok" -gt 0 ] && echo "Failed recipes: ${COL}${failed}${COFF}"
}

main() {
    # target_func should be one of `quick`, `average` or `full`
    target="${1:-quick}"
    target_func="${target}_test"
    printf '%s: invoked with target suite "%s"\n\n' "$(basename "$0")" "$target"

    mod_global=doit
    ${target_func}

    mod_global=doit
    ${target_func}

    mod_global=undo
    $target_func

    mod_global=doit
    ${target_func}

    mod_global=undo
    $target_func

    recap
}

main "$@"
echo "nok=$nok"
exit "$nok"
