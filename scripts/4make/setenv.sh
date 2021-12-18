#! /bin/sh

NEW_MASH_HOME="$(pwd)/src"

cat << EOS
export MASH_HOME=$NEW_MASH_HOME ; \
  export PATH="$NEW_MASH_HOME/bin:\$PATH" ; \
  export POSIXSH_IMPORT_PATH="$NEW_MASH_HOME/lib:$NEW_MASH_HOME/etc:$POSIXSH_IMPORT_PATH"; \
  echo "MASH_HOME=\$MASH_HOME" ; \
  echo "PATH=\$PATH"
EOS

# export MASH_IMPORT_PATH="$NEW_MASH_HOME/lib:$NEW_MASH_HOME/etc:$NEW_MASH_HOME/../chroot-setup/scripts" ; \
