#! /bin/sh
# (Helps for experiments.)

doit() {
    echo "Hello, $USER! 'mash' seems working ;)"
}

undo() {
    echo "Farewell, $USER! 'mash undo' seems to work ;)"
}

${mash_action}
