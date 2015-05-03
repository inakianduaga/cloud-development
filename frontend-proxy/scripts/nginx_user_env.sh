#!/bin/bash

#Generate an nginx environment file that includes container port mapping information for all users

USER_PREFIX='USER_'

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
  IFS== read USER ID <<< $p;

  echo "${USER}_EDITOR_PORT=$(mapUserIdToStartingContainerPort $ID)"
  echo "${USER}_WEBSERVER_PORT=$(( $(mapUserIdToStartingContainerPort $ID) + 2))"

done