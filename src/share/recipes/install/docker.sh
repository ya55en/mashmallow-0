#! /bin/sh

import logging

# Store current user as it does NOT work with $USER below under sudo
_USER="$USER"

# TODO: auto-detect distro name, etc.
_CODENAME=focal
_DISTRO=ubuntu

already_has_docker() {
    #: Return true (0) if docker has been installed, false otherwise.
    # TODO: Check docs for 'systemctl status' to make sure this impl is correct.

    systemctl status docker.service --no-pager
    test $? -lt 4
}

ensure_proper_distro() {
    #: Fail if not on Ubuntu (currently nothing else is supported).

    if ! uname -v | grep -iq "${_DISTRO}"; then
        die 15 'Not on ${_DISTRO}, terminating'
    fi
}

ensure_sudoer() {
    #: Fail if current user is not a sudoer.

    if ! /bin/sudo apt --version; then
        die 14 'NOT a sudo user; terminating.'
    fi
}

ensure_curl_present() {
    #: Fail if curl not found in PATH.

    if ! curl -V > /dev/null 2>&1; then
        die 15 'FATAL: curl not found, terminating'
    fi
}

setup_apt_docker_repo() {
    #: Set up specialized apt repository for docker.

    set -e
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${_CODENAME} stable"
}

install_docker_ce() {
    #: Install docker from specialized apt repository. Assumes the repository
    #: has already been set up.

    sudo apt-get update || die 14 'sudo apt-get update FAILED!'
    sudo apt install -y docker-ce || die 14 'sudo apt install docker-ce FAILED!'
}

add_user_to_group_docker() {
    #: Add current user to group docker providing access to the docker
    #: daemon unix socket.

    _info "Adding user '${_USER}' to group 'docker'..."
    sudo usermod -aG docker "${_USER}"
}

disable_docker_service() {
    _info "Disabling docker service..."
    _info " (docker will still work fine when invoked on the cmd line.)"
    sudo systemctl disable docker
    systemctl status docker --no-pager
}

smoke_test() {
    #: Smoke-test current user's ability to run docker images.

    docker run hello-world
}

explain_logout_need() {
    #: Explain the need to log out and then log back in to have
    #: the group addition take effect.

    cat << EOS

Your user '${_USER}' has been added to group 'docker' so that
you can use docker without becoming a super-user.

You need to **REBOOT** so that this may take effect.

After rebooting, please execute 'mash verify install docker' command!
to do final checks.

Cheers! ;)

EOS
}

inform_docker_is_working() {
    #: Explain docker has already been installed (method unknown)
    #: and working.

    cat << EOS

Docker has been found to be installed and working:

 \$ docker --version
 $(docker --version)

Cheers! ;)

EOS
}

doit() {
    ensure_sudoer
    ensure_proper_distro
    ensure_curl_present
    _info "Installing docker on ${_DISTRO} ${_CODENAME}..."
    setup_apt_docker_repo
    install_docker_ce
    add_user_to_group_docker
    disable_docker_service
    sudo systemctl restart docker.service
    explain_logout_need
}

verify() {
    already_has_docker || die 22 'docker not yet installed (or not found?)'
    sudo systemctl restart docker.service
    smoke_test ||
        die 14 'docker already installed but not working (?)\n** Have you done a REBOOT?? **'
    inform_docker_is_working
}

undo() {
    cat << EOS

'undo install docker' not yet implemented. We are sorry
for the inconvenience.

EOS
}

$mash_action
