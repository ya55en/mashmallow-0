#! /bin/sh

# set -x

# Assumming lib/libma.sh has been sourced already.

DEBUG=true # use DEBUG=false to suppress debugging

# Install Pycharm Pro

version='2021.2.2'
flavor='community'
log debug "version=[$version]"

pycharm_filename="pycharm-${flavor}-${version}.tar.gz"

# https://download-cdn.jetbrains.com/python/pycharm-community-2021.2.2.tar.gz

# _URL_DOWNLOAD="https://download.jetbrains.com/python/${pycharm_filename}"
_URL_DOWNLOAD="https://download-cdn.jetbrains.com/python/${pycharm_filename}"
_URL_HASHSUM="https://download.jetbrains.com/python/${pycharm_filename}.sha256"

log debug "_URL_DOWNLOAD=[$_URL_DOWNLOAD]"
log debug "_URL_DOWNLOAD=[$_URL_HASHSUM]"

# Download and install:
log info "Downloading Pycharm ${flavor} edition, v${version}..."
curl -sL "$_URL_DOWNLOAD" -o "/tmp/${pycharm_filename}"

# TODO: check sha256 from $_URL_HASHSUM
#   sha256sum -c pycharm-community-2021.2.2.tar.gz.sha256

log info "Extracting ${pycharm_filename}..."
tar xf "/tmp/${pycharm_filename}" -C "$_LOCAL/opt/"


pycharm_dir="$_LOCAL/opt/pycharm-${flavor}-${version}"
[ -d "${pycharm_dir}/bin" ] || die 2 "Bin directory NOT found: ${pycharm_dir}/bin"

cwd="$(pwd)" && cd "${_LOCAL}/opt" && ln -fs $(basename ${pycharm_dir}) pycharm-${flavor} && cd "$cwd"

linked_dir="$_LOCAL/opt/pycharm-${flavor}"
[ -e "${linked_dir}" ] || die 2 "Linked directory NOT found: ${linked_dir}"


echo "export PATH=\"${linked_dir}/bin:\$PATH\"" > ~/.bashrc.d/42-pycharm-${flavor}.sh

# smoke test: source the PATH setup and run a script in pycharm/bin
# $include ~/.bashrc.d/42-pycharm-pro.sh
echo DO: . "\"\${HOME}/.bashrc.d/42-pycharm-${flavor}.sh\""


# YD: printenv.py comes from opt/pycharm/bin/
# TODO: procvide working smoke test
# printenv.py /dev/null || die 9 "Setting up PATH to include pycharm bin/ FAILED."
# pycharm --version

# log info 'Smoke test passed.'
log info 'Done. ;)'

# TODO: Instruct the user to log out and log back in to refresh
#  the environment variables.
