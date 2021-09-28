#! /bin/sh
#: Remove mash core.
#: mash (full name ma(r)shmallow) is a recipe store and runner
#: for POSIX environments. See https://mashmallow.dev

_LOCAL="$HOME/.local"
_MASH_HOME="${_LOCAL}/opt/mash"

remove_mash_home() {
    #: Remove mash core (the MASH_HOME directory).

    log info "Removing mash home directory ..."
    if [ -e "${_MASH_HOME}" ]; then
        log info "${_MASH_HOME}"
        rm -r "${_MASH_HOME}"
    else
        log info "Directory does Not exist: ${_MASH_HOME}"
    fi
}

remove_add_to_path_script_00() {
    #: Remove add-to-path script ~/.bashrc.d/00-mash-init.sh

    log info "Removing add to path script 00 ..."
    target_filename="$HOME/.bashrc.d/00-mash-init.sh"
    if [ -e "${target_filename}" ]; then
        log info "Add-to-path script 00: ${target_filename}"
        rm "${target_filename}"
    else
        log warn "Add-to-path script 00 does Not exist: ${target_filename}"
    fi
}

remove_add_to_path_script_99() {
    #: Remove add-to-path script ~/.bashrc.d/99-mash-setup.sh

    log info "Removing add to path script 99 ..."
    target_filename="$HOME/.bashrc.d/99-mash-setup.sh"
    if [ -e "${target_filename}" ]; then
        log info "Add-to-path script 99: ${target_filename}"
        rm "${target_filename}"
    else
        log warn "Add-to-path script 99 does Not exist: ${target_filename}"
    fi
}

instruct_user() {
    #: Print adequate instructions on the console.

    cat << EOS

Mash removed successfully.

TODO: ** Instruct user what to do after removal. **

TODO: Think on having a refresh-env commad to reload env

EOS
}

doit() {
    log warn "Removing mash ..."
    remove_mash_home
    remove_add_to_path_script_00
    remove_add_to_path_script_99
    instruct_user
}

doit
