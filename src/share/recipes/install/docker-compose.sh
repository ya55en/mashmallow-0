#! /bin/sh

_ARCH="$(uname -m)"
_KERNEL="$(uname -s)"

_URL_LATEST='https://github.com/docker/compose/releases/latest'
_URL_DOWNLOAD_RE='^location: https://github.com/docker/compose/releases/tag/v\(.*\)$'
#_VERSION="$(curl -Is $_URL_LATEST | grep '^location' | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")"
_VERSION='1.29.2'

# TODO: Versions 2.x follow different URL/ARCH naming convention and need different handling

_BIN_LOC="${_LOCAL}/bin/docker-compose"
_FILE_URL="https://github.com/docker/compose/releases/download/${_VERSION}/docker-compose-${_KERNEL}-${_ARCH}"
_file_name="docker-compose-${_KERNEL}-${_ARCH}"
_download_target="${_DOWNLOAD_CACHE}/${_file_name}"

log debug "_VERSION=$_VERSION"
log debug "_FILE_URL=$_FILE_URL"

download_into_cache() {
    #: Download into a cache folder.

    if [ -e "${_download_target}" ]; then
        log info "Already downloaded/cached, skipping."
    else
        mkdir -p "${_DOWNLOAD_CACHE}"
        log info "Downloading decker-compose v${_VERSION} ..."
        curl -sL "${_FILE_URL}" -o "${_download_target}" ||
            die 25 "docker-compose download FAILED! (rc=$?)"
    fi
}

copy_into_bin_loc() {
    #: Copy from $HOME/.cache/mash/downloads to $HOME/.local/bin .

    if [ -e "${_BIN_LOC}/${_file_name}" ]; then
        log warn "Already in $HOME/.local/bin, skipping."
    else
        log info "Copying ${_file_name} to ${_BIN_LOC} ..."
        cp "${_download_target}" "${_BIN_LOC}"
        chmod +x "${_BIN_LOC}"
    fi
}

smoke_test() {
    #: Run a smoke test.

    log info "Running a smoke test ..."
    docker-compose --version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log info 'docker-compose installation successful.'
        docker-compose --version
    else
        log error 'docker-compose installation FAILED.'
    fi

}

inform_user() {
    cat << EOS

Completed. You can use docker-compose instantly, like:

  $ docker-compose --help

Enjoy! ;)

EOS

}

doit() {
  download_into_cache
  copy_into_bin_loc
  smoke_test
  inform_user
}

undo() {
    log warn "Removing docker-compose ..."

    log info "Removing binary from ${_BIN_LOC}"
    rm "${_BIN_LOC}" || die 65 "Could not remove ${_BIN_LOC}/${_file_name} !"
    log info "docker-compose removed successfully."
}

$mash_action
