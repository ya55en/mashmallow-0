#! /bin/sh

#: WIP!
#: Install mash core.
#: mash (full name ma(r)shmallow) is a recipe store and runner
#: for POSIX environments. See https://mashmallow.dev

_LOCAL="$HOME/.local"
_LOCAL_SUBDIRS='bin lib opt share'
_MASH_HOME="$_LOCAL/opt/mash"

create_local() {
    #: Create ~/.local/{bin,lib,opt,share}. Download
    #: and install mash core.

    if [ -e "$_LOCAL" ]; then
        echo "W: $_LOCAL already exists, skipping."
    else
        mkdir "$_LOCAL"
    fi

    for directory in $_LOCAL_SUBDIRS; do
        thedir="${_LOCAL}/${directory}"
        if [ -e "$thedir" ]; then
            echo "W: $thedir already exists, skipping."
        else
            mkdir "$thedir"
        fi
    done
}

create_local_mash() {
    #: Create ~/.local/mash/{bin,lib,etc,var,lib/recipes}. Download
    #: and install mash core.

    true
}

create_bashrcd() {
    #: Create ~/.bashrc.d/

    if [ -e "$HOME/.bashrc.d" ]; then
        echo "W: $HOME/.bashrc.d already exists, skipping."
    else
        echo "I: Creating $HOME/.bashrc.d..."
        mkdir "$HOME/.bashrc.d"
    fi
}

create_add_to_path_script() {
    #: Create add-to-path script ~/.bashrc.d/99-mash-setup.sh

    cat > "$HOME/.bashrc.d/99-mash-setup.sh" << EOS
MASH_HOME=$_MASH_HOME ; export MASH_HOME
add-to-path "${_MASH_HOME}/bin"
EOS
}

add_bashrcd_sourcing_snippet() {
    #: Add ~/.bashrc.d/ activation code to ~/.bashrc

    true
}

instruct_user() {
    #: Print adequate instructions on the console.

    true
}

main() {
    create_local
}

main
