#! /bin/sh

# Assumming lib/libma.sh has been sourced already.

link_path="$_LOCAL/bin/python"


set_python_as_link() {
    #: Make binary python available as a link to python3:
    log info "Setting up python link..."
    into_dir_do "$_LOCAL/bin" 'ln -s "$(which python3)" python'
    # TODO: depending on 'which' - not ideal, think on replacement
    log info "Created symlink 'python' to $(which python3)"
}

smoke_test_python_link() {
    python -V || die "Creating python as link to python3 FAILED."
    log info "Smoke test OK. (python -V)"
}

_apt_packages="
    python3-venv
    python3-dev
"

install_dev_essentials() {
    # Be careful on undo install because of issue #19
    log info "Installing dev-essentials..."
    mash install dev-essentials
}

install_apt_packages() {
    log info "Installing apt packages..."
    sudo apt-get install -y "${_apt_packages}"
}

# mash install pip-bootstrap (?)

install_pipx_local() {
    log info "Installing pipx-local..."
    mash install pipx-local
}

doit() {
    log info "Installing python-dev"
    skip_msg="'python' executable found, skip linking."
    python -V 2>/dev/null && log info "$skip_msg" || set_python_as_link
    smoke_test_python_link

    install_dev_essentials
    install_apt_packages
    install_pipx_local
    log info "SUCCESS."
}

undo() {
    if ! [ -e "${link_path}" ]; then
        log warn "Link '~/.local/bin/python' python3 not there, skipping."
    else
        log info "Removing '~/.local/bin/python' link to python3..."
        rm "${link_path}"
        [ -e "${link_path}" ] && die 14 "Removing ${link_path} FAILED!"
    fi

    log info "NOT Removing dev-essentials..."
#    mash undo install dev-essentials

    log info "Purging apt packages..."
    sudo apt-get purge "${_apt_packages}"

    log info "Removing pipx_local..."
    mash undo install pipx-local

    log info "Python-dev removed successfully."
}

$mash_action
