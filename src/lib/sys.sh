#!/bin/sh

# An 'import' "statement" - a function of a single argument which
# is the name of a 'module' - the filename w/o '.sh' extension of
# a shell library. That shell library is looked up in all paths
# listed in MASH_IMPORT_PATH and sourced if found, othewise
# 'import' exits with a message and rc=5.

# TODO: remove the smoke tests form here and provide tests in a separate module.
# TODO: clarify who defines MASH_IMPORT_PATH and remove it from here.

# By default, MASH_IMPORT_PATH contains ${MASH_HOME}/{etc,lib}
#MASH_IMPORT_PATH="$HOME/.local/opt/mash/etc:$HOME/.local/opt/mash/lib" # eq. to "$MASH_HOME/lib"

# for tests:
#MASH_IMPORT_PATH="/a:/b:/c:$HOME/Work/mashmallow-0/scripts/import-stuff:/etc"
#MASH_IMPORT_PATH="$HOME/.local/lib:$HOME/Work/mashmallow-0/scripts/import-stuff:/lib"

_sys_name_='sys.sh'
_name_="$(basename "$0")"

_SYS__MODEXT='.sh'

#: Terminate execution with given rc and message.
die() {
    rc=$1
    msg="$2"

    echo "FATAL: $msg" >&2
    exit $rc
}

#: Return true if given `$str` contains a colon, false (rc=1) otherwise.
_sys__contains_colon() {
  local str="$1"

  case "$str" in
  *:*)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

#: Check if $mod_name (defined in `import()`) or $mod_name${MODEXT}
#: exists in given `$path` and if so -- source it and return true,
#: otherwise return false (rc=1).
_sys__process_path() {
  local path="$1"
  local full_path="${path}/${mod_name}"
  local full_path_ext="${path}/${mod_name}${_SYS__MODEXT}"

  # printf 'full_path=[%s]\n' "$full_path"
  if [ -e "$full_path_ext" ]; then
    . "$full_path_ext" || exit 6  # TODO: add die() and use it here
    printf '%s SOURCED.\n' "${mod_name}"
    return 0

  elif [ -e "$full_path" ]; then
    . "$full_path" || exit 6  # TODO: and here
    printf '%s SOURCED.\n' "${mod_name}"
    return 0

  else
    # printf 'hey, %s not found here.\n' "${mod_filename}"
    return 1
  fi
}

#: Look up module `$mod_filename` (defined in `import()`) in all paths
#: of given colon-delimited `$path_list`. If found -- source that module
#: and return true, otherwise return false (rc=1).
_sys__find_module_in_paths() {
  local path_list="$1"
  local IFS_OLD
  local rc=1 # not found (until proven otherwise)

  IFS_OLD="$IFS"
  IFS=':'

  while _sys__contains_colon "$path_list"; do
    read -r path path_list <<EOF
$path_list
EOF
    _sys__process_path "$path" && {
      rc=0 # found!
      break
    }
  done

  [ -n "$path_list" ] && _sys__process_path "$path_list" && rc=0 # found!

  IFS="$IFS_OLD"
  return $rc
}

#: Looks up for a shell module in MASH_IMPORT_PATH and sources it, if found,
#: otherwise prints an error message and exits rc=5. (See the sys.sh header
#: comment for more details.)
import() {
  local mod_name="$1"
  # local mod_filename="${mod_name}${_SYS__MODEXT}"

  _sys__find_module_in_paths "$MASH_IMPORT_PATH" || {
    echo "FATAL: Module $mod_name NOT found in MASH_IMPORT_PATH" >&2
    echo "       MASH_IMPORT_PATH='$MASH_IMPORT_PATH'"           >&2
    exit 5
  }
}

test_e2e_case_1() {
  local path_list='ID:SOME text here: :with possible : INSIDE'
  printf 'path_list=[%s]\n' "$path_list"
  _sys__find_module_in_paths "$path_list"
  echo "DONE."
}

test_e2e_case_2() {
  import foorc
  import pathlib
  echo "FOO=${FOO} and _get_name_($0) returns [$(_get_name_ "$0")]."
}

test() {
  test_e2e_case_2
}

if [ "$_name_" = "$_sys_name_" ]; then
  if [ "$1" = test ]; then
    test
  else
    echo "$_sys_name_ is a library - not callable directly."
    echo "If you want to run the tests -- use 'test' argument."
    exit 1
  fi
fi
