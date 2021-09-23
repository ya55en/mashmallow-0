#! /bin/sh

#: Install mash core.
#: mash (full name ma(r)shmallow) is a recipe store and runner
#: for POSIX environments. See https://mashmallow.dev

_LOCAL="$HOME/.local"
_LOCAL_SUBDIRS='bin lib opt share'
_MASH_HOME="${MASH_HOME:-${_LOCAL}/opt/mash}"
_DOWNLOAD_CACHE=/tmp

# TODO: auto-detect latest version
__version__='0.0.4'
_MASH_FILENAME="mash-v${__version__}.tgz"
_URL_DOWNLOAD="https://github.com/ya55en/mashmallow-0/releases/download/v${__version__}/${_MASH_FILENAME}"

echo "DEBUG: _MASH_HOME='${_MASH_HOME}'"
echo "DEBUG: _MASH_FILENAME='${_MASH_FILENAME}'"
echo "DEBUG: _URL_DOWNLOAD='${_URL_DOWNLOAD}'"

create_local() {
    #: Create ~/.local/{bin,lib,opt,share}. Download
    #: and install mash core.

    if [ -e "$_LOCAL" ]; then
        echo "W: $_LOCAL already exists, skipping."
    else
        echo "I: Creating directory ${_LOCAL}..."
        mkdir "${_LOCAL}"
    fi

    for directory in $_LOCAL_SUBDIRS; do
        thedir="${_LOCAL}/${directory}"
        if [ -e "${thedir}" ]; then
            echo "W: ${thedir} already exists, skipping."
        else
            echo "I: Creating ${thedir}..."
            mkdir "${thedir}"
        fi
    done
}

download_mash_core() {
    #: Download mash core tarball and install it.

    target_filename="${_DOWNLOAD_CACHE}/${_MASH_FILENAME}"
    echo "install_mash(): target_filename=${target_filename}"

    if [ -e "${target_filename}" ]; then
        echo "Release file already downloaded, skipping."
    else
        echo "Downloading ${target_filename}..."
        curl -sL "$_URL_DOWNLOAD" -o "${target_filename}" ||
            die 9 "Download failed. (URL: $_URL_DOWNLOAD)"
    fi

}

install_mash_core() {
    #: Install mash core into $_MASH_HOME, creating
    #: $_MASH_HOME/{bin,etc,lib,share/recipes}.

    target_filename="${_DOWNLOAD_CACHE}/${_MASH_FILENAME}"

    if [ -e "${_MASH_HOME}" ]; then
        echo "Target directory already exists: ${_MASH_HOME}, skipping."
    else
        echo "Deploying mash archive to target directory ${_MASH_HOME}..."
        mkdir -p "${_MASH_HOME}"
        tar xf "${target_filename}" -C "${_MASH_HOME}"
    fi
}

create_bashrcd() {
    #: Create ~/.bashrc.d/

    if [ -e "$HOME/.bashrc.d" ]; then
        echo "W: $HOME/.bashrc.d/ already exists, skipping."
    else
        echo "I: Creating $HOME/.bashrc.d/..."
        mkdir "$HOME/.bashrc.d"
    fi
}

create_add_to_path_script_00() {
    #: Create add-to-path script ~/.bashrc.d/00-mash-init.sh

    target_filename="$HOME/.bashrc.d/00-mash-init.sh"

    if [ -e "${target_filename}" ]; then
        echo "Add-to-path init script already exists, skipping. (${target_filename})"
    else
        echo "Installing add-to-path init script ${target_filename}..."
        cat > "${target_filename}" << EOS
# ~/.bashrc.d/00-mash-init.sh - mash: initialization: first things first ;)

_LOCAL="\$HOME/.local"
_LOCAL_SHARE_APPS="\$_LOCAL/share/applications"

echo "\$PATH" | grep -q "\$_LOCAL/bin" || PATH="\$_LOCAL/bin:\$PATH"

# Set XDG_DATA_DIRS, if needed, so it includes user's private share section if it exists.
# See https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html
echo "\$XDG_DATA_DIRS" | grep -q "\$_LOCAL_SHARE_APPS" ||
    XDG_DATA_DIRS="\$_LOCAL_SHARE_APPS:\$XDG_DATA_DIRS"

EOS
    fi
}

create_add_to_path_script_99() {
    #: Create add-to-path script ~/.bashrc.d/99-mash-setup.sh

    target_filename="$HOME/.bashrc.d/99-mash-setup.sh"

    if [ -e "${target_filename}" ]; then
        echo "Add-to-path setup script already exists, skipping. (${target_filename})"
    else
        echo "Installing add-to-path setup script ${target_filename}..."
        cat > "${target_filename}" << EOS
# ~/.bashrc.d/99-mash-setup.sh - mash: set some variables and do add-to-path mash/bin

MASH_HOME="$_MASH_HOME" ; export MASH_HOME

echo \$PATH | grep -q "\$MASH_HOME/bin" ||
    PATH="\$MASH_HOME/bin:\$PATH" ; export PATH

EOS
    fi
}

add_bashrcd_sourcing_snippet() {
    #: Add ~/.bashrc.d/ activation code to ~/.bashrc

    # shellcheck disable=SC2016
    if grep -q 'for file in "$HOME/.bashrc.d/"*.sh; do' ~/.bashrc; then
        echo "bashrc.d sourcing snippet already set, skipping."
    else
        echo "Setting bashrc.d sourcing snippet..."
        cat >> "$HOME/.bashrc" << EOS

#: mash: sourcing initializing scripts from ~/.bashrc.d/*.sh
for file in "\$HOME/.bashrc.d/"*.sh; do
    . "\$file"
done
EOS
    fi
}

instruct_user() {
    #: Print adequate instructions on the console.

    cat << EOS

Please close and reopen any shell-based terminals
in order to refresh your variables.

TODO: ** Instruct user what to do after installation. **

TODO: Think on having a refresh-env commad to reload env
vars from ~/bashrc.d/.

EOS
}

main() {
    create_local
    download_mash_core
    install_mash_core
    create_bashrcd
    create_add_to_path_script_00
    create_add_to_path_script_99
    add_bashrcd_sourcing_snippet
    instruct_user
}

main
