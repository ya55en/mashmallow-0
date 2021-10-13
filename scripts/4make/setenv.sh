#! /bin/sh

NEW_MASH_HOME="$(pwd)/src"

cat << EOS
export MASH_HOME=$NEW_MASH_HOME ; \
  export PATH="$NEW_MASH_HOME/bin:\$PATH" ; \
  export MASH_IMPORT_PATH="$NEW_MASH_HOME/lib:$NEW_MASH_HOME/etc:$NEW_MASH_HOME/../chroot-setup/scripts" ; \
  echo "MASH_HOME=\$MASH_HOME" ; \
  echo "PATH=\$PATH"
EOS
