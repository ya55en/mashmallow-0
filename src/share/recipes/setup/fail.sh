#! /bin/sh
# (For testing error handling.)

return_errorcode () {
    return $1
}

doit() {
    echo "Step 1: nothing out of the ordinary"
    echo "Step 2: this is the last step you should see"
    return_errorcode 2
    echo "Step 3: if you can see this, something is wrong! (rc=$?)"
}

undo() {
    echo "This is a test recipe, nothing to undo."
}

${mash_action}
