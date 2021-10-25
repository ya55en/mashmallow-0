#! /bin/sh
# Non-executable: pathlib

import string

#: Return a relative part of given path $1 from given directory $2 to
#: the end of the path, stripping the part from the beginning to the
#: given directory.
relpath_from_dir() {
    local path="$1"
    local dir="$2"

    path="$(strip "$path")"
    dir="$(strip "$dir")"

    [ -z "$path" ] && {
        die 65 "Illegal (empty) path=[$path]"
        return 1
    }

    [ -z "$dir" ] && {
        die 66 "Illegal (empty) sub-dir segment dir=[$dir]"
        return 1
    }

    echo "$path" | sed "s:^.*/\?\($dir/\?.*$\):\1:"
}
