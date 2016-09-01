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
# Updates the user config file property
#
# @param string PROPERTY
# @param string VALUE
#
# @link http://stackoverflow.com/questions/8822097/how-to-replace-whole-line-with-sed
#
function setUserConfigProperty()
{
    #Read arguments
    local PROPERTY=$1
    local VALUE=$2

    sed -i "/^${PROPERTY}=/c${PROPERTY}=${VALUE}" $USERS_PATH
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
# Updates config's webserver for a given user
#
# @param string USER
# @param string VALUE
#
function setUserWebserver()
{
    #Read arguments
    local USER=$1
    local VALUE=$2

    setUserConfigProperty WEBSERVER_${USER} $VALUE
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
# Updates config's webserver port for a given user
#
# @param string USER
# @param string VALUE
#
function setUserWebserverPort()
{
    #Read arguments
    local USER=$1
    local VALUE=$2

    setUserConfigProperty WEBSERVER_${USER}_PORT $VALUE
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
# Updates config's webserver volume for a given user
#
# @param string USER
# @param string VALUE
#
function setUserWebserverVolume()
{
    #Read arguments
    local USER=$1
    local VALUE=$2

    setUserConfigProperty WEBSERVER_${USER}_VOLUME "$VALUE"
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
# Updates config's webserver docker cmd extras for a given user
#
# @param string USER
# @param string VALUE
#
function setUserWebserverDockerCMDExtras()
{
    #Read arguments
    local USER=$1
    local VALUE=$2

    setUserConfigProperty WEBSERVER_${USER}_DOCKER_CMD_EXTRAS "'$VALUE'"
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
# The editor bind port for a given user
# @param string user
# @return int
#
function getUserEditorPort()
{
  echo $(getUserConfigProperty EDITOR_${1^^}_PORT)
}

#
# The editor volume mount point for a given user
# @param string user
# @return string
#
function getUserEditorVolume()
{
  echo $(getUserConfigProperty EDITOR_${1^^}_VOLUME)
}

#
# The editor docker run command extras for a given user
# @param string user
# @return string
#
function getUserEditorDockerCMDExtras()
{
  echo $(getUserConfigProperty EDITOR_${1^^}_DOCKER_CMD_EXTRAS)
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