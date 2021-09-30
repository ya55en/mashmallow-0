#! /usr/bin/env -S python3 -B

"""
Parse the last git commit log section, like:

commit 7b5175a2fd4f0afa15cacd22fc0302aea79faf34 (HEAD -> main, tag: v0.0.2, origin/main, origin/HEAD)
Author: Yassen Damyanov <yd@itlabs.bg>
Date:   Mon Sep 20 18:15:43 2021 +0300

    Release v0.0.2

     - separate dist from release make target;
     - bump version in install.sh

"""

import sys
import re

regex = re.compile(r'v(\d+\.\d+\.[0-9a-z]+)')


def _main(argv: list) -> int:
    commit = None
    version = '9.8.7'  # fake number
    release_note = None

    after_version = False

    for line in sys.stdin:
        if line.startswith('commit'):
            commit = line.split()[1]

        match = regex.search(line)
        if match:
            version = match.group(1)
            release_note = line.strip()
            after_version = True

        if after_version:
            if line.strip() == "":
                break
            release_note = line.strip()


    result = f'''\
 $ # Make sure you have bumped version and committed with a message like:
 $ # Release v{version} - Improved docker-related recipes
 $ git tag v{version}
 $ make clean-dist && make dist
 $ git push && git push --tags
 $ gh release create v{version} --notes "{release_note} ({commit[:7]}, unofficial)" ./dist/mash-v{version}.tgz
'''

    print(result, end="")
    return 0


def main(argv: list) -> int:
    try:
        return _main(argv)
    except Exception as err:
        print(f'ERROR: {type(err)!s}: {err!s}')
        return 3


if __name__ == '__main__':
    sys.exit(main(sys.argv))
