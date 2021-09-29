#! /bin/sh

DEBUG=true

_ARCH="$(uname -m)"
_KERNEL="$(uname -s)"
# defined in etc/mashrc  # TODO: remove
#_LOCAL="$HOME/.local"

_URL_LATEST='https://github.com/bitwarden/desktop/releases/latest'
_URL_DOWNLOAD_RE='^location: https://github.com/docker/compose/releases/tag/v\(.*\)$'
#_VERSION="$(curl -Is $_URL_LATEST | grep '^location' | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")"
_VERSION='1.29.2'

# TODO: Versions 2.x follow different URL/ARCH naming convention and need different handling

_BIN_LOC="${_LOCAL}/bin/docker-compose"
_FILE_URL="https://github.com/docker/compose/releases/download/${_VERSION}/docker-compose-${_KERNEL}-${_ARCH}"

log debug "_VERSION=$_VERSION"
log debug "_FILE_URL=$_FILE_URL"

doit() {
    curl -sL "${_FILE_URL}" -o "${_BIN_LOC}"
    chmod +x "${_BIN_LOC}"
    docker-compose --version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log info 'docker-compose installation successful.'
        docker-compose --version
    else
        log error 'docker-compose installation FAILED.'
    fi
}

undo() {
    log warn "Undo NOT supported (yet) for '$verb $recipe'"
}

$mash_action
