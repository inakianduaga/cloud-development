#!/bin/bash

#
# Launch docker containers for each user
#
# TODO: Use upstart service to manage the containers
#

# Maps a user id to the editor auth container port
# @param int id
# @return integer
function mapUserIdToStartingContainerPort()
{
  echo $(( 8080 + 4 * ($1 - 1) ))
}

# Loop through each user, and for each launch 4 containers
#
# - Auth for webserver
# - webserver (of correct type)
# - Auth for editor
# - editor
#