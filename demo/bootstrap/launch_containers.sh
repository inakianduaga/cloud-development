#!/bin/bash

#
# Launch docker containers for each user
#

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CONFIG_PATH="${CURRENT_DIR}/../config/config"
USERS_PATH="${CURRENT_DIR}/../config/users"

# Import utils
source "${CURRENT_DIR}/../../scripts/user_config.sh"

function getDockerBridgeIp()
{
    echo $(ip route | awk '/docker0/ { print $NF }')
}

# Stop a docker container
function stopDockerContainer()
{
    docker stop $1 > /dev/null 2>&1
    docker rm $1 > /dev/null 2>&1
}


#
# Launch frontend proxy
#
cloud_frontend_proxy='cloud-frontend-proxy'
certs_path="${CURRENT_DIR}/../certificates"
base_hostname=$(getConfigKey BASE_HOSTNAME)
absolute_users_path="${CURRENT_DIR}/../config/users"
$(stopDockerContainer $cloud_frontend_proxy)
docker run -d -p 80:80 -p 443:443 -v $certs_path:/etc/nginx/certs -e BASE_HOSTNAME=$base_hostname --env-file $absolute_users_path -e PROXY_HOST=$(getDockerBridgeIp) --name $cloud_frontend_proxy $cloud_frontend_proxy


# Loop through each user, and for each launch 4 containers
#
# - Auth for webserver
# - webserver (of correct type)
# - Auth for editor
# - editor
#

# Loop over all demo users
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
    webserver_container_repo_path="${CURRENT_DIR}$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/repo/"
    webserver_type=$(getUserWebserver $USER)
    webserver_port=$(getUserWebserverPort $USER)
    webserver_volume=$(getUserWebserverVolume $USER)
    webserver_docker_run_extras=$(getUserWebserverDockerCMDExtras $USER)

    # Authentication server config
    authentication_container_name=$(getWebserverAuthenticationContainerNameByUser $USER)
    authentication_container_webserver_port=$(getAuthenticationWebserverPortByUserId $ID)
    authentication_container_config_path="${CURRENT_DIR}$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/conf/authentication"

    # Remove webserver container and relaunch
    $(stopDockerContainer $webserver_container_name)
    docker run -d -p $(getDockerBridgeIp):$webserver_container_port:$webserver_port -v $webserver_container_repo_path:$webserver_volume $webserver_docker_run_extras --name $webserver_container_name cloud-webserver-$webserver_type

    # Remove authentication container and relaunch
    $(stopDockerContainer $authentication_container_name)
    docker run -d -p $(getDockerBridgeIp):$authentication_container_webserver_port:8085 --env-file $authentication_container_config_path -e DOORMAN_PROXY_HOST=$(getDockerBridgeIp) -e DOORMAN_PROXY_PORT=$webserver_container_port --name $authentication_container_name cloud-authentication
  fi

  # Lauch authentication / editor container pair
  if [ ! -z $(getUserEditor $USER) ]; then

    # Editor config
    editor_container_name=$(getEditorContainerNameByUser $USER)
    editor_container_port=$(getEditorPortByUserId $ID)
    editor_container_repo_path="${CURRENT_DIR}$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/repo/"
    editor_type=$(getUserEditor $USER)
    editor_port=$(getUserEditorPort $USER)
    editor_volume=$(getUserEditorVolume $USER)
    editor_docker_run_extras=$(getUserEditorDockerCMDExtras $USER)

    # Authentication server config
    authentication_container_name=$(getEditorAuthenticationContainerNameByUser $USER)
    authentication_container_editor_port=$(getAuthenticationEditorPortByUserId $ID)
    authentication_container_config_path="${CURRENT_DIR}$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/conf/authentication"

    # Remove editor container and relaunch
    $(stopDockerContainer $editor_container_name)
    docker run -d -p $(getDockerBridgeIp):$editor_container_port:$editor_port -v $editor_container_repo_path:$editor_volume $editor_docker_run_extras --name $editor_container_name cloud-editor-$editor_type

    # Remove authentication container and relaunch
    $(stopDockerContainer $authentication_container_name)
    docker run -d -p $(getDockerBridgeIp):$authentication_container_editor_port:8085 --env-file $authentication_container_config_path -e DOORMAN_PROXY_HOST=$(getDockerBridgeIp) -e DOORMAN_PROXY_PORT=$editor_container_port --name $authentication_container_name cloud-authentication

  fi

done



