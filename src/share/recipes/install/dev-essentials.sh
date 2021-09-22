#! /bin/sh

# Assumming lib/libma.sh has been sourced already.

doit() {
  log info "Installing developer essentials"
   sudo apt-get install -y \
    build-essential \
    make cmake \
    git \
    vim \
    curl \
    bzip2 xz-utils \
    screen
  # potentially use neo-vim?
  mash install github-cli
#  sudo apt install no-install-recommends
#  sudo apt install no-install-suggests
  log info "Installed developer essentials successfully"
}

undo() {
  log info "Uninstalling developer essentials"
  mash undo install github-cli
  sudo apt-get purge -y \
    screen \
    xz-utils \
    bzip2 \
    curl \
    vim \
    git \
    cmake \
    make \
    build-essential
  log info "Uninstalled developer essentials successfully"
}

doit

