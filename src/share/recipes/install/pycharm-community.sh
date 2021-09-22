#! /bin/sh

# pycharm-community.sh
# Install Pycharm Community edition

# Assumming lib/libma.sh has been sourced already.

# shellcheck disable=SC2034  # Used in sourced logging code
DEBUG=true # use DEBUG=false to suppress debugging

version='2021.2.2'
flavor='community'

pycharm_filename="pycharm-${flavor}-${version}.tar.gz"
pycharm_dir="$_LOCAL/opt/pycharm-${flavor}-${version}"
dot_desktop_file_src='com.jetbrains.pycharm-any.desktop'
dot_desktop_file_dst="com.jetbrains.pycharm-${flavor}.desktop"

_URL_DOWNLOAD="https://download-cdn.jetbrains.com/python/${pycharm_filename}"
_URL_HASHSUM="https://download-cdn.jetbrains.com/python/${pycharm_filename}.sha256"

download_tarball() {
    #: Download pycharm tarball into $_DOWNLOAD_CACHE
    skip="${1:-no-skip}"

    if [ "x$skip" = xskip-if-exists ] && [ -f "${_DOWNLOAD_CACHE}/${pycharm_filename}" ]; then
        log warn "File exits: ${_DOWNLOAD_CACHE}/${pycharm_filename}"
        log warn "Target archive already downloaded, skipping."
    else
        log debug "_URL_DOWNLOAD=$_URL_DOWNLOAD"
        log debug "_URL_DOWNLOAD=$_URL_HASHSUM"
        log debug "_DOWNLOAD_CACHE=$_DOWNLOAD_CACHE"
        log info "Downloading Pycharm ${flavor} edition, v${version}..."
        rm -f "${_DOWNLOAD_CACHE}/${pycharm_filename}"
        curl -sL "$_URL_DOWNLOAD" -o "${_DOWNLOAD_CACHE}/${pycharm_filename}" ||
            die 9 "Download failed. (URL: $_URL_DOWNLOAD)"
    fi
}

check_hashsum() {
    # TODO: check sha256 from $_URL_HASHSUM
    #   sha256sum -c pycharm-community-2021.2.2.tar.gz.sha256
    /bin/true
}

extract_into_opt() {
    #: Extract the pycharm tarball into ~/.local/opt/.

    log info "Extracting ${_DOWNLOAD_CACHE}/${pycharm_filename}..."
    tar xf "${_DOWNLOAD_CACHE}/${pycharm_filename}" -C "$_LOCAL/opt/" ||
        die $? "Extracting ${_DOWNLOAD_CACHE}/${pycharm_filename} FAILED (rc=$?)"
    [ -d "${pycharm_dir}/bin" ] || die 2 "Bin directory NOT found: ${pycharm_dir}/bin"
}

create_symlink() {
    #: Create a "pycharm-${flavor}" symlink in ~/.local/opt/ pointing
    #: to the pycharm installaton directory.

    # cwd="$(pwd)" && cd "${_LOCAL}/opt" && ln -fs "$(basename "${pycharm_dir}")" pycharm-${flavor} && cd "$cwd"
    # shellcheck disable=SC2016  # Need to pass this verbatim to into_dir_do()
    into_dir_do "${_LOCAL}/opt" 'ln -fs "$(basename "${pycharm_dir}")" pycharm-${flavor}'

    linked_dir="$_LOCAL/opt/pycharm-${flavor}"
    [ -L "${linked_dir}" ] || die 2 "Linked directory NOT found: ${linked_dir}"
    printf "%s" "$linked_dir"  # return value - do NOT alter
}

create_add_to_path_script() {
    #: Create an add-to-path script in ~/.bashrc.d/

    linked_dir="$1"
    cat > "$HOME/.bashrc.d/42-pycharm-${flavor}.sh" << EOS
# ~/.bashrc.d/42-pycharm-${flavor}.sh - mash: add pycharm bin to PATH

_LINKED_DIR='${linked_dir}'

echo \$PATH | grep -q "\${_LINKED_DIR}/bin" || PATH="\${_LINKED_DIR}/bin:\$PATH"

EOS
}

install_dot_desktop() {
    dot_desktop_fullpath="$_LOCAL/share/applications/${dot_desktop_file_dst}"
    if [ -e "${dot_desktop_fullpath}" ]; then
        log warn "Dot-desktop file exists, skipping. (${dot_desktop_fullpath})"
    else
        log info "Installing a dot-desktop file ... (${dot_desktop_fullpath})"
        # shellcheck disable=SC1090
        . "${_APPLICATIONS_DIR}/${dot_desktop_file_src}" > "${dot_desktop_fullpath}"
    fi
}

smoke_test() {
    #: Smoke-test the installation invoking 'printenv.py' from
    #: pycharm's bin/ directory.

    # shellcheck disable=SC1090
    . "$HOME/.bashrc.d/42-pycharm-${flavor}.sh"
    printenv.py /dev/null || die 9 "Smoke test running 'printenv.py' FAILED."
    log debug "Smoke Test: OK (printenv.py /dev/null)"
}

instruct_user() {
    cat << EOS

In order to have all your terminals know about the add-to-path change,
you need to:
  - EITHER source the add-top-path script (see below) in all open terminals,
  - OR log out, then log back in.

To source the add-to-path script, do (note the dot in front):

 $ . "~/.bashrc.d/42-pycharm-${flavor}.sh"

 Pycharm should be then accessible from anywhere on the command line,
 with:

  $ pycharm.sh

EOS
}

doit() {
    log debug "Installing pycharm version=[$version], flavor=${flavor}"
    download_tarball skip-if-exists
    check_hashsum
    extract_into_opt
    install_dot_desktop
    linked_dir="$(create_symlink)"
    create_add_to_path_script "$linked_dir"
    smoke_test
    instruct_user
    log info 'SUCCESS.'
}

undo() {
    log warn "UNinstalling pycharm version=[$version], flavor=${flavor}"

    log info "Removing $HOME/.bashrc.d/42-pycharm-${flavor}.sh..."
    rm "$HOME/.bashrc.d/42-pycharm-${flavor}.sh" ||
        log warn "Could NOT remove add-to-path file $HOME/.bashrc.d/42-pycharm-${flavor}.sh!"

    log info "Removing $_LOCAL/opt/pycharm-${flavor} symlink..."
    rm -f "$_LOCAL/opt/pycharm-${flavor}" ||
        log warn "Could NOT remove symlink $_LOCAL/opt/pycharm-${flavor}!"

    dot_desktop_fullpath="$_LOCAL/share/applications/${dot_desktop_file_dst}"
    log info "Removing dot-desktop ${dot_desktop_fullpath} ..."
    rm "${dot_desktop_fullpath}"

    log info "Removing $pycharm_dir..."
    rm -r "$pycharm_dir" ||
        log warn "Could NOT remove directory $pycharm_dir!"
    # TODO: remove the .desktop file
    cat << EOS

In order to have all your terminals know about the add-to-path change,
you need to close (and re-open) all open terminals, OR log out, then log
back in.

UN-installation ended.

EOS
}

$mash_action
