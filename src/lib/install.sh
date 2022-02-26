#! /bin/sh

import logging
import assert

_install_name_='install.sh'

install_single() {
    #: Used to install single-binary recipes
    #: $1 - path to source, $2 - name, $3 - version, $4 (optional) - relative path to binary (w/o the first dir)
    echo "install_single($1, $2, $3, $4) called!"
    dir_fullpath="$_LOCAL/opt/$2/$3"
    mkdir -p "$dir_fullpath"
    ln -fs  "$dir_fullpath" "$_LOCAL/opt/$2/current"
    cp -pr "$1" "$dir_fullpath/$2"
    if [ -z "$4" ]; then
        path_to_bin="$2"
    else
        path_to_bin="$2/$4"
    fi
    chmod +x "$dir_fullpath/$path_to_bin"
    ln -fs "$_LOCAL/opt/$2/current/$path_to_bin" "$_LOCAL/bin/$2"
}

install_multi() {
    #: Used to install multi-binary recipes
    #:    ($1) tarball_path - path to the source tarball
    #:    ($2) recipe_name - the name of the recipe currently being installed
    #:    ($3) version - the version of the recipe currently being installed
    local tarball_path="$1"; local recipe_name="$2"; local version="$3"

    #: create proper .local/opt/name/version directory structure and extract the tarball
    local recipe_dir="$_LOCAL/opt/$recipe_name"
    if [ -e "$recipe_dir/$version" ]; then
        _warn "Current version seems to have been installed in $recipe_dir"
        # exit here?
    fi
    mkdir -p "$recipe_dir"
    _info "Extracting tarball into $recipe_dir ..."
    tar xf "$tarball_path" -C "$recipe_dir" ||
        die $? "Extracting $source_path FAILED (rc=$?)"
    mv "$recipe_dir/$(ls $recipe_dir)" "$recipe_dir/$version"
    #: create 'current' symlink
    if [ -L "$recipe_dir/current" ]; then
        _warn "Symlink $recipe_dir/current has already been created, skipping."
    else
        _info "Creating symlink 'current' to $recipe_dir/$version ..."
        ln -fs  "$recipe_dir/$version" "$recipe_dir/current"
        [ -e "$recipe_dir/$version" ] || die 33 "Creating symlink 'current' to $recipe_dir/$version FAILED"
    fi

}

install_bashrcd_script(){
    #: Used to create ~/.bashrc.d/ script to setup path
    #:    ($1) recipe_name - the name of the recipe currently being installed
    #:    ($2) env_filename - the name for the ~/.bashrc.d/ script file
    #:    ($3) bin_directory [optional] - path to directory containing the binaries, by default is current/bin
    local recipe_name="$1"; local env_filename="$2"; local binary_dir="$3"

    local env_path="$HOME/.bashrc.d/$env_filename"
    if [ -e "$env_path" ]; then
        _warn "Env setup script for $recipe_name already exists, skipping ($env_path)"
        return 4
    fi
    _info "Creating env setup script ($env_path) ..."

    if [ -z "$binary_dir" ]; then
        #: binary dir not given: defaulting to current/bin
        binary_dir="$_LOCAL/opt/$recipe_name/current/bin"
    fi
    cat > "$env_path" << EOS
# $env_path - mash: add ${recipe_name} bin to PATH

_RECIPE_HOME='${binary_dir}'
echo \$PATH | grep -q "\$_RECIPE_HOME" || PATH="\$_RECIPE_HOME:\$PATH"

EOS
}



if [ "$_name_" = "$_install_name_" ]; then
    _error "$_install_name_ is a library to be sourced, not executed."
fi
