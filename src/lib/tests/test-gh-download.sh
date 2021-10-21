#! /bin/sh

#. "$MASH_HOME/lib/sys.sh"

import mashrc
import unittest/assert
import gh-download

wishful_api() {
    local project_path='bitwarden/desktop'
    version=$(gh_latest_version $project_path)
    gh_download "$project_path" "$version" "$app_file" "$download_loc"
    # then install appimage
}

test_gh_latest_raw_version() {
    assert_equal "$(gh_latest_raw_version 'bitwarden/desktop')" 'v1.28.3'
}

test_gh_latest_version() {
    assert_equal "$(gh_latest_version 'ya55en/mashmallow-0')" '0.0.6'
}

test_gh_latest_version_vscodium() {
    assert_equal "$(gh_latest_version 'VSCodium/vscodium')" '1.61.2'
}

test_gh_download() {
    local download_cache=/tmp
    local target_file

    # https://github.com/ya55en/mashmallow-0/releases/download/v0.0.1/mash-v0.0.1.tgz
    target_file="${_DOWNLOAD_CACHE}/mash-v0.0.1.tgz"
    rm -f "$target_file"
    gh_download 'ya55en/mashmallow-0' '0.0.1' 'mash-v0.0.1.tgz'
    assert_true [ -e "$target_file" ]

    download_cache=/tmp
    target_file="${download_cache}/mash-v0.0.1.tgz"
    rm -f "$target_file"
    gh_download 'ya55en/mashmallow-0' '0.0.1' 'mash-v0.0.1.tgz' "$download_cache"
    assert_true [ -e "${target_file}" ]
}
