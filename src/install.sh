#! /bin/sh

#: Install mash core.
#: mash (full name ma(r)shmallow) is a recipe store and runner
#: for POSIX environments. See https://mashmallow.dev

_LOCAL="$HOME/.local"
_LOCAL_SUBDIRS='bin lib opt share'
_MASH_HOME="${MASH_HOME:-${_LOCAL}/opt/mash}"
_DOWNLOAD_CACHE=/tmp

_URL_LATEST=https://github.com/ya55en/mashmallow-0/releases/latest
_URL_DOWNLOAD_RE='^location: https://github.com/ya55en/mashmallow-0/releases/tag/v\(.*\)$'
__version__=$(curl -Is $_URL_LATEST | grep ^location | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")
# __version__='0.0.5'
_MASH_FILENAME="mash-v${__version__}.tgz"
_URL_DOWNLOAD="https://github.com/ya55en/mashmallow-0/releases/download/v${__version__}/${_MASH_FILENAME}"

echo "DEBUG: HOME='${HOME}'"
echo "DEBUG: _MASH_HOME='${_MASH_HOME}'"
echo "DEBUG: _MASH_FILENAME='${_MASH_FILENAME}'"
echo "DEBUG: _URL_DOWNLOAD='${_URL_DOWNLOAD}'"

create_dot_local() {
    #: Create ~/.local/{bin,lib,opt,share}.

    # mkdir -p "${_LOCAL}"  # YD: Do we need this?

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

    target_file_path="${_DOWNLOAD_CACHE}/${_MASH_FILENAME}"
    echo "install_mash(): target_file_path=${target_file_path}"

    if [ -e "${target_file_path}" ]; then
        echo "Release file already downloaded, skipping."
    else
        echo "Downloading ${target_file_path}..."
        curl -sL "$_URL_DOWNLOAD" -o "${target_file_path}" ||
            die 9 "Download failed. (URL: $_URL_DOWNLOAD)"
    fi

}

install_mash_core() {
    #: Install mash core into $_MASH_HOME, creating
    #: $_MASH_HOME/{bin,etc,lib,share/recipes}.

    target_file_path="${_DOWNLOAD_CACHE}/${_MASH_FILENAME}"

    if [ -e "${_MASH_HOME}" ]; then
        echo "Target directory already exists: ${_MASH_HOME}, skipping."
    else
        echo "Deploying mash archive to target directory ${_MASH_HOME}..."
        mkdir -p "${_MASH_HOME}"
        tar xf "${target_file_path}" -C "${_MASH_HOME}"
    fi
}

create_bashrcd() {
    #: Create ~/.bashrc.d/ .

    if [ -e "$HOME/.bashrc.d" ]; then
        echo "W: $HOME/.bashrc.d/ already exists, skipping."
    else
        echo "I: Creating $HOME/.bashrc.d/..."
        mkdir "$HOME/.bashrc.d"
    fi
}

create_add_to_path_script_00() {
    #: Create add-to-path script ~/.bashrc.d/00-mash-init.sh.

    target_file_path="$HOME/.bashrc.d/00-mash-init.sh"

    if [ -e "${target_file_path}" ]; then
        echo "Add-to-path init script already exists, skipping. (${target_file_path})"
    else
        echo "Installing add-to-path init script ${target_file_path}..."
        cat > "${target_file_path}" << EOS
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
    #: Create add-to-path script ~/.bashrc.d/99-mash-setup.sh.

    target_file_path="$HOME/.bashrc.d/99-mash-setup.sh"

    if [ -e "${target_file_path}" ]; then
        echo "Add-to-path setup script already exists, skipping. (${target_file_path})"
    else
        echo "Installing add-to-path setup script ${target_file_path}..."
        cat > "${target_file_path}" << EOS
# ~/.bashrc.d/99-mash-setup.sh - mash: set some variables and do add-to-path mash/bin

MASH_HOME="$_MASH_HOME" ; export MASH_HOME

echo \$PATH | grep -q "\$MASH_HOME/bin" ||
    PATH="\$MASH_HOME/bin:\$PATH" ; export PATH

EOS
    fi
}

add_bashrcd_sourcing_snippet() {
    #: Add ~/.bashrc.d/ activation code to ~/.bashrc.

    # shellcheck disable=SC2016
    if grep -q 'for file in "$HOME/.bashrc.d/' ~/.bashrc; then
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
    create_dot_local
    download_mash_core
    install_mash_core
    create_bashrcd
    create_add_to_path_script_00
    create_add_to_path_script_99
    add_bashrcd_sourcing_snippet
    instruct_user
}

main
