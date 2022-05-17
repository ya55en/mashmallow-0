#! /bin/sh

# https://launchpad.net/debian/+archive/primary/+sourcefiles/openssl/1.1.1o-1/openssl_1.1.1o.orig.tar.gz
# https://www.openssl.org/source/openssl-1.1.1o.tar.gz
# ./config shared no-ssl2 no-ssl3 enable-ec_nistp_64_gcc_128 --prefix=/home/yassen/.local/aux/openssl-1.1.sh --openssldir=/home/yassen/.local/aux/openssl-1.1.sh

import string

# TODO: Move to a generic library
# shellcheck disable=SC2039
generic_download() {
    local package_name="$1"
    local download_url="$2"
    local archive_filename="$3"
    local download_dir="${4:-$_DOWNLOAD_CACHE}"
    local download_path="$download_dir/$archive_filename"

    _debug "package_name=[$package_name]"
    _debug "download_url=[$download_url]"
    _debug "archive_filename=[$archive_filename]"
    _debug "download_dir=[$download_dir]"
    _debug "download_path=[$download_path]"

    if [ -e "$download_path" ]; then
        _warn "$PACKAGE_NAME tarball already downloaded/cached; skipping."
        _debug "Tarball exists: [$download_path]"
    else
        _info "Downloading $PACKAGE_NAME tarball ($DOWNLOAD_URL) ..."
        curl -fsSL "$DOWNLOAD_URL" -o "$download_path"
        _debug "Tarball downloaded to [$download_path]."
    fi
}

# TODO: Move to a generic library
extract_tar_archive() {
    # local _FUNCNAME=extract_tar_archive

    local archive_path="$1"
    local dest_dir="$2"
    local tar_strip_components=${3:-0}
    local on_dest_dir_exists="${4:-skip}" # one of: skip, fail, remove

    _debug "Archive path: [$archive_path]"
    _debug "Destination directory: [$dest_dir]"

    if [ -d "$dest_dir" ]; then
        case "$on_dest_dir_exists" in
        skip)
            _warn "Destination directory already exists:"
            _warn "  * path: $dest_dir"
            _warn "  * skipping extraction."
            return
            ;;
        fail)
            _fatal "Destination directory already exists:"
            _fatal "  * path: $dest_dir"
            _fatal "  * terminating."
            exit 5
            ;;
        remove)
            _warn "Destination directory already exists:"
            _warn "  * path: $dest_dir"
            _warn "  * REMOVING..."
            rm -r "$dest_dir"
            ;;
        *)
            _fatal "UNREACHABLE!! on_dest_dir_exists=[$on_dest_dir_exists]"
            exit 99
            ;;
        esac
    fi

    _debug "Creating destination dir $dest_dir ..."
    mkdir -p "$dest_dir"

    if [ "$tar_strip_components" -gt 0 ]; then
        strip_components_opt="--strip-components=$tar_strip_components"
    else
        strip_components_opt=
    fi

    if tar xf "$archive_path" "$strip_components_opt" -C "$dest_dir"; then
        _info "Archive extracted successfully."
    else
        _fatal "Archive extraction FAILED."
        exit 5
    fi
}

run_configure() {
    local OLD_CWD="$(pwd)"
    local CONFIG_OPTS='shared no-ssl2 no-ssl3 enable-ec_nistp_64_gcc_128'

    cd "$SOURCE_DIR" || die "UNEXPECTED: nonexistent $SOURCE_DIR"

    # shellcheck disable=SC2086
    ./config $CONFIG_OPTS --prefix="$INSTALL_DIR" --openssldir="$INSTALL_DIR"
    rc=$?

    cd "$OLD_CWD" || true

    # shellcheck disable=SC2181
    [ "$rc" = 0 ] || {
        _fatal "$PACKAGE_NAME ./configure FAILED."
        exit 5
    }
}

run_make() {
    cd "$SOURCE_DIR" || die "UNEXPECTED: nonexistent $SOURCE_DIR"

    _info "Running make ($((_CPU_COUNT - 1)) parallel jobs) ..."
    make -j"$((_CPU_COUNT - 1))" > "/tmp/$SHORT_NAME-$VERSION-build.log" 2>&1
    rc=$?

    cd "$OLD_CWD" || true

    # shellcheck disable=SC2181
    [ "$rc" = 0 ] || {
        _fatal "$PACKAGE_NAME make FAILED."
        _fatal "For details see /tmp/$SHORT_NAME-$VERSION-build.log"
        exit 5
    }
}

