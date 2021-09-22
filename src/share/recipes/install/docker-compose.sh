#! /bin/sh

doit() {
    echo x"$(sudo whoami)"
    if [ x"$(sudo whoami)" != xroot ]; then
        die 15 'FATAL: Not sudo root, terminating'
    fi

    if [ x"$HOME" == xroot ]; then
        die 15 'FATAL: Root but not sudo root, terminating'
    fi

    if curl -V > /dev/null 2>&1; then :; else
        die 15 'FATAL: curl not found, terminating'
    fi

    # TODO: take the latest version automagically

    _ARCH=x86_64
    _LOCAL="$HOME/.local"
    _VERSION='1.27.4'
    _BIN_LOC="$HOME/.local/bin/docker-compose"
    _FILE_URL="https://github.com/docker/compose/releases/download/${_VERSION}/docker-compose-$(uname -s)-$(uname -m)"

    curl -L "${_FILE_URL}" -o "${_BIN_LOC}"
    chmod +x "${_BIN_LOC}"
    docker-compose --version && echo 'Done.' || die 12 'Docker-compose installation FAILED'
}

undo() {
    log warn "Undo NOT supported (yet) for '$verb $recipe'"
}

$mash_action
