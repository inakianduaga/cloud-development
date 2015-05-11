#!/bin/bash

#
# Launch docker containers
#
# ENV variables used: BASE_PATH USERS_PATH CONFIG_PATH USERS_UTIL_PATH FRONTEND_PROXY_CERTIFICATES_PATH
echo $BASE_PATH
echo $USERS_PATH
echo $CONFIG_PATH
echo $USERS_UTIL_PATH

# Action to perform (start|stop, defaults to start)
ACTION=${1:-start}

# Import utils
source $USERS_UTIL_PATH

# Derived variables
BASE_HOSTNAME=$(getConfigKey BASE_HOSTNAME)
DOCKER_INTERFACE=$(ip route | awk '/docker0/ { print $NF }')

#
# Start/stop frontend proxy
#
$ACTION cloud_frontend_proxy CERTIFICATES_PATH=$FRONTEND_PROXY_CERTIFICATES_PATH BASE_HOSTNAME=$BASE_HOSTNAME USERS_CONFIG_PATH=$USERS_PATH PROXY_HOST=$DOCKER_INTERFACE

#
# Loop over all users
#
USERS="$(getUsers)"
for p in ${USERS///$'\n'} ; do

  #http://stackoverflow.com/questions/10638538/split-string-with-bash-with-symbol
  IFS== read PREFIXED_USER ID <<< "$p";

  # Useful variables
  USER=${PREFIXED_USER#"USER_"}
  USER=${USER,,} # to lowercase

  # Lauch authentication / webserver container pair
  if [ ! -z $(getUserWebserver $USER) ]; then

    # Webserver config
    webserver_container_name=$(getWebserverContainerNameByUser $USER)
    webserver_container_port=$(getWebserverPortByUserId $ID)
    webserver_container_repo_path="$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/repo/"
    webserver_type=$(getUserWebserver $USER)
    webserver_port=$(getUserWebserverPort $USER)
    webserver_volume=$(getUserWebserverVolume $USER)
    webserver_docker_run_extras=$(getUserWebserverDockerCMDExtras $USER)

    # Authentication server config
    authentication_container_name=$(getWebserverAuthenticationContainerNameByUser $USER)
    authentication_container_webserver_port=$(getAuthenticationWebserverPortByUserId $ID)
    authentication_container_config_path="$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/conf/authentication"

    # start/stop user webserver container
    $ACTION cloud_webserver CONTAINER_PORT=$webserver_container_port PORT=$webserver_port CONTAINER_REPO_PATH=$webserver_container_repo_path VOLUME=$webserver_volume DOCKER_RUN_EXTRAS=$webserver_docker_run_extras CONTAINER_NAME=$webserver_container_name TYPE=$webserver_type

    # start/stop user webserver authentication container
    $ACTION cloud_authentication CONTAINER_PORT=$authentication_container_webserver_port AUTHENTICATION_CONFIG_PATH=$authentication_container_config_path PROXY_HOST=$DOCKER_INTERFACE PROXY_PORT=$webserver_container_port CONTAINER_NAME=$authentication_container_name
  fi

  # Lauch authentication / editor container pair
  if [ ! -z $(getUserEditor $USER) ]; then

    # Editor config
    editor_container_name=$(getEditorContainerNameByUser $USER)
    editor_container_port=$(getEditorPortByUserId $ID)
    editor_container_repo_path="$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/repo/"
    editor_type=$(getUserEditor $USER)
    editor_port=$(getUserEditorPort $USER)
    editor_volume=$(getUserEditorVolume $USER)
    editor_docker_run_extras=$(getUserEditorDockerCMDExtras $USER)

    # Authentication server config
    authentication_container_name=$(getEditorAuthenticationContainerNameByUser $USER)
    authentication_container_editor_port=$(getAuthenticationEditorPortByUserId $ID)
    authentication_container_config_path="$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/conf/authentication"

    # start/stop user editor container
    $ACTION cloud_editor CONTAINER_PORT=$editor_container_port PORT=$editor_port CONTAINER_REPO_PATH=$editor_container_repo_path VOLUME=$editor_volume DOCKER_RUN_EXTRAS=$editor_docker_run_extras CONTAINER_NAME=$editor_container_name TYPE=$editor_type

    # start/stop user editor authentication container
    $ACTION cloud_authentication CONTAINER_PORT=$authentication_container_editor_port AUTHENTICATION_CONFIG_PATH=$authentication_container_config_path PROXY_HOST=$DOCKER_INTERFACE PROXY_PORT=$editor_container_port CONTAINER_NAME=$authentication_container_name

  fi

done