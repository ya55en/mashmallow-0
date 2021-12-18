#! /bin/sh

#: Install mash core.
#: mash (full name ma(r)shmallow) is a recipe store and runner
#: for POSIX environments. See https://mashmallow.dev

_LOCAL="$HOME/.local"
_LOCAL_SUBDIRS='bin lib opt share'

# TODO: do we need to honor MASH_HOME here?
_MASH_HOME="${MASH_HOME:-${_LOCAL}/opt/mash}"

_DOWNLOAD_CACHE=/tmp

_URL_LATEST=https://github.com/ya55en/mashmallow-0/releases/latest
_URL_DOWNLOAD_RE='^location: https://github.com/ya55en/mashmallow-0/releases/tag/v\(.*\)$'
__latest__=$(curl -Is $_URL_LATEST | grep ^location | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")
__version__="${1:-$__latest__}" # version passed as an argument for unreleased builds

_MASH_FILENAME="mash-v${__version__}.tgz"
_URL_DOWNLOAD="https://github.com/ya55en/mashmallow-0/releases/download/v${__version__}/${_MASH_FILENAME}"

if [ "$DEBUG" = true ]; then
    echo "DEBUG: HOME='${HOME}'"
    echo "DEBUG: _MASH_HOME='${_MASH_HOME}'"
    echo "DEBUG: _MASH_FILENAME='${_MASH_FILENAME}'"
    echo "DEBUG: _URL_DOWNLOAD='${_URL_DOWNLOAD}'"
    echo "DEBUG: __version__='${__version__}'"
fi

install_sh_stdlib() {
    if [ -e "$POSIXSH_STDLIB_HOME/bin/shtest" ]
    then
        echo "I: sh-stdlib present: running tests"
        "$POSIXSH_STDLIB_HOME/bin/shtest" "$POSIXSH_STDLIB_HOME/tests" # TODO: What if tests fail?
    else
        echo "I: sh-stdlib not present: downloading and installing"
        curl -sSL https://github.com/ya55en/sh-stdlib/raw/main/install.sh | sh
    fi
}

#: Create ~/.local/{bin,lib,opt,share}.
create_dot_local() {
    if [ -e "$_LOCAL" ]; then
        echo "W: $_LOCAL already exists, skipping."
    else
        echo "I: Creating directory ${_LOCAL}..."
        mkdir -p "${_LOCAL}"
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

#: Download mash core tarball and install it.
download_mash_core() {
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

#: Install mash core into $_MASH_HOME, creating
#: $_MASH_HOME/{bin,etc,lib,share/recipes}.
install_mash_core() {
    target_file_path="${_DOWNLOAD_CACHE}/${_MASH_FILENAME}"

    if [ -e "${_MASH_HOME}" ]; then
        echo "Target directory already exists: ${_MASH_HOME}, skipping."
    else
        echo "Deploying mash archive to target directory ${_MASH_HOME}..."
        mkdir -p "${_MASH_HOME}"
        tar xf "${target_file_path}" -C "${_MASH_HOME}"
    fi
}

#: Create ~/.bashrc.d/ .
create_bashrcd() {
    if [ -e "$HOME/.bashrc.d" ]; then
        echo "W: $HOME/.bashrc.d/ already exists, skipping."
    else
        echo "I: Creating $HOME/.bashrc.d/..."
        mkdir "$HOME/.bashrc.d"
    fi
}

#: Create bashrcd script ~/.bashrc.d/00-mash-init.sh.
create_bashrcd_script_00() {
    target_file_path="$HOME/.bashrc.d/00-mash-init.sh"

    if [ -e "${target_file_path}" ]; then
        echo "Bashrcd script '00-mash-init.sh' already exists, skipping. (${target_file_path})"
    else
        echo "Installing bashrcd script ${target_file_path}..."
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
        echo "Adding MASH_HOME setup to bashrcd script ${target_file_path}..."
        cat >> "${target_file_path}" << EOS

# mash: set MASH_HOME and add mash/bin to PATH

MASH_HOME="$_MASH_HOME" ; export MASH_HOME
echo \$PATH | grep -q "\$MASH_HOME/bin" || PATH="\$MASH_HOME/bin:\$PATH"
EOS

    fi
}

#: Create bashrcd script ~/.bashrc.d/99-mash-import-path.sh.
create_bashrcd_script_99_import_path() {
    target_file_path="$HOME/.bashrc.d/99-mash-import-path.sh"

    if [ -e "${target_file_path}" ]; then
        echo "bashrcd script '99-mash-import-path.sh' already exists, skipping. (${target_file_path})"
    else
        echo "Installing bashrcd script ${target_file_path}..."
        cat > "${target_file_path}" << EOS
# ~/.bashrc.d/99-mash-import-path.sh - mash: set MASH_IMPORT_PATH

# $POSIXSH_IMPORT_PATH is necessary for sys.sh 'import()' to work.
echo "\$POSIXSH_IMPORT_PATH" | grep -q "\$MASH_HOME/etc" || POSIXSH_IMPORT_PATH="\$MASH_HOME/etc:\$POSIXSH_IMPORT_PATH"
echo "\$POSIXSH_IMPORT_PATH" | grep -q "\$MASH_HOME/lib" || POSIXSH_IMPORT_PATH="\$MASH_HOME/lib:\$POSIXSH_IMPORT_PATH"

export $POSIXSH_IMPORT_PATH
export PATH

EOS
    fi
}

#: Add ~/.bashrc.d/ activation code to ~/.bashrc.
add_bashrcd_sourcing_snippet() {
    # shellcheck disable=SC2016
    if grep -q 'for file in "\$HOME/\.bashrc.d/"\*\.sh; do' ~/.bashrc; then
        echo "bashrc.d sourcing snippet already set, skipping."
    else
        echo "Setting bashrc.d sourcing snippet..."
        cat >> "$HOME/.bashrc" << EOS

#: mash: sourcing initializing scripts from ~/.bashrc.d/*.sh
if [ -d "\$HOME/.bashrc.d/" ]; then
    for file in "\$HOME/.bashrc.d/"*.sh; do
        . "\$file"
    done
fi
EOS
    fi
}

#: Print adequate instructions on the console.
instruct_user() {
    cat << EOS

Please close and reopen any shell-based terminals
in order to refresh your variables.

TODO: ** Instruct user what to do after installation. **

TODO: Think on having a refresh-env command to reload env
vars from ~/bashrc.d/.

EOS
}

main() {
    install_sh_stdlib
    create_dot_local
    download_mash_core
    install_mash_core
    create_bashrcd
    create_bashrcd_script_00
    create_bashrcd_script_99_import_path
    add_bashrcd_sourcing_snippet
    instruct_user
}

main
