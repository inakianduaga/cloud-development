#!/bin/bash

#
# Launch docker containers
#
# ENV variables used: BASE_PATH USERS_PATH CONFIG_PATH USERS_UTIL_PATH FRONTEND_PROXY_CERTIFICATES_PATH

# Action to perform (start|stop, defaults to start)
ACTION=${1:-start}

# Import utils
source $USERS_UTIL_PATH

# Derived variables
BASE_HOSTNAME=$(getConfigKey BASE_HOSTNAME)
FRONTEND_PROXY_DOCKER_CMD_EXTRAS=$(getConfigKey FRONTEND_PROXY_DOCKER_CMD_EXTRAS)
# Encode potential whitespace since upstart doesn't accept whitespace in env variables
FRONTEND_PROXY_DOCKER_CMD_EXTRAS=${FRONTEND_PROXY_DOCKER_CMD_EXTRAS// /\*}
DOCKER_INTERFACE=$(ip route | awk '/docker0/ { print $NF }')

#
# Start/stop frontend proxy
#
$ACTION cloud_frontend_proxy CERTIFICATES_PATH=$FRONTEND_PROXY_CERTIFICATES_PATH CONFIG_PATH=$CONFIG_PATH USERS_CONFIG_PATH=$USERS_PATH PROXY_HOST=$DOCKER_INTERFACE DOCKER_RUN_EXTRAS=$FRONTEND_PROXY_DOCKER_CMD_EXTRAS

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
    # Encode potential whitespace since upstart doesn't accept whitespace in env variables
    webserver_docker_run_extras=${webserver_docker_run_extras// /\*}

    # Authentication server config
    authentication_container_name=$(getWebserverAuthenticationContainerNameByUser $USER)
    authentication_container_webserver_port=$(getAuthenticationWebserverPortByUserId $ID)
    authentication_container_config_path="$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/conf/authentication"

    # start/stop user webserver container
    $ACTION cloud_webserver CONTAINER_PORT=$webserver_container_port PORT=$webserver_port CONTAINER_REPO_PATH=$webserver_container_repo_path VOLUME=$webserver_volume DOCKER_RUN_EXTRAS=$webserver_docker_run_extras CONTAINER_NAME=$webserver_container_name TYPE=$webserver_type DOCKER_INTERFACE=$DOCKER_INTERFACE

    # start/stop user webserver authentication container
    $ACTION cloud_authentication CONTAINER_PORT=$authentication_container_webserver_port AUTHENTICATION_CONFIG_PATH=$authentication_container_config_path PROXY_HOST=$DOCKER_INTERFACE PROXY_PORT=$webserver_container_port CONTAINER_NAME=$authentication_container_name DOCKER_INTERFACE=$DOCKER_INTERFACE
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
    # Encode potential whitespace since upstart doesn't accept whitespace in env variables
    editor_docker_run_extras=${editor_docker_run_extras// /\*}


    # Authentication server config
    authentication_container_name=$(getEditorAuthenticationContainerNameByUser $USER)
    authentication_container_editor_port=$(getAuthenticationEditorPortByUserId $ID)
    authentication_container_config_path="$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/conf/authentication"

    # start/stop user editor container
    $ACTION cloud_editor CONTAINER_PORT=$editor_container_port PORT=$editor_port CONTAINER_REPO_PATH=$editor_container_repo_path VOLUME=$editor_volume DOCKER_RUN_EXTRAS=$editor_docker_run_extras CONTAINER_NAME=$editor_container_name TYPE=$editor_type DOCKER_INTERFACE=$DOCKER_INTERFACE

    # start/stop user editor authentication container
    $ACTION cloud_authentication CONTAINER_PORT=$authentication_container_editor_port AUTHENTICATION_CONFIG_PATH=$authentication_container_config_path PROXY_HOST=$DOCKER_INTERFACE PROXY_PORT=$editor_container_port CONTAINER_NAME=$authentication_container_name DOCKER_INTERFACE=$DOCKER_INTERFACE

  fi

done