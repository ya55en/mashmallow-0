#! /bin/sh

ensure_sudoer() {
    #: Notify the user we need sudo access and challenge the OS
    echo 'Installing vivaldi requires sudo access...'

    if ! /bin/sudo apt --version >/dev/null; then
        die 14 'NO sudo user; terminating.'
    else
        echo 'Got sudo access - good.'
    fi
}

download_deb() {
    if [ -e "$download_path" ]; then
        _warn "Vivaldi archive already downloaded/cached, skipping."
        _debug "Tarball exists: [$download_path]"
    else
        _info "Downloading vivaldi deb package ($download_url)..."
        curl -fsSL "$download_url" -o "$download_path"
        _debug "Tarball downloaded to [$download_path]."
    fi
}

check_hashsum() {
    # TODO: check hash sum, possibly signature
    true
}

apt_install_deb() {
    _info 'Installing vivaldi deb package...'
    sudo apt install "$download_path"
}

smoke_test() {
    if /usr/bin/vivaldi --version >/tmp/vivaldi-version; then
        _info "SUCCESS: $(cat /tmp/vivaldi-version) installed and operational."
    else
        _fail "Vivaldi NOT operational (reason unknown; refer to log files)."
    fi
}

doit() {
    ensure_sudoer
    download_deb
    check_hashsum
    apt_install_deb
    smoke_test
}

undo() {
    cat <<EOS

'undo install vivaldi' not yet implemented. We are sorry
for the inconvenience.

EOS
}

# For 'local' not defined see https://github.com/koalaman/shellcheck/wiki/SC3043
# (See also https://github.com/koalaman/shellcheck/issues/1727)
# shellcheck disable=SC2039
main() {
    # https://downloads.vivaldi.com/stable/vivaldi-stable_5.2.2623.46-1_amd64.deb
    local version
    local deb_file
    local download_url
    local download_path

    version='5.2.2623.46-1'
    deb_file="vivaldi-stable_${version}_${_OS_ARCH_SHORT}.deb"
    download_url="https://downloads.vivaldi.com/stable/${deb_file}"
    download_path="${_DOWNLOAD_CACHE}/${deb_file}"

    _debug "download_url=[$download_url]"
    _debug "download_path=[$download_path]"

    $mash_action
}

main
