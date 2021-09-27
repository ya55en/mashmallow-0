#!/bin/bash

# 0. The installation would determine last version TODO: make it so it does that

ARCH=x86_64
if [ "$ARCH" = x86_64 ]; then
    _short_arch=amd64
elif [ "$ARCH" = x86 ]; then
    _short_arch=386
# TODO: provide mapping for all supported architectures
else
    die 77 "Unknown architecture: ARCH=[$ARCH]"
fi

_LOCAL="$HOME/.local"
version='3.3.1'
shfmt_filename="shfmt_v${version}_linux_${_short_arch}"
shfmt_dir="$_LOCAL/opt/shfmt"
log debug "Version: [${version}]"
_DOWNLOAD_URL="https://github.com/mvdan/sh/releases/download/v${version}/shfmt_v${version}_linux_${_short_arch}"
log debug "Download URL: [${_DOWNLOAD_URL}]"

download_in_download_cache() {
    #: Download into the download cache.
    skip="${1:-no-skip}"

    if [ "$skip" = skip-if-exists ] && [ -f "${_DOWNLOAD_CACHE}/${shfmt_filename}" ]; then
        log warn "Target archive already downloaded, skipping."
        log warn "File exits: ${_DOWNLOAD_CACHE}/${shfmt_filename}"
    else
        log debug "_DOWNLOAD_URL=$_DOWNLOAD_URL"
        # log debug "_URL_DOWNLOAD=$_URL_HASHSUM"
        mkdir -p "${_DOWNLOAD_CACHE}"
        log debug "DOWNLOAD_CACHE dir=${_DOWNLOAD_CACHE}"
        log info "Downloading shfmt, v${version} ..."
        rm -f "${_DOWNLOAD_CACHE}/${shfmt_filename}"
        curl -sL "${_DOWNLOAD_URL}" -o "${_DOWNLOAD_CACHE}/${shfmt_filename}" ||
            die 97 "Download FAILED. rc=$? (URL: ${_DOWNLOAD_URL})"
        chmod 775 "${_DOWNLOAD_CACHE}/${shfmt_filename}"
    fi
}

move_into_opt() {
    #: Create ./local/opt/shfmt/
    # and put the versioned binary (e.g. shfmt_v3.3.1_linux_amd64) there.
    log info "Creating ${shfmt_dir} ..."
    mkdir -p "${shfmt_dir}"
    log info "Moving ${_DOWNLOAD_CACHE}/${shfmt_filename} to opt ..."
    mv "${_DOWNLOAD_CACHE}/${shfmt_filename}" "${shfmt_dir}" ||
        die $? "Moving ${_DOWNLOAD_CACHE}/${shfmt_filename} FAILED (rc=$?)"
    [ -d "$shfmt_dir" ] || die 63 "Shfmt directory NOT found: ${shfmt_dir}"
}

create_symlink() {
    #: Create a symlink in ./local/bin named shfmt.
    log info "Creating symlink in ./local/bin named shfmt ..."
    ln -fs "${shfmt_dir}/${shfmt_filename}" "${_LOCAL}/bin/shfmt"
}

smoke_test() {
      log debug "Running a smoke test ..."
    if shfmt --version; then
        log info "Smoke test passed OK. (shfmt --version)"
    else
        log error "Smoke test FAILED! Please check the logs."
        exit 58
    fi
}

instruct_user() {
    cat << EOS

Completed. You can use instantly, shfmt like:

  $ shfmt --help

EOS
}

doit() {
    download_in_download_cache skip-if-exists
    move_into_opt
    create_symlink
    smoke_test
    instruct_user
    log info 'SUCCESS.'
}

undo() {
    log warn "UNinstalling shellcheck version=[$version]"
    log info "Removing symlink $_LOCAL/bin/shfmt ..."
    rm "$_LOCAL/bin/shfmt"

    log info "Removing shfmt binary ..."
    rm "${shfmt_dir}/${shfmt_filename}"

    log info "Removing directory ${shfmt_dir} ..."
    rmdir "${shfmt_dir}" || log info "shfmt directory not empty, so not deleted: ${shfmt_dir}"
    [ ! -d "${shfmt_dir}" ]
    log info 'UNinstallation ended.'

}

$mash_action
