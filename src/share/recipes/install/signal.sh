#!/bin/sh

# Install Signal (for Debian-based systems)
# See https://signal.org/en/download/
# Click "Download for Linux" or "Dignal for Linux" -- you should see a modal window
# "Linux (Debian-based) Install Instructions".

import logging

#: Install Signal official public software signing key.
install_official_signing_key() {
    if [ -e "$_keyrings_dir_/$_pgp_key_filename_" ]; then
        _warn "PGP key file already exists, skipping ($_keyrings_dir_/$_pgp_key_filename_)"
    else
        _info "Downloading Signal's official public software signing key..."
        curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > "$_pgp_key_filename_"
        # shellcheck disable=SC2154
        cat "$_pgp_key_filename_" | sudo tee -a "$_keyrings_dir_/$_pgp_key_filename_" > /dev/null
        _info "Key installed in $_keyrings_dir_/$_pgp_key_filename_."
    fi
}

#: Add our repository to your list of repositories.
add_signal_repository() {
    local ubu_codename=xenial # they do not support higher versions :(
    local signal_ubuntu_repo_url='https://updates.signal.org/desktop/apt'
    # ubu_codename="$(lsb_release -c | awk '{print $2}')"

    _info "Setting up Signal ubuntu repository for $ubu_codename..."
    echo "deb [arch=amd64 signed-by=$_keyrings_dir_/signal-desktop-keyring.gpg] $signal_ubuntu_repo_url $ubu_codename main" |
        sudo tee "/etc/apt/sources.list.d/signal-desktop-${ubu_codename}.list"
}

#: Install the signal package(s).
apt_install_signal_desktop() {
    sudo apt update && sudo apt install signal-desktop
}

#: Smoke test signal-desktop
smoke_test() {
    # TODO: Implement
    :
}

doit() {
    install_official_signing_key
    add_signal_repository
    apt_install_signal_desktop
}

undo() {
    die 33 "Unfortunately, 'undo' NOT supported (yet)"
}

main() {
    local _keyrings_dir_='/usr/share/keyrings'
    local _pgp_key_filename_='signal-desktop-keyring.gpg'

    $mash_action
}

main
