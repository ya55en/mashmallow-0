#! /bin/sh

# set -x

# Assumming lib/libma.sh has been sourced already.

DEBUG=true
_ARCH=x86_64
_LOCAL="$HOME/.local"

version='3.26.2941'

log debug "version=[$version]"

_URL_DOWNLOAD="https://wire-app.wire.com/linux/Wire-${version}_${_ARCH}.AppImage"

log debug "_URL_DOWNLOAD=[$_URL_DOWNLOAD]"


# Download and install:
log info "Downloading Wire desktop v${version}..."
mkdir -p "$_LOCAL/opt/wire"
curl -sL "$_URL_DOWNLOAD" -o $_LOCAL/opt/wire/Wire-${version}-${_ARCH}.AppImage__OFF


# TODO: check sha512

mv -f $_LOCAL/opt/wire/Wire-${version}-${_ARCH}.AppImage__OFF $_LOCAL/opt/wire/Wire-${version}-${_ARCH}.AppImage
chmod +x $_LOCAL/opt/wire/Wire-${version}-${_ARCH}.AppImage
ln -fs $_LOCAL/opt/wire/Wire-${version}-${_ARCH}.AppImage $_LOCAL/bin/wire-desktop

cat <<EOS

In order to have all your terminals know about the add-to-path change,
you need to:
  - EITHER source the add-top-path script (see below) in all open terminals,
  - OR log out, then log back in.

To source the add-to-path script, do (note the dot in front):

 $ . "~/.bashrc.d/42-pycharm-${flavor}.sh"

 Pycharm should be accessible now from anywhere on the command line,
 with:

  $ pycharm.sh

EOS
log info 'Done! ;)'
