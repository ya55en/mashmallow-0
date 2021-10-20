#! /bin/sh

import logging
# Assumming lib/libma.sh has been sourced already.

link_path="$_LOCAL/bin/python"

set_python_as_link() {
    #: Make binary python available as a link to python3:

    skip_msg="'python' executable found, skip linking."
    python -V > /dev/null 2>&1 && {
        _info "$skip_msg"
        return 0
    }

    _info "Setting up python link..."
    into_dir_do "$_LOCAL/bin" 'ln -s "$(which python3)" python'
    # TODO: depending on 'which' - not ideal, think on replacement
    _info "Created symlink 'python' to $(which python3)"
}

smoke_test_python_link() {
    python -V > /dev/null 2>&1 || die "Creating python as link to python3 FAILED."
    _info "Smoke test OK. (python -V)"
}

_apt_packages='python3-venv python3-dev'

install_dev_essentials() {
    # Be careful on undo install because of issue #19
    _info "Installing dev-essentials..."
    mash install dev-essentials
}

install_apt_packages() {
    _info "Installing apt packages..."
    sudo apt-get install -y ${_apt_packages}
}

# mash install pip-bootstrap (?)

install_pipx_local() {
    _info "Installing pipx-local..."
    mash install pipx-local
}

doit() {
    _info "Setting up python-dev:"
    set_python_as_link
    smoke_test_python_link
    install_dev_essentials
    install_apt_packages
    install_pipx_local
    _info "python-dev recipe setup successfully."
}

undo() {
    if ! [ -e "${link_path}" ]; then
        _warn "Link '~/.local/bin/python' python3 not there, skipping."
    else
        _info "Removing '~/.local/bin/python' link to python3..."
        rm "${link_path}"
        [ -e "${link_path}" ] && die 14 "Removing ${link_path} FAILED!"
    fi

    _info "NOT Removing dev-essentials (see #19)."
    # mash undo install dev-essentials

    _info "Purging apt packages..."
    sudo apt-get purge ${_apt_packages}

    _info "Removing pipx-local..."
    mash undo install pipx-local

    _info "python-dev removed successfully."
}

$mash_action
