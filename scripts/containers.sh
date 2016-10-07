#!/bin/bash

#
# "Class" with useful methods for handling the user containers
#

#===================================================
# Useful methods
#===================================================

#
# "Escapes" the input characters by substituting them with plain strings
# This is because upstart doesn't seem to like certain characters in its env variables
#
# @param string
# @return string
#
function escapeSpecialChars()
{
  local escaped=${1// /\SPACE}
  escaped=${escaped//-/HYPHEN}
  escaped=${escaped//:/COLON}

  echo $escaped
}

#
# Removes a container of a given name
#
# @param string container name/id
#
function removeContainer()
{
    /usr/bin/docker stop $1 > /dev/null 2>&1
    /usr/bin/docker rm $1 > /dev/null 2>&1
}

#
# Launches the frontend proxy container
#
# @param CERTIFICATES_PATH
# @param CONFIG_PATH
# @param DOCKER_RUN_EXTRAS
# @param USERS_CONFIG_PATH
# @param PROXY_HOST
#
function launchFrontendProxy()
{
    #Read arguments
    local CERTIFICATES_PATH=$1
    local CONFIG_PATH=$2
    local DOCKER_RUN_EXTRAS=$3
    local USERS_CONFIG_PATH=$4
    local PROXY_HOST=$5

    # launch/stop container through direct/upstart call
    if [ $MODE = "direct" ] ; then
        $(removeContainer "cloud-frontend-proxy")
        if [ $ACTION = "start" ] ; then
            /usr/bin/docker run -d -p 80:80 -p 443:443 -v $CERTIFICATES_PATH:/etc/nginx/certs --env-file $CONFIG_PATH --env-file $USERS_CONFIG_PATH -e PROXY_HOST=$PROXY_HOST $DOCKER_RUN_EXTRAS --name cloud-frontend-proxy cloud-frontend-proxy
        fi
    else
        $ACTION cloud_frontend_proxy CERTIFICATES_PATH=$CERTIFICATES_PATH CONFIG_PATH=$CONFIG_PATH DOCKER_RUN_EXTRAS=$(escapeSpecialChars "$DOCKER_RUN_EXTRAS") USERS_CONFIG_PATH=$USERS_CONFIG_PATH PROXY_HOST=$PROXY_HOST
    fi
}

#
# Launches an authentication container
#
# @param CONTAINER_PORT
# @param AUTHENTICATION_CONFIG_PATH
# @param PROXY_HOST
# @param PROXY_PORT
# @param CONTAINER_NAME
# @param DOCKER_INTERFACE
#
function launchAuthentication()
{
    #Read arguments
    local CONTAINER_PORT=$1
    local AUTHENTICATION_CONFIG_PATH=$2
    local PROXY_HOST=$3
    local PROXY_PORT=$4
    local CONTAINER_NAME=$5
    local DOCKER_INTERFACE=$6

    # launch/stop container through direct/upstart call
    if [ $MODE = "direct" ] ; then
        $(removeContainer "$CONTAINER_NAME")
        if [ $ACTION = "start" ] ; then
            /usr/bin/docker run -d -p $DOCKER_INTERFACE:$CONTAINER_PORT:8085 --env-file $AUTHENTICATION_CONFIG_PATH -e DOORMAN_PROXY_HOST=$PROXY_HOST -e DOORMAN_PROXY_PORT=$PROXY_PORT --name $CONTAINER_NAME cloud-authentication
        fi
    else
        $ACTION cloud_authentication CONTAINER_PORT=$CONTAINER_PORT AUTHENTICATION_CONFIG_PATH=$AUTHENTICATION_CONFIG_PATH PROXY_HOST=$PROXY_HOST PROXY_PORT=$PROXY_PORT CONTAINER_NAME=$CONTAINER_NAME DOCKER_INTERFACE=$DOCKER_INTERFACE
    fi
}

#
# Launches an editor container
#
# @param CONTAINER_PORT
# @param PORT
# @param CONTAINER_REPO_PATH
# @param VOLUME
# @param DOCKER_RUN_EXTRAS
# @param CONTAINER_NAME
# @param TYPE
# @param DOCKER_INTERFACE
#
function launchEditor()
{
    #Read arguments
    local CONTAINER_PORT=$1
    local PORT=$2
    local CONTAINER_REPO_PATH=$3
    local VOLUME=$4
    local DOCKER_RUN_EXTRAS=$5
    local CONTAINER_NAME=$6
    local TYPE=$7
    local DOCKER_INTERFACE=$8

    # launch/stop container through direct/upstart call
    if [ $MODE = "direct" ] ; then
        $(removeContainer "$CONTAINER_NAME")
        if [ $ACTION = "start" ] ; then
            /usr/bin/docker run -d -p $DOCKER_INTERFACE:$CONTAINER_PORT:$PORT -v $CONTAINER_REPO_PATH:$VOLUME $DOCKER_RUN_EXTRAS --name $CONTAINER_NAME cloud-editor-$TYPE
        fi
    else
        $ACTION cloud_editor CONTAINER_PORT=$CONTAINER_PORT PORT=$PORT CONTAINER_REPO_PATH=$CONTAINER_REPO_PATH VOLUME=$VOLUME DOCKER_RUN_EXTRAS=$(escapeSpecialChars "$DOCKER_RUN_EXTRAS") CONTAINER_NAME=$CONTAINER_NAME TYPE=$TYPE DOCKER_INTERFACE=$DOCKER_INTERFACE
    fi
}

#
# Launches an webserver container
#
# @param CONTAINER_PORT
# @param PORT
# @param CONTAINER_REPO_PATH
# @param VOLUME
# @param DOCKER_RUN_EXTRAS
# @param CONTAINER_NAME
# @param TYPE
# @param DOCKER_INTERFACE
#
function launchWebserver()
{
    #Read arguments
    local CONTAINER_PORT=$1
    local PORT=$2
    local CONTAINER_REPO_PATH=$3
    local VOLUME=$4
    local DOCKER_RUN_EXTRAS=$5
    local CONTAINER_NAME=$6
    local TYPE=$7
    local DOCKER_INTERFACE=$8

    # launch/stop container through direct/upstart call
    if [ $MODE = "direct" ] ; then
        $(removeContainer "$CONTAINER_NAME") || true
        if [ $ACTION = "start" ] ; then
            /usr/bin/docker run -d -p $DOCKER_INTERFACE:$CONTAINER_PORT:$PORT -v $CONTAINER_REPO_PATH:$VOLUME $DOCKER_RUN_EXTRAS --name $CONTAINER_NAME $TYPE
        fi
    else
        $ACTION cloud_webserver CONTAINER_PORT=$CONTAINER_PORT PORT=$PORT CONTAINER_REPO_PATH=$CONTAINER_REPO_PATH VOLUME=$VOLUME DOCKER_RUN_EXTRAS=$(escapeSpecialChars "$DOCKER_RUN_EXTRAS") CONTAINER_NAME=$CONTAINER_NAME TYPE=$TYPE DOCKER_INTERFACE=$DOCKER_INTERFACE
    fi
}

#
# Kills and relaunches the webserver container associated to a user based on current configuration.
# Used for hot-reloading docker containers without needing to relaunch the entire sandbox
#
function refreshWebserverFromConfigForUser()
{
    local USER=${1,,}
    local MODE="direct"
    local ACTION="start"
    local DOCKER_INTERFACE=$(ip route | awk '/docker0/ { print $NF }')

    # Webserver config
    webserver_container_name=$(getWebserverContainerNameByUser $USER)
    webserver_container_port=$(getWebserverPortByUser $USER)
    webserver_container_repo_path="$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/repo/"
    webserver_type=$(getUserWebserver $USER)
    webserver_port=$(getUserWebserverPort $USER)
    webserver_volume=$(getUserWebserverVolume $USER)
    webserver_docker_run_extras=$(getUserWebserverDockerCMDExtras $USER)

    # start/stop user webserver container
    launchWebserver "$webserver_container_port" "$webserver_port" "$webserver_container_repo_path" "$webserver_volume" "$webserver_docker_run_extras" "$webserver_container_name" "$webserver_type" "$DOCKER_INTERFACE"
}