#! /bin/sh

# Assumming lib/libma.sh has been sourced already.

link_path="$_LOCAL/bin/python"


set_python_as_link() {
    #: Make binary python available as a link to python3:
    into_dir_do "$_LOCAL/bin" 'ln -s "$(which python3)" python'
    # TODO: depending on 'which' - not ideal, think on replacement
    log info "Created symlink 'python' to $(which python3)"
}

smoke_test() {
    python -V || die "Creating python as link to python3 FAILED."
    log info "Smoke test OK. (python -V)"
}

doit() {
    skip_msg="'python' executable found, skip linking."
    python -V 2>/dev/null && log info "$skip_msg" || set_python_as_link
    smoke_test
}

undo() {
    if ! [ -e "${link_path}" ]; then
        log warn "Link '~/.local/bin/python' python3 not there, skipping."
    else
        log info "Removing '~/.local/bin/python' link to python3..."
        rm "${link_path}"
        [ -e "${link_path}" ] && die 14 "Removing ${link_path} FAILED!"
    fi
}

$mash_action
