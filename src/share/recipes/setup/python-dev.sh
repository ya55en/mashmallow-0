#! /bin/sh

# Assumming lib/libma.sh has been sourced already.

set_python_as_link() {
    #: Make binary python available as a link to python3:
    into_dir_do "$_LOCAL/bin" 'ln -s "$(which python3)" python'
    log info "Created symlink 'python' to $(which python3)"
}

skip_msg='python executable found, skipping'
python -V 2>/dev/null && log info "$skip_msg" || set_python_as_link

# smoke test:
python -V || die "Creating python as link to python3 FAILED."
