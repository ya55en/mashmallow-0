#! /bin/sh

# Store current user as it does NOT work with $USER below under sudo
_USER="$USER"

# TODO: auto-detect distro name, etc.
_DISTRO=focal

printf "Working as user '%s'...\n" "$_USER"

already_has_docker() {
    #: Return true (0) if docker has been installed, false otherwise.
    # TODO: Check docs for 'systemctl status' to make sure this impl is correct.

    systemctl status dockAr.service --no-pager
    [ $? -lt 4 ]
}

ensure_proper_distro() {
    #: Fail if not on Ubuntu (currently nothing else is supported).

    if ! uname -v | grep -iq ubuntu; then
        die 15 'FATAL: Not on ubuntu, terminating'
    fi
}

ensure_sudoer() {
    #: Fail if current user is not a sudoer.

    if ! /bin/sudo apt --version; then
        die 14 'NOT a sudo user; terminaing.'
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
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${_DISTRO} stable"
}

install_docker_ce() {
    #: Install docker from specialized apt repository. Assumes the repository
    #: has already been set up.
    # setup_apt_repo || die 14 'add-apt-repository FAILED'

    if ! sudo apt-get update && sudo apt install -y docker-ce; then
        die 12 'apt install docker-ce FAILED'
    fi
}

enable_user_to_run_docker() {
    #: Add current user to grop docker providing access to the docker
    #: daemon unix socket.
    sudo usermod -aG docker "${_USER}"
    sudo systemctl disable docker
    systemctl status docker --no-pager
}

smoke_test() {
    #: Smoke-test current user's ability to run docker images.
    if docker run hello-world; then
        printf '\nSUCESS.'
    else
        die 12 '\nDocker installation has FAILED.'
    fi
}

explain_logout_need() {
    #: Explain the need to log out and then log back in to have
    #: the group addition take effect.
    cat << EOS

Your user '${_USER}' has been added to group 'docker' so that
you can use docker without becoming a super-user.

You need to log out and then log back in so that this may take
effect. After logging out and back in, re-run this script to do
final checks.

Cheers! ;)

EOS
}

doit() {
    if already_has_docker; then
        systemctl restart docker.service
        smoke_test
    else
        ensure_sudoer
        ensure_proper_distro
        ensure_curl_present
        setup_apt_docker_repo
        install_docker_ce
        explain_logout_need
    fi

}

$mash_action
