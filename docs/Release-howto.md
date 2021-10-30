# `ma'shmallow-0` Release Howto

## Versioning

`ma'shmallow-0` follows the "Semantic Versioning 2.0.0" spec.

Each release version is in the form `major.minor.patch`, for
example: `1.2.0`.

_Unreleased builds_ are versioned `major.minon.patch-hash` where
`hash` is a string composed of the first 5 characters of the git
commit sha1 hash. Example: `1.2.0-4c68d`

## Tagging

The release commit is tagged with a lightweight git tag composed
of the release version prefixed with 'v', like `v1.2.0`.

The release commit contains the tag of the next release stored in
`./next-tag`. Thus, the build procedure for the dist tarball tries
to obtain the tag for the build from the commit message, and if not
found, uses the value in `./next-tag`, forming an _unreleased build
version_ string (see above).

### Why `./next-tag`?

Why `./next-tag` and not simply use `$(git tag | head -1)`?

We cannot use the git tag as it may not be there (e.g. on shallow
clones as with Github CI); also preliminary releases need to use the
next release tag, which is not present within git tags.


## How to make a new release

1. Bump the next-tag (set the tag of the next release planned).

2. Make a commit with a text including the current release version,
   e.g.: "Release v1.2.0 - Some new functionality added"

3. Proceed as per `make show-release` instructions.
