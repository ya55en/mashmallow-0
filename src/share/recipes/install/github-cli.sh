#! /bin/sh

#: Install github cli

ARCH=x86_64

if [ "$ARCH" = x86_64 ]; then
    _short_arch=amd64
elif [ "$ARCH" = x86 ]; then
    _short_arch=386
# TODO: provide mapping for all supported architectures
else
    die 77 "Unknown architecture: ARCH=[$ARCH]"
fi

version='1.14.0'
ghcli_filename="gh_${version}_linux_${_short_arch}.tar.gz"
ghcli_dir="$_LOCAL/opt/gh_${version}_linux_${_short_arch}"
#TODO: how is the folder supposed to be called?

_URL_DOWNLOAD="https://github.com/cli/cli/releases/download/v${version}/${ghcli_filename}"

log debug "_URL_DOWNLOAD"

download_tarball() {
    #: Download gh cli tarball into download_cache_dir
    skip="${1:-no-skip}"

    if [ "$skip" = skip-if-exists ] && [ -f "${_DOWNLOAD_CACHE}/${ghcli_filename}" ]; then
        log warn "Target archive already downloaded, skipping."
        log warn "File exits: ${_DOWNLOAD_CACHE}/${ghcli_filename}"
    else
        log debug "_URL_DOWNLOAD=$_URL_DOWNLOAD"
        # log debug "_URL_DOWNLOAD=$_URL_HASHSUM"
        log debug "download_cache_dir=$_DOWNLOAD_CACHE"
        log info "Downloading Gh Cli, v${version}..."
        rm -f "${_DOWNLOAD_CACHE}/${ghcli_filename}"
        curl -sL "$_URL_DOWNLOAD" -o "${_DOWNLOAD_CACHE}/${ghcli_filename}" ||
            die 9 "Download failed. (URL: $_URL_DOWNLOAD)"
    fi
}

# TODO: check hash (no hash provided by upstream; make up one)

extract_into_opt() {
    #: Extract the github-cli tarball into ~/.local/opt/.

    log info "Extracting ${_DOWNLOAD_CACHE}/${ghcli_filename}..."
    tar xf "${_DOWNLOAD_CACHE}/${ghcli_filename}" -C "$_LOCAL/opt/" ||
        die $? "Extracting ${_DOWNLOAD_CACHE}/${ghcli_filename} FAILED (rc=$?)"
    [ -d "${ghcli_dir}/bin" ] || die 2 "Bin directory NOT found: ${ghcli_dir}/bin"
}

create_symlink() {
    #: Create symlink to the gh executable.

    log info "Creating symlink to ${ghcli_dir}/bin/gh ..."
    ln -fs "${ghcli_dir}/bin/gh" "$_LOCAL/bin/gh"
}

smoke_test() {
    #: Smoke-test the new installation

    log debug "Running a smoke test ..."
    if gh --version; then
        log info "Smoke test passed OK. (gh --version)"
    else
        log error "Smoke test FAILED! Please check the logs."
        exit 56
    fi
}

instruct_user() {
    cat << EOS

Completed. You can use github cli instantly, like:

  $ gh --help

EOS
}

doit() {
    log debug "Installing ghcli version=[$version]"
    download_tarball skip-if-exists
    # check_hashsum
    extract_into_opt
    create_symlink
    smoke_test
    instruct_user
    log info 'SUCCESS.'
}

undo() {
    log warn "UNinstalling github-cli version=[$version]"

    log info "Removing symlink $_LOCAL/bin/gh ..."
    rm "$_LOCAL/bin/gh"

    log info "Removing directory ${ghcli_dir} ..."
    rm -r "${ghcli_dir}"

    log info 'UNinstallation ended.'
}

doit
