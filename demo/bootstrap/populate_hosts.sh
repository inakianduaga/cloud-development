#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - Need permissions to write to $HOSTS_PATH"
   exit 1
fi

HOSTS_PATH='/etc/hosts'
CONFIG_PATH='./../config/config'
USERS_PATH='./../config/users'

# Import utils
source ./../../scripts/user_config.sh

SUBDOMAIN_EDITOR_STRING=$(getConfigKey SUBDOMAIN_EDITOR_STRING)
SUBDOMAIN_WEBSERVER_STRING=$(getConfigKey SUBDOMAIN_WEBSERVER_STRING)

#
# Adds an entry to the hostnames file (if it's not already included)
# @param string hostname prefix
#
# http://stackoverflow.com/questions/3557037/appending-a-line-to-a-file-only-if-it-doesnt-already-exist-using-sed
#
function addHostEntryByPrefix()
{
  source $CONFIG_PATH
  line="127.0.0.1       ${1}.${BASE_HOSTNAME}"
  grep -q -F "$line" $HOSTS_PATH || echo "$line" >> $HOSTS_PATH
}

# Loop over all demo users
USERS="$(getUsers)"
for p in ${USERS///$'\n'} ; do

  #http://stackoverflow.com/questions/10638538/split-string-with-bash-with-symbol
  IFS== read PREFIXED_USER ID <<< "$p";

  # Useful variables
  USER=${PREFIXED_USER#"USER_"}
  USER=${USER,,} # to lowercase

  # Add webserver host entry
  if [ ! -z $(getUserWebserver $USER) ]; then
    $(addHostEntryByPrefix "${USER}.${SUBDOMAIN_WEBSERVER_STRING}")
  fi

  # Add editor host
  if [ ! -z $(getUserEditor $USER) ]; then
    $(addHostEntryByPrefix "${USER}.${SUBDOMAIN_EDITOR_STRING}")
  fi

done


