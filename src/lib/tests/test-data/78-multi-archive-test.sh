# /tmp/mash-tests/.bashrc.d/78-multi-archive-test.sh - mash: add multi-archive bin to PATH

_RECIPE_HOME='/tmp/mash-tests/multi-archive/current/test-subdirectory-2'
echo $PATH | grep -q "$_RECIPE_HOME" || PATH="$_RECIPE_HOME:$PATH"

