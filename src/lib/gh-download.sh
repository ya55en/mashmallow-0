#! /bin/sh
#: TODO: document (YD)
#: TODO: provide logging, possibly die()
#: TODO: import a logging library when we have it

import mashrc
import logging

_name_="$(basename "$0")"
_ghd_name_='gh-download.sh'

_ghd_gitgub_base_url='https://github.com/'

#: Print latest github release version on stdout.
gh_latest_raw_version() {
    local project_path="$1"

    local url_latest="${_ghd_gitgub_base_url}${project_path}/releases/latest"
    _debug "gh_latest_raw_version(): url_latest=[$url_latest]" >&2

    local url_download_re="^location: ${_ghd_gitgub_base_url}${project_path}/releases/tag/\(.*\)$"
    _debug "gh_latest_raw_version(): url_download_re=[$url_download_re]" >&2

    local raw_version
    raw_version=$(curl -ISs "$url_latest" | grep ^location | tr -d '\n\r' | sed "s|$url_download_re|\1|")
    printf '%s' "$raw_version"
}

# Not sure this is needed:
gh_latest_version() {
    local project_path="$1"
    local raw_version
    local version
    raw_version="$(gh_latest_raw_version $project_path)"
    version="${raw_version#v*}"
    printf '%s' "$version"
}

#: Download github release with given version.
gh_download() {
    #: Download the app image
    local project_path="$1"
    local raw_version="$2"
    local app_file="$3"
    local download_loc="${4:-$_DOWNLOAD_CACHE}"

    local download_url="${_ghd_gitgub_base_url}${project_path}/releases/download/${raw_version}/${app_file}"
    local download_target="${download_loc}/${app_file}"

    if [ -e "$download_target" ]; then
        _warn "File already downloaded ($download_target), skipping."
    else
        mkdir -p "${_DOWNLOAD_CACHE}"
        curl -sSL "$download_url" -o "${download_target}" || {
            _error "${project_path} download FAILED! (rc=$?)"
        }
    fi
}

if [ "$_name_" = "$_ghd_name_" ]; then
    _error "$_ghd_name_ is a library to be sourced, not executed."
fi
