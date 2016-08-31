#!/bin/bash
#
# Launch docker containers
#
# ENV variables used: BASE_PATH USERS_PATH CONFIG_PATH USERS_UTIL_PATH FRONTEND_PROXY_CERTIFICATES_PATH $CONTAINERS_UTIL_PATH
#

#===================================================
# Read environment / config
#===================================================

# Action to perform (start|stop, defaults to start)
ACTION=${1:-start}

# Mode with which we launch containers (direct|upstart, defaults to direct)
MODE=${2:-direct}

# Import user/container helper methods
source $USERS_UTIL_PATH
source $CONTAINERS_UTIL_PATH

# Derived variables
BASE_HOSTNAME=$(getConfigKey BASE_HOSTNAME)
FRONTEND_PROXY_DOCKER_CMD_EXTRAS=$(getConfigKey FRONTEND_PROXY_DOCKER_CMD_EXTRAS)
DOCKER_INTERFACE=$(ip route | awk '/docker0/ { print $NF }')

#===================================================
# Loop over user containers
#===================================================

#
# Start/stop frontend proxy
#
launchFrontendProxy "$FRONTEND_PROXY_CERTIFICATES_PATH" "$CONFIG_PATH" "$FRONTEND_PROXY_DOCKER_CMD_EXTRAS" "$USERS_PATH" "$DOCKER_INTERFACE"

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
    launchWebserver "$webserver_container_port" "$webserver_port" "$webserver_container_repo_path" "$webserver_volume" "$webserver_docker_run_extras" "$webserver_container_name" "$webserver_type" "$DOCKER_INTERFACE"

    # start/stop user webserver authentication container
    launchAuthentication "$authentication_container_webserver_port" "$authentication_container_config_path" "$DOCKER_INTERFACE" "$webserver_container_port" "$authentication_container_name" "$DOCKER_INTERFACE"
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
    launchEditor "$editor_container_port" "$editor_port" "$editor_container_repo_path" "$editor_volume" "$editor_docker_run_extras" "$editor_container_name" "$editor_type" "$DOCKER_INTERFACE"

    # start/stop user editor authentication container
    launchAuthentication "$authentication_container_editor_port" "$authentication_container_config_path" "$DOCKER_INTERFACE" "$editor_container_port" "$authentication_container_name" "$DOCKER_INTERFACE"
  fi

done