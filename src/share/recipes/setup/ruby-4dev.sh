#!/bin/sh

#: Setup a ruby development environment using rbenv
#: (For rbenv see https://github.com/rbenv/rbenv)
#: Sources:
#:  - https://gorails.com/setup/ubuntu/22.04
#:  -

# Prerequisite:
# - sudo access
# - bash in PATH (for rbenv installation).
#
# The recipe will install these:
# - git autoconf bison build-essential
#   libssl-dev libreadline-dev zlib1g-dev libyaml-dev
#   libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

import logging
import os

import mashrc

install_packages() {
    _info 'Installing needed dev libraries and tools...'

    sudo apt-get update | sudo tee /tmp/ruby-4dev-apt-installs.log
    # shellcheck disable=SC2086
    sudo apt-get install -y $apt_packages | sudo tee -a /tmp/ruby-4dev-apt-installs.log
}

install_rbenv() {
    if rbenv -v > /dev/null 2>&1; then
        _warn "Rbenv already installed ($(rbenv --version)), skipping."
        _warn "(Remove existing one first if you need to re-install.)"
        _info "Updating existing rbenv and ruby-build..."
        git -C "$HOME"/.rbenv pull
        git -C "$HOME"/.rbenv/plugins/ruby-build pull
    else
        _info "Installing rbenv..."
        curl -fsSL "$rbenv_installer_url" | bash
    fi
}

#: Create environment setup script in ~/.bashrc.d/
create_env_setup_script() {
    local script_basename='78-rbenv-env.sh'
    local linked_dir="$HOME"/.rbenv
    local script_fullpath="${HOME}/.bashrc.d/${script_basename}"

    cat > "$script_fullpath" << EOS
# ~/.bashrc.d/$script_basename - mash: setup rbenv related env variables

_RBENV_DIR='${linked_dir}'
echo \$PATH | grep -q "\$_RBENV_DIR/bin" || PATH="\$_RBENV_DIR/bin:\$PATH"

export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$HOME/.local/openssl-1.1"
EOS

    echo "# Append output of '~/.rbenv/bin/rbenv init - bash':" >> "$script_fullpath"
    "$HOME"/.rbenv/bin/rbenv init - bash >> "$script_fullpath"
}

alter_path() {
    # YD: Sourcing below does NOT work as it is bash-specific :(
    # . "$script_fullpath"
    # YD: So we need to alter PATH manually, for later commands to succeed:
    export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

#install_ruby() {
#    # Getting the two most important:
#    # rbenv install -l 2>/dev/null | awk '/^(2\.7\.|3\.)/ {print $1}'
#    rbenv install "$ruby_version" || die 33 "Ruby installation FAILED."
#    rbenv global "$ruby_version"
#}

#install_bundler() {
#    gem install bundler -v $bundler_version || die 33 "Installing bundler FAILED."
#}

smoke_test() {
    rbenv install -l || _error "rbenv (+ ruby-build) is NOT operational"
    # irb -v || _error "irb (interactive ruby) is NOT operational"
    # ruby -v || die 33 "ruby is NOT operational"

    # Now leaving the ruby installation to the user;
    # otherwise used to check also:
    #   $ ruby -v
    #   $ gem -v
    #   $ irb -v
}

inform_user() {
    _info 'SUCCESS!'
    _warn 'You need to **close and reopen** all your terminals now.'
    _warn 'Then you will be able to use rbenv, ruby, gem, etc., like:'
    cat << EOS

 $ rbenv versions
 $ rbenv install --list

EOS
}

doit() {
    install_packages
    install_rbenv
    create_env_setup_script
    alter_path
    # install_ruby
    # install_bundler
    smoke_test
    inform_user
}

undo() {
    _warn "Undoing 'ruby-4dev' is NOT yet supported :( ... Apologies."
}

main() {
    local apt_packages
    local rbenv_installer_url='https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer'
    local ruby_version='2.7.2'
    local bundler_version='2.0.2'

    # libsqlite3-dev mandatory for one of Rails gems
    apt_packages='
git autoconf bison build-essential
libssl-dev
libreadline-dev
zlib1g-dev
libyaml-dev
libreadline-dev
libncurses5-dev
libffi-dev
libgdbm-dev
libsqlite3-dev
sqlite3
'
    sudo echo ''
    $mash_action
}

main
