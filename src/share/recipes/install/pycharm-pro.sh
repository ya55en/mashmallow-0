#! /bin/sh

# set -x

# Assumming lib/libma.sh has been sourced already.

die 22 "pycharm-pro is deprecated in favour of a universal pycharm recipe."

DEBUG=true  # use DEBUG=false to suppress debugging

import logging

# Install Pycharm Pro

version='2021.2.1'
_debug "version=[$version]"

pycharm_filename="pycharm-professional-${version}.tar.gz"

_URL_DOWNLOAD="https://download.jetbrains.com/python/${pycharm_filename}"
_URL_HASHSUM="https://download.jetbrains.com/python/${pycharm_filename}.sha256"

_debug "_URL_DOWNLOAD=[$_URL_DOWNLOAD]"
_debug "_URL_DOWNLOAD=[$_URL_HASHSUM]"

# Download and install:
_info "Downloading Pycharm Pro v${version}..."
curl -sSL "$_URL_DOWNLOAD" -o "/tmp/${pycharm_filename}"

# TODO: check sha256 from $_URL_HASHSUM

_info "Extracting ${pycharm_filename}..."
tar xf "/tmp/${pycharm_filename}" -C "$_LOCAL/opt/"

pycharm_dir="$_LOCAL/opt/pycharm-${version}"
[ -d "${pycharm_dir}/bin" ] || die 2 "Bin directory NOT found: ${pycharm_dir}/bin"

cwd="$(pwd)" && cd "${_LOCAL}/opt" && ln -fs $(basename ${pycharm_dir}) pycharm && cd "$cwd"

linked_dir="$_LOCAL/opt/pycharm"
[ -e "${linked_dir}" ] || die 2 "Linked directory NOT found: ${linked_dir}"

echo "export PATH=\$PATH:${linked_dir}/bin" > ~/.bashrc.d/42-pycharm-pro.sh

# smoke test: source the PATH setup and run a script in pycharm/bin
. ~/.bashrc.d/42-pycharm-pro.sh
printenv.py /dev/null || die 9 "Setting up PATH to include pycharm bin/ FAILED."

_info 'Smoke test passed.'
_info 'Done. ;)'
