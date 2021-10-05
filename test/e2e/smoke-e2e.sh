#! /bin/sh

# TODO:
# Copy this into the chroot when bringing it up
# Make sure the mash user is sudoer no-pass.
# Make sure ~/.local/share/applications exists.

ESC=$(printf "\033")
COFF="${ESC}[0m"
CRED="${ESC}[91m"
CGRN="${ESC}[92m"
CYEL="${ESC}[93m"
CBLU="${ESC}[94m"

ok=0
nok=0

alias capture_result=' ok=`expr $ok + 1` || nok=`expr $nok + 1`'

failed=''

testrun() {
  mash=$1
  modif=''
  if [ "$2" = undo ]; then modif='undo '; shift; fi
  verb=$2
  recipe=$3

  printf "\n\n-----------------------------------------------------\n\n"

  # shellcheck disable=2086
  if $mash ${modif}${verb} $recipe; then
    ok=$(expr $ok + 1)
  else
    nok=$(expr $nok + 1)
    failed="$failed $recipe"
    printf "\n\n%sFAILED RECIPE: %s !!  FAILED RECIPE: %s !!%s\n\n" "$CRED" "$recipe" "$recipe" "$COFF"
  fi
}


testrun mash install bitwarden
testrun mash install wire

#testrun mash install dev-essentials
testrun mash install docker-compose
#testrun mash install docker

#testrun mash install firefox

testrun mash install github-cli
testrun mash install pipx-local
testrun mash install pycharm-community

#testrun mash install pycharm-pro

testrun mash install shell-check
testrun mash install shfmt
testrun mash install vscodium
testrun mash setup python-dev


#true && capture_result
#true && capture_result
#true && capture_result
#true && capture_result

total=$(expr $ok + $nok)

if [ "$nok" -gt 0 ]; then COL=$CRED; else COL=$CGRN; fi

printf "\n\n\nE2E TEST RESULTS: **************************\n"
echo "TOTAL: $total,  Passed: $ok,  ${COL}FAILED: ${nok}${COFF}"
[ $nok -gt 0 ] && echo "Failed recipes: ${COL}${failed}${COFF}"

unalias capture_result