run_make_install() {
    cd "$SOURCE_DIR" || die "UNEXPECTED: nonexistent $SOURCE_DIR"

    # Run two custom target to skip the HUUUUGE docs install
    _info "Running make install_sw install_ssldirs ..."
    make install_sw install_ssldirs > "/tmp/$SHORT_NAME-$VERSION-install.log" 2>&1

    cd "$OLD_CWD" || true

    # shellcheck disable=SC2181
    [ "$rc" = 0 ] || {
        _fatal "$PACKAGE_NAME make install FAILED."
        _fatal "For details see /tmp/$SHORT_NAME-$VERSION-install.log"
        exit 5
    }
}

run_make_test() {
    cd "$SOURCE_DIR" || die "UNEXPECTED: nonexistent $SOURCE_DIR"

    # Run two custom target to skip the HUUUUGE docs install
    _info "Running make test (this *will* take a while) ..."
    make test > "/tmp/$SHORT_NAME-$VERSION-test.log" 2>&1

    cd "$OLD_CWD" || true

    # shellcheck disable=SC2181
    [ "$rc" = 0 ] || {
        _fatal "$PACKAGE_NAME make install FAILED."
        _fatal "For details see /tmp/$SHORT_NAME-$VERSION-test.log"
        exit 5
    }

    tail -n4 "/tmp/$SHORT_NAME-$VERSION-test.log"
    echo ''
}

smoke_test() {
    # shellcheck disable=SC2016
    # local cmd='LD_LIBRARY_PATH=$INSTALL_DIR/lib $INSTALL_DIR/bin/openssl version'

    if LD_LIBRARY_PATH="$INSTALL_DIR"/lib "$INSTALL_DIR"/bin/openssl version; then
        _info "$PACKAGE_NAME seems to have been built and working fine."
    else
        _fatal "Building $PACKAGE_NAME FAILED."
    fi
}

inform_user() {
    _info "SUCCESS. You have $SHORT_NAME $VERSION built and ready."
    _warn "Note that $PACKAGE_NAME executables and shared libs are NOT on your paths."
    _info "However, other recipes like 'ruby-4dev' would be able to link against it."
    _info "Also, you *can* set these to become part of the game -- paths locations are:"
    _info "  * $INSTALL_DIR/bin"
    _info "  * $INSTALL_DIR/lib"
    cat << EOS

Enjoy! ;)
EOS
}

doit() {
    _info "Preparing to build $SHORT_NAME $VERSION ..."
    generic_download "$PACKAGE_NAME" "$DOWNLOAD_URL" "$ARCHIVE_FILENAME" "$DOWNLOAD_DIR"
    extract_tar_archive "$DOWNLOAD_DIR/$ARCHIVE_FILENAME" "$SOURCE_DIR" "1"
    run_configure
    run_make
    run_make_install
    # run_make_test
    smoke_test
    inform_user
}

# shellcheck disable=SC2039
main() {
    # Prerequisites: gcc, make (possibly bison, autoconf?)

    # TODO: get the latest VERSION automagically [1]
    # https://www.openssl.org/source/openssl-1.1.1o.tar.gz

    # FIXME: needed only during development - suppress before commit!
    local _LOCAL="$HOME/.local"
    local DOWNLOAD_DIR="$_DOWNLOAD_CACHE"

    local SHORT_NAME='OpenSSL'
    local PACKAGE_NAME="${SHORT_NAME}-1.1"
    local VERSION='1.1.1o'
    local URL_PATH='www.openssl.org/source'
    local ARCHIVE_FILENAME="openssl-${VERSION}.tar.gz"
    local DOWNLOAD_URL="https://$URL_PATH/$ARCHIVE_FILENAME"

    local SOURCE_DIR="$_LOCAL/src/$(lower "$PACKAGE_NAME")"
    local INSTALL_DIR="$_LOCAL/lib/$(lower "$PACKAGE_NAME")"

    # shellcheck disable=SC2154
    $mash_action
}

main
