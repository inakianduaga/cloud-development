#!/bin/bash

#
# Generates the nginx proxy rules to redirect requests to the proper container
#
# We need this because we can't use much logic at all inside the nginx variables (unless we use lua modules)
#
# Convention:
#
# - Each user has *4* containers allocated
# - the starting port for *id = 1* is *8080*
#

USER_PREFIX='USER_'
SUBDOMAIN_EDITOR_STRING='edit'
SUBDOMAIN_WEBSERVER_STRING='view'

# Maps a user id to the editor auth container port
# @param int id
# @return integer
function mapUserIdToStartingContainerPort()
{
  echo $(( 8080 + 4 * ($1 - 1) ))
}

# Get the list of all users, based on prefix
USERS=$(printenv | grep "$USER_PREFIX")

# Loop over all users
# http://stackoverflow.com/questions/11655770/bash-scripting-looping-through-a-environmental-variable-path-list
for p in ${USERS///$'\n'} ; do

  #http://stackoverflow.com/questions/10638538/split-string-with-bash-with-symbol
  IFS== read PREFIXED_USER ID <<< $p;

  # Useful variables
  USER=${PREFIXED_USER#$USER_PREFIX}
  USER=${USER,,} # to lowercase
  EDITOR_PORT=$(mapUserIdToStartingContainerPort $ID)
  WEBSERVER_PORT=$(( $(mapUserIdToStartingContainerPort $ID) + 2))
  USER_EDITOR="${USER}_${SUBDOMAIN_EDITOR_STRING}"
  USER_WEBSERVER="${USER}_${SUBDOMAIN_WEBSERVER_STRING}"

  # Proxy redirect for the editor
  echo "if(\$userapp ~ "${USER_EDITOR}") {"
  echo "proxy_pass http://127.0.0.1:${EDITOR_PORT}\$uri\$is_args\$args;"
  echo "}"

  # Proxy redirect for the webserver
  echo "if(\$userapp ~ "${USER_WEBSERVER}") {"
  echo "proxy_pass http://127.0.0.1:${WEBSERVER_PORT}\$uri\$is_args\$args;"
  echo "}"

done