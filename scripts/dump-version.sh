#!/bin/sh

#: Print discovered version to stdout. The version is composed
#: of the latest git tag, duplicated in a file located at
#: `src/etc/next-tag`, and the first 7 characters of the latest
#: commit hash.  Example: 1.2.0-e6c5584
#: (See also 'docs/Release-howto.md'.)

# TODO: provide unit and e2e tests
# TODO: move to ../


extract_from_message() {
    # local message='Release v 1.2.0 here'
    local version_regex='^.*v\([0-9]\+.[0-9]\+.[0-9]\+\).*$'
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

truncated_hash() {
    local hash="$(git log -n1 --format=format:%H)"
    printf '%s' "${hash%"${hash#?????}"}"
}

main() {
    local tag
    local hash

    tag="$(extract_from_message)"
    if [ -n "$tag" ]; then
        # hash="-release"
        hash='' # we n
    else
        hash="-$(truncated_hash)"
        tag="$(cat ./next-tag || cat ../next-tag)"
    fi

    printf '%s%s\n' "$tag" "$hash"
}

main
