#! /bin/sh

import logging
import assert

_install_name_='install.sh'

install_single() {
    #: Used to install single-binary recipes.
    #: When calling from a test, set test_environment to true before calling.
    #:    WARNING: this will install recipes inside /tmp/ - do this only for testing!
    local source_path="$1"               #: source_path - path to the source directory/file
    local recipe_name="$2"               #: recipe_name - the name of the recipe currently being installed
    local version="$3"                   #: version - the version of the recipe currently being installed
    local bin_path="${4:-$recipe_name}"  #: bin_path [optional] - in case of archive - relative path to binary inside

    local recipe_dir="$_LOCAL/opt/$recipe_name"
    if [ "$test_environment" = true ]; then
        recipe_dir="/tmp/mash-tests/$recipe_name"
    fi
    if [ -e "$recipe_dir/$version" ]; then
        die 9 "Current version seems to have been installed in $recipe_dir - please remove and try again."
    fi

    #: extract source
    mkdir -p "$recipe_dir/$version"
    local archive_stderr="$(tar xf $source_path -C $recipe_dir/$version 2>&1 >/dev/null)"
    if [ "$(echo $archive_stderr | grep -c 'tar: This does not look like a tar archive')" = '1' ]; then
        #: source is (assuming no bad input) a single binary - just copy it
        _info "Copying binary into $recipe_dir ..."
        cp -pr "$source_path" "$recipe_dir/$version/$recipe_name"
    elif [ -z "$archive_stderr" ]; then
        #: source is a tarball
        _info "Extracting tarball into $recipe_dir ..."
        #: check if further unpacking necessary
        local count=0
        for dir in $recipe_dir/$version/*; do
            count=$((count+1))
        done
        if [ "$count" -eq 1 ]; then
            #: move the files one directory up and delete the now empty directory
            local unarchived_dir="$(ls $recipe_dir/$version)"
            mv "$recipe_dir/$version/$unarchived_dir"/* "$recipe_dir/$version"
            rm -r "$recipe_dir/$version/$unarchived_dir"
        fi
    else
        die $? "Extracting $source_path FAILED (rc=$?) (stderr=$archive_stderr)"
    fi
    chmod +x "$recipe_dir/$version/$bin_path"

    #: create 'current' symlink
    if [ -L "$recipe_dir/current" ]; then
        _warn "Symlink $recipe_dir/current has already been created, skipping."
    else
        _info "Creating symlink 'current' to $recipe_dir/$version ..."
        ln -fs  "$recipe_dir/$version" "$recipe_dir/current"
        [ -e "$recipe_dir/$version" ] || die 33 "Creating symlink 'current' to $recipe_dir/$version FAILED"
    fi

    #: create symlink in ~/.local/bin
    local local_bin="$_LOCAL/bin"
    if [ "$test_environment" = true ]; then
        local_bin="/tmp/mash-tests/bin"
        mkdir -p "$local_bin"
    fi
    if [ -L "$local_bin/$recipe_name" ]; then
        _warn "Symlink $local_bin/$recipe_name has already been created, skipping."
    else
        _info "Creating symlink '$recipe_name' in $local_bin ..."
        ln -fs "$recipe_dir/current/$bin_path" "$local_bin/$(basename $bin_path)"
        [ -e "$recipe_dir/$version" ] || die 33 "Creating symlink '$recipe_name' in $local_bin FAILED"
    fi
}

install_multi() {
    #: Used to install multi-binary recipes.
    #: When calling from a test, set test_environment to true before calling.
    #:    WARNING: this will install recipes inside /tmp/ - do this only for testing!
    local tarball_path="$1"  #: tarball_path - path to the source tarball
    local recipe_name="$2"   #: recipe_name - the name of the recipe currently being installed
    local version="$3"       #: version - the version of the recipe currently being installed

    #: create proper .local/opt/name/version directory structure and extract the tarball
    local recipe_dir="$_LOCAL/opt/$recipe_name"
    if [ "$test_environment" = true ]; then
        recipe_dir="/tmp/mash-tests/$recipe_name"
    fi
    if [ -e "$recipe_dir/$version" ]; then
        die 9 "Current version seems to have been installed in $recipe_dir - please remove and try again."
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
    #: Used to create ~/.bashrc.d/ script to setup path.
    #: When calling from a test, set test_environment to true before calling.
    #:    WARNING: this will place scripts inside /tmp/ - do this only for testing!
    local recipe_name="$1"   #: recipe_name - the name of the recipe currently being installed
    local env_filename="$2"  #: env_filename - the name for the ~/.bashrc.d/ script file
    local binary_dir="$3"    #: bin_directory [optional] - path to directory containing the binaries, defaults to current/bin
    binary_dir="${3:-$_LOCAL/opt/$recipe_name/current/bin}"

    local env_path="$HOME/.bashrc.d/$env_filename"
    if [ "$test_environment" = true ]; then
        env_path="/tmp/mash-tests/.bashrc.d/$env_filename"
    fi
    if [ -e "$env_path" ]; then
        _warn "Env setup script for $recipe_name already exists, skipping ($env_path)"
        return 4
    fi
    _info "Creating env setup script ($env_path) ..."

    cat > "$env_path" << EOS
# $env_path - mash: add ${recipe_name} bin to PATH

_RECIPE_HOME='${binary_dir}'
echo \$PATH | grep -q "\$_RECIPE_HOME" || PATH="\$_RECIPE_HOME:\$PATH"

EOS
}


if [ "$_name_" = "$_install_name_" ]; then
    _error "$_install_name_ is a library to be sourced, not executed."
fi
