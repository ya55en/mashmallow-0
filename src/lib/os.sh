#! /bin/sh

#: os standard module for mashmallow-0 project.

_OS_ARCH=
_OS_ARCH_SHORT=
_OS_OS=
_OS_KERNEL_NAME=

# TODO: we might need kernel version and/or release variables

#: Set global processor/machine architecture related variables.
_os__set_vars() {
    IFS_SAVED="$IFS"
    IFS=' '

    # shellcheck disable=2034
    read -r _OS_KERNEL_NAME _OS_ARCH _OS_OS << EOS
$(uname -spo)
EOS

    IFS="$IFS_SAVED"
}

# shellcheck disable=2120
#: Print short version of the processor architecture tag. (Used
#: by recipes like `github-cli`.)
_os__get_arch_short() {

    os_arch=${1:-$_OS_ARCH}

    if [ "$os_arch" = x86_64 ]; then
        printf 'amd64'

    elif [ "$os_arch" = x86 ]; then
        printf '386'

    # TODO: provide mapping for all supported architectures
    else
        die 77 "Architecture not implemented yet: os_arch=[$os_arch]"
    fi
}

[ -z "$_OS_ARCH" ] && _os__set_vars
[ -z "$_OS_ARCH_SHORT" ] && _OS_ARCH_SHORT="$(_os__get_arch_short)"
