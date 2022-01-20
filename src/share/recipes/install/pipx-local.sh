#! /bin/sh

_LOCAL="$HOME/.local"
_PYTHON_VENVS="$_LOCAL/venvs"
bashrcd_script='32-pipx-setup.sh'

import logging
import removal

create_venvs_dir() {
    #:  Create `~/.local/venvs`

    if ! [ -d "$_PYTHON_VENVS" ]; then
        _info "Creating ~/.local/venvs directory ..."
        mkdir "$_PYTHON_VENVS"
    fi
}

install_python3_venv() {
    #:  Install python3-venv
    #TODO: check if python3-venv is installed

    _info "Installing python3-venv ..."
    sudo apt-get update
    sudo apt-get install python3-venv
}

create_pipx_venv() {
    #:  Create pipx venv in `~/.local/venvs`
    #TODO: check if pipx venv exists

    _info "Creating pipx venv in '~/.local/venvs' ..."
    python3 -m venv "$_PYTHON_VENVS/pipx" --prompt pipx-local && _info "Created."
}

update_trio() {
    #:  Update (pip setuptools wheel) trio

    _info "Updating (pip setuptools wheel) trio ..."
    "$_PYTHON_VENVS/pipx/bin/python3" -m pip install -U pip setuptools wheel
}

install_pipx() {
    #:  Install pipx
    #TODO: check if pipx is installed

    _info "Installing pipx..."
    "$_PYTHON_VENVS/pipx/bin/python3" -m pip install pipx
}

create_symlink() {
    #: Create symlink `~/.local/bin/pipx` => `~/.local/venvs/pipx/bin/pipx`
    #TODO: check if symlink already exists

    _info "Creating symlink '~/.local/bin/pipx' => '~/.local/venvs/pipx/bin/pipx'"
    ln -fs "$_PYTHON_VENVS/pipx/bin/pipx" "$_LOCAL/bin/pipx"
}

create_bashrcd_script() {
    #: Create `~/.bashrc.d/32-pipx-setup.sh`
    # Creating without idempotency check, so that changes are always reflected.
    # Depends on 'which' - not ideal; TODO: provide default python otherwise
    bashrcd_script_path="$HOME/.bashrc.d/${bashrcd_script}"

    _info "Creating bashrcd script: $bashrcd_script_path"
    cat > "${bashrcd_script_path}" << EOS
# pipx-related setup
export PIPX_HOME="$HOME/.local"
export PIPX_DEFAULT_PYTHON="$(which python3)"
# eval "\$(register-python-argcomplete3 pipx)"  # see if this can work
EOS
}

smoke_test() {
    #TODO: implement
    true
}

instruct_user() {
    cat << EOS

In order to have all your terminals know about the bashrc.d change,
you need to:
  - EITHER source the bashrc.d script (see below) in all open terminals,
  - OR log out, then log back in.

To source the bashrc.d script, do (note the dot in front):

 $ . "~/.bashrc.d/${bashrcd_script}"

 pipx should be accessible now from anywhere on the command line,
 with:

  $ pipx

EOS

}

doit() {
    create_venvs_dir
    install_python3_venv
    create_pipx_venv
    update_trio
    install_pipx
    create_symlink
    create_bashrcd_script
    instruct_user

    _info "Done."
}

undo() {
    _info "Removing pipx-local:"
    delete_files "Removing bashrcd script: ${bashrcd_script} ..." "${bashrcd_script_path}"
    delete_files "Removing symlink $_LOCAL/bin/pipx ..." "$_LOCAL/bin/pipx"
    delete_directory "Removing pipx venv ..." "$_PYTHON_VENVS/pipx"
    _info 'pipx-local removed successfully.'
}

$mash_action
