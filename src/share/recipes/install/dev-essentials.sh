#! /bin/sh

# Assumming lib/libma.sh has been sourced already.

import logging
import removal

apt_confd_file='95mash'
apt_confd_fullpath="/etc/apt/apt.conf.d/${apt_confd_file}"
p_sswdless_sudo_file="${USER}-nopass"
p_sswdless_sudo_fullpath="/etc/sudoers.d/${p_sswdless_sudo_file}"

apt_packages="
        build-essential
        make cmake
        git
        vim
        curl wget
        bzip2 xz-utils
        screen
        strace
"
# potentially use neo-vim instead of vim (?)

install_apt_packages() {
    _info "Installing apt packages..."
    sudo apt-get update
    sudo apt-get install -y ${apt_packages}
}

install_github_cli() {
    _info "Installing github-cli via mash..."
    mash install github-cli
}

tune_apt_install_scope() {
    if [ -e "${apt_confd_fullpath}" ]; then
        _warn "$(dirname ${apt_confd_fullpath}) already has ${apt_confd_file}, skipping."
    else
        tmp_filename='nuGzbYqEiU~' # TODO: have a dynamic random name for better security
        _info "Installing apt config ${apt_confd_fullpath}..."

        cat > "${tmp_filename}" << EOS
# mash: setup apt for NOT installing recommended (and suggested) packages.
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOS
        # We need to first create it as a temp file and then sudo-move it
        # as echo-ing directly to ${apt_confd_fullpath} fails with:
        #   'cannot create /etc/apt/apt.conf.d/95mash: Permission denied'
        sudo chown root:root "${tmp_filename}"
        sudo mv -f "${tmp_filename}" "${apt_confd_fullpath}"
        [ -f "${apt_confd_fullpath}" ] || die 14 "Creating ${apt_confd_fullpath} FAILED!"
    fi
}

setup_p_sswdless_sudo() {
    if [ -e "${p_sswdless_sudo_fullpath}" ]; then
        _warn "$(dirname ${p_sswdless_sudo_fullpath}) already has ${p_sswdless_sudo_file}, skipping."
    else
        tmp_filename='cUpQF531OE~' # TODO: have a dynamic random name for better security
        _info "Installing p_sswdless sudo config ${p_sswdless_sudo_fullpath}..."

        cat > "${tmp_filename}" << EOS
# mash: setup p_sswdless sudo for $USER
$USER ALL=(ALL) NOPASSWD:ALL
EOS
        # We need to first create it as a temp file and then sudo-move it
        sudo chown root:root "${tmp_filename}"
        sudo mv -f "${tmp_filename}" "${p_sswdless_sudo_fullpath}"
        [ -f "${p_sswdless_sudo_fullpath}" ] || die 14 "Creating ${p_sswdless_sudo_fullpath} FAILED!"
    fi
}

doit() {
    _info "** Installing developer essentials..."
    install_apt_packages
    install_github_cli
    tune_apt_install_scope
    setup_p_sswdless_sudo
    _info "** SUCCESS."
}

undo() {
    _info "Removing dev-essentials:"
    delete_files "Removing p_sswdless sudo setup ${p_sswdless_sudo_fullpath}..." "${p_sswdless_sudo_fullpath}"
    mash undo install github-cli # TODO: Is this ok here?
    apt_purge $apt_packages

#    TODO: ????
#    # moving at the end trying to reduce the disastrous effect of 'apt-get purge'
#    _info "-- Removing apt config ${apt_confd_fullpath}..."
#    sudo rm -f "${apt_confd_fullpath}"

    _info "dev-essentials removed successfully."
}

$mash_action
