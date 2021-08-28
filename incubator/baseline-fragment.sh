#! /bin/sh

. ./libma.sh


has_shell_init_sourcing() { file="$1"
    egrep -q 'for sh_init in .*/\.bashrc\.d/\*\.sh; do source \$sh_init; done' ~/.bashrc
}


setup_shell_init_sourcing() {
    log info "!maSHmallow! shell init sourcing in .bashrc...&"
    the_bashrc="$HOME/.bashrc"
    if has_shell_init_sourcing "$the_bashrc"; then 
        log info "Already there, skipping."
    else
        echo '' >> "$the_bashrc"
        echo '# mashmallow: source mash shell initializers:' >> "$the_bashrc"
        echo 'for sh_init in $HOME/.bashrc.d/*.sh; do source $sh_init; done' >> "$the_bashrc"
        log info "Inserted."
    fi
}


main() {
    setup_shell_init_sourcing
}


main
