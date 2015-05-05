#!/bin/bash

#
# Utility class to retrieve user configuration & parameters
#
# $USER_PATH='/path/to/users_definition'
# $CONFIG_PATH='/path/to/configuration'
#

# Returns the list of users by reading the user list
function getUsers()
{
  source $USERS_PATH
  echo $(set -o posix ; set | grep "USER_")
}

function getUserConfigProperty()
{
  source $USERS_PATH
  echo ${!1}
}

#
# Returns the webserver for a given user
# @param string user
# @return string
#
function getUserWebserver()
{
  local user=${1^^}
  echo $(getUserConfigProperty WEBSERVER_${1^^})
}

#
# The webserver bind port for a given user
# @param string user
# @return int
#
function getUserWebserverPort()
{
  echo $(getUserConfigProperty WEBSERVER_${1^^}_PORT)
}

#
# The webserver volume mount point for a given user
# @param string user
# @return string
#
function getUserWebserverVolume()
{
  echo $(getUserConfigProperty WEBSERVER_${1^^}_VOLUME)
}

#
# The webserver docker run command extras for a given user
# @param string user
# @return string
#
function getUserWebserverDockerCMDExtras()
{
  echo $(getUserConfigProperty WEBSERVER_${1^^}_DOCKER_CMD_EXTRAS)
}

#
# Returns the editor for a given user
# @param string user
# @return string
#
function getUserEditor()
{
  echo $(getUserConfigProperty EDITOR_${1^^})
}

#
# Gets the starting port for the cloud containers
# @return string
#
function getCloudStartingPort()
{
  source $CONFIG_PATH
  echo $CLOUD_STARTING_PORT
}

#
# Gets a configuration key
# @param key
#
function getConfigKey()
{
  source $CONFIG_PATH
  echo ${!1}
}

# Maps a user id to the editor auth container port
# @param int id
# @return integer
function mapUserIdToStartingContainerPort()
{
  local starting_port=$(getConfigKey CLOUD_STARTING_PORT)
  echo $(( $starting_port + 4 * ($1 - 1) ))
}

#
# The webserver container port for a given user id
# @param int id
# @return int
#
function getWebserverPortByUserId()
{
  echo $(( $(mapUserIdToStartingContainerPort $1) + 2 ))
}

#
# The webserver authentication container port for a given user id
# @param int id
# @return int
#
function getAuthenticationWebserverPortByUserId()
{
  echo $(( $(mapUserIdToStartingContainerPort $1) + 3 ))
}

#
# The editor container port for a given user id
# @param int id
# @return int
#
function getEditorPortByUserId()
{
  echo $(mapUserIdToStartingContainerPort $1)
}

#
# The editor authentication container port for a given user id
# @param int id
# @return int
#
function getAuthenticationEditorPortByUserId()
{
  echo $(( $(mapUserIdToStartingContainerPort $1) + 1 ))
}

#
# The webserver container name for a given user
# @param string
# @return string
#
function getWebserverContainerNameByUser()
{
  echo "${1}_webserver"
}

#
# The webserver authentication container name for a given user
# @param string
# @return string
#
function getWebserverAuthenticationContainerNameByUser()
{
  echo "${1}_authentication_webserver"
}

#
# The editor container name for a given user
# @param string
# @return string
#
function getEditorContainerNameByUser()
{
  echo "${1}_editor"
}

#
# The editor authentication container name for a given user
# @param string
# @return string
#
function getEditorAuthenticationContainerNameByUser()
{
  echo "${1}_authentication_editor"
}