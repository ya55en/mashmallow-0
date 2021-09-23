#! /bin/sh

NEW_MASH_HOME="$(pwd)/src"

cat << EOS
export MASH_HOME=$NEW_MASH_HOME ; \
  export PATH="$NEW_MASH_HOME/bin:\$PATH" ; \
  echo "MASH_HOME=\$MASH_HOME" ; \
  echo "PATH=\$PATH"
EOS
