#! /bin/sh

. "$MASH_HOME/lib/sys.sh"

_name_="$(basename "$0")"
_tgd_name_='test-gh-download.sh'

import lib-4test
import gh-download
import mashrc

wishful_api() {
    local project_path='bitwarden/desktop'
    version=$(gh_latest_version $project_path)
    gh_download "$project_path" "$version" "$app_file" "$download_loc"
    # then install appimage
}

test_gh_latest_raw_version() {
    _curr_test_=test_gh_latest_raw_version
    # shellcheck disable=2003,2086
    no=$(expr $no + 1)

    assert_equal "$(gh_latest_raw_version 'bitwarden/desktop')" 'v1.28.3'

    print_pass
}

test_gh_latest_version() {
    _curr_test_=test_gh_latest_version
    # shellcheck disable=2003,2086
    no=$(expr $no + 1)

    assert_equal "$(gh_latest_version 'ya55en/mashmallow-0')" '0.0.6'

    print_pass
}

test_gh_latest_version_vscodium() {
    _curr_test_=test_gh_latest_version_vscodium
    # shellcheck disable=2003,2086
    no=$(expr $no + 1)

    assert_equal "$(gh_latest_version 'VSCodium/vscodium')" '1.61.1'

    print_pass
}

test_gh_download() {
    _curr_test_=test_gh_download
    # shellcheck disable=2003,2086
    no=$(expr $no + 1)
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

    print_pass
}

test() {
    set -e
    local no=0

    test_gh_latest_raw_version
    test_gh_latest_version
    test_gh_latest_version_vscodium
    test_gh_download
}

if [ "$_name_" = "$_tgd_name_" ]; then
    test
fi