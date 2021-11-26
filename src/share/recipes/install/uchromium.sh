#!/bin/sh

#: Install ungoogled chromium + chromedriver
#: Base repo: https://github.com/macchrome/linchrome/
#: See also https://chromium.woolyss.com/#linux
#: Related links:
#:  - https://github.com/Eloston/ungoogled-chromium/
#:  - https://github.com/ungoogled-software/ungoogled-chromium-portablelinux
#:  - https://ungoogled-software.github.io/ungoogled-chromium-binaries/
#: Also a related source (but points to a googled chromium and also
#: very hard to discover the latest stable):
#:  - https://www.chromium.org/getting-involved/download-chromium

import logging
import gh-download

download_tarball() {
    #: Download shellcheck tarball into download_cache_dir

    _debug "raw version=[$raw_version]"
    _debug "version=[$version]"
    [ -n "$version" ] || {
        die 3 "Failed to get ${project_path} latest version"
    }
    _info "Downloading ${project_path}, v${version} ..."
    gh_download "$project_path" "$raw_version" "$app_file"
}

check_hashsum() {
    # TODO: implement
    :
}

#: Extract the shellcheck tarball into ~/.local/opt/.
extract_into_opt() {
    if [ -e "${app_main_dir}" ]; then
        _warn "The target directory already exists, skipping ($app_main_dir)."
        _warn "(If you still want to install, please remove it manually.)"
        return 0
    fi
    _info "Extracting ${download_target} ..."
    mkdir -p "${app_main_dir}"
    tar xf "${download_target}" -C "${app_main_dir}" ||
        die $? "Extracting ${download_target} FAILED (rc=$?)"
    [ -d "${app_main_dir}" ] || die 2 "chromium directory NOT found: ${app_main_dir}"
}

create_symlink() {
    #: Create symlink to the shellcheck executable.
    if [ -e "${app_main_dir}/current" ]; then
        _warn "Symlink already exists, skipping (${app_main_dir}/current)"
    else
        _info "Creating symlink to ${app_main_dir}/$app_basename ..."
        into_dir_do "${app_main_dir}" "ln -s $app_basename current"
    fi
}

#: Create an add-to-path script in ~/.bashrc.d/
create_bashrcd_script() {
    local linked_dir="${app_main_dir}/current"
    local script_name='52-uchromium-path.sh'

    [ -e "$linked_dir" ] || die 33 "linked directory NOT found: [$linked_dir]"
    _info "Creating env-setup script ~/.bashrc.d/$script_name ..."
    cat > "$HOME/.bashrc.d/$script_name" << EOS
# ~/.bashrc.d/$script_name - mash: add ungoogled chromium dir to PATH

_UCHROMIUM_DIR='${linked_dir}'
echo \$PATH | grep -q "\$_UCHROMIUM_DIR" || PATH="\$_UCHROMIUM_DIR:\$PATH"

EOS

    . "$HOME/.bashrc.d/$script_name"
}

smoke_test() {
    _debug "Running a smoke test ..."
    if chromedriver --version && chrome --version; then
        _info "Smoke test passed OK. (chrome --version)"
    else
        _error "Smoke test FAILED! Please check the logs."
        exit 56
    fi
}

instruct_user() {
    _info 'SUCCESS!'
    _warn 'You need to **close and reopen** all your terminals now.'
    _warn 'Then you will be able to use chrome and chromedriver, like:'
    cat << EOS

  $ chromedriver --help

EOS
}

doit() {
    _debug "Installing ungoogled chromium version=[$version]"
    download_tarball
    check_hashsum
    extract_into_opt
    create_symlink
    create_bashrcd_script
    smoke_test
    instruct_user
}

undo() {
    _error "Undo install ungoogled chromium NOT supported yet, apologies."
}

main() {
    local raw_version
    local version
    local app_file
    local app_basename
    local app_main_dir
    local download_target
    local project_path='macchrome/linchrome'

    # TODO: check os info and fail of not Linux x64

    # Sample archive filename: ungoogled-chromium_96.0.4664.45_1.vaapi_linux.tar.xz
    raw_version="$(gh_latest_raw_version $project_path)"
    _debug "raw_version=[$raw_version]"
    version="${raw_version%%-*}" # remove everything after the dash
    version="${version#v*}"      # remove the leading 'v'
    app_basename="ungoogled-chromium_${version}_1.vaapi_linux"
    app_file_ext='tar.xz'
    app_file="${app_basename}.${app_file_ext}"
    _debug "app_file=[$app_file]"
    app_main_dir="${_LOCAL}/opt/ungoogled-chromium"
    download_target="${_DOWNLOAD_CACHE}/${app_file}"

    $mash_action
}

main
