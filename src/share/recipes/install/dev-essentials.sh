#! /bin/sh

# Assumming lib/libma.sh has been sourced already.

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
    log info "Installing apt packages..."
    sudo apt-get install -y ${apt_packages}
}

install_github_cli() {
    log info "Installing github-cli via mash..."
    mash install github-cli
}

tune_apt_install_scope() {
    if [ -e "${apt_confd_fullpath}" ]; then
        log warn "$(dirname ${apt_confd_fullpath}) already has ${apt_confd_file}, skipping."
    else
        tmp_filename='nuGzbYqEiU~' # TODO: have a dynamic random name for better security
        log info "Installing apt config ${apt_confd_fullpath}..."

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
        log warn "$(dirname ${p_sswdless_sudo_fullpath}) already has ${p_sswdless_sudo_file}, skipping."
    else
        tmp_filename='cUpQF531OE~' # TODO: have a dynamic random name for better security
        log info "Installing p_sswdless sudo config ${p_sswdless_sudo_fullpath}..."

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
    log info "** Installing developer essentials..."
    install_apt_packages
    install_github_cli
    tune_apt_install_scope
    setup_p_sswdless_sudo
    log info "** SUCCESS."
}

undo() {
    log info "** UN-installing dev-essentials..."

    log info "-- Removing p_sswdless sudo setup ${p_sswdless_sudo_fullpath}..."
    sudo rm -f "${p_sswdless_sudo_fullpath}"

    log info "-- Removing github-cli..."
    mash install github-cli

    log info "-- Purging apt packages (will ask - please say NO! :)..."
    # Asking the user on purge, because of issue #19:
    sudo apt-get purge ${apt_packages}

    # moving at the end trying to reduce the disastrous effect of 'apt-get purge'
    log info "-- Removing apt config ${apt_confd_fullpath}..."
    sudo rm -f "${apt_confd_fullpath}"

    log info "** dev-essentials removal successful."
}

doit
