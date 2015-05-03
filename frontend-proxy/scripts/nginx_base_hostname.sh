#!/bin/bash
# Generates a file that can be included in the nginx configuration that sets the BASE_HOSTNAME variable
# defaults to `localhost` when not present

if [ -z $BASE_HOSTNAME ]; then
    BASE_HOSTNAME=localhost
fi

echo "set \$BASE_HOSTNAME ${BASE_HOSTNAME};"
