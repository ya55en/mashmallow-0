#!/bin/sh

#: Setup a ruby development environment using rbenv
#: (For rbenv see https://github.com/rbenv/rbenv)

#: Prerequisite: bash in PATH (for rbenv installation).

import logging
import os

import mashrc

install_packages() {
    sudo apt-get update
    sudo apt-get install -y $apt_packages
}

install_rbenv() {
    if rbenv -v > /dev/null 2>&1; then
        _warn "Rbenv already installed ($(rbenv --version)), skipping."
        _warn "(Remove existing one first if you need to re-install.)"
        _info "Updating existing rbenv and ruby-build..."
        git -C /home/yassen/.rbenv pull
        git -C /home/yassen/.rbenv/plugins/ruby-build pull
    else
        _info "Installing rbenv..."
        curl -fsSL "$rbenv_installer_url" | bash
    fi
}

#: Create environment setup script in ~/.bashrc.d/
create_env_setup_script() {
    local script_basename='78-rbenv-env.sh'
    local linked_dir="$HOME/.rbenv"
    local script_fullpath="${HOME}/.bashrc.d/${script_basename}"

    cat > "$script_fullpath" << EOS
# ~/.bashrc.d/$script_basename - mash: setup rbenv related env variables

_RBENV_DIR='${linked_dir}'
echo \$PATH | grep -q "\$_RBENV_DIR/bin" || PATH="\$_RBENV_DIR/bin:\$PATH"

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

install_ruby() {
    # Getting the two most important:
    # rbenv install -l 2>/dev/null | awk '/^(2\.7\.|3\.)/ {print $1}'
    rbenv install "$ruby_version" || die 33 "Ruby installation FAILED."
    rbenv global "$ruby_version"
}

install_bundler() {
    gem install bundler -v $bundler_version || die 33 "Installing bundler FAILED."
}

smoke_test() {
    rbenv install -l || _error "rbenv (+ ruby-build) is NOT operational"
    irb -v || _error "irb (interactive ruby) is NOT operational"
    ruby -v || die 33 "ruby is NOT operational"
}

inform_user() {
    _info 'SUCCESS!'
    _warn 'You need to **close and reopen** all your terminals now.'
    _warn 'Then you will be able to use rbenv, ruby, gem, etc., like:'
    cat << EOS

 $ rbenv versions
 $ rbenv install --list
 $ ruby -v
 $ gem -v
 $ irb -v

EOS
}

doit() {
    install_packages
    install_rbenv
    create_env_setup_script
    alter_path
    install_ruby
    smoke_test
    inform_user
}

main() {
    local apt_packages=
    local rbenv_installer_url='https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer'
    local ruby_version='2.7.2'
    local bundler_version='2.0.2'

    # libsqlite3-dev mandatory for one of Rails gems
    apt_packages='
curl git build-essential
libssl-dev zlib1g-dev
libsqlite3-dev sqlite3
'

    $mash_action
}

main
