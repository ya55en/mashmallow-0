#!/bin/sh

#: Print discovered version to stdout. The version is composed
#: of the latest git tag, duplicated in a file located at
#: `src/etc/next-tag`, and the first 7 characters of the latest
#: commit hash.  Example: 1.2.0-e6c5584
#: (See also 'docs/Release-howto.md'.)

# TODO: provide unit and e2e tests
# TODO: move to ../

version_regex='^.*v\([0-9]\+.[0-9]\+.[0-9]\+\).*$'

extract_from_message() {
    # local message='Release v 1.2.0 here'
    local message="$(git log -n1 --format=format:%s)"
    local version

    if expr "$message" : "$version_regex" > /dev/null; then
        version=$(echo "$message" | sed "s:$version_regex:\1:")
        echo "$version"
        return 0
    fi
    # else:
    return 1
}

dump_next_tag() {
    cat ./next-tag
}

main() {
    local tag="$(extract_from_message || dump_next_tag)"
    local hash="$(git log -n1 --format=format:%H)"
    printf '%s-%s\n' "$tag" "${hash%"${hash#???????}"}"
}

main
