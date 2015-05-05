#!/bin/bash

#
# Launch docker containers for each user
#

CONFIG_PATH='./../config/config'
USERS_PATH=.'/../config/users'

# Import utils
source ./../../scripts/user_config.sh

function getDockerBridgeIp()
{
    echo $(ip route | awk '/docker0/ { print $NF }')
}

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
  IFS== read PREFIXED_USER ID <<< $p;

  # Useful variables
  USER=${PREFIXED_USER#"USER_"}
  USER=${USER,,} # to lowercase

  # Lauch authentication / webserver container pair
  if [ ! -z $(getUserWebserver $USER) ]; then

    # Webserver config
    webserver_container_name=$(getWebserverContainerNameByUser $USER)
    webserver_container_port=$(getWebserverPortByUserId $ID)
    webserver_container_repo_path="${PWD}$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/repo/"
    webserver_type=$(getUserWebserver $USER)
    webserver_port=$(getUserWebserverPort $USER)
    webserver_volume=$(getUserWebserverVolume $USER)
    webserver_docker_run_extras=$(getUserWebserverDockerCMDExtras $USER)

    # Authentication server config
    authentication_container_name=$(getWebserverAuthenticationContainerNameByUser $USER)
    authentication_container_webserver_port=$(getAuthenticationWebserverPortByUserId $ID)
    authentication_container_config_path="${PWD}$(getConfigKey BASE_CLOUD_USERS_FOLDER)${USER}/conf/authentication"

    # Remove webserver container and relaunch
    docker stop $webserver_container_name > /dev/null 2>&1;
    docker rm $webserver_container_name > /dev/null 2>&1
    docker run -d -p $webserver_container_port:$webserver_port -v $webserver_container_repo_path:$webserver_volume $webserver_docker_run_extras --name $webserver_container_name cloud-webserver-$webserver_type

    # Remove authentication container and relaunch
    docker stop $authentication_container_name > /dev/null 2>&1;
    docker rm $authentication_container_name > /dev/null 2>&1
    docker run -d -p $authentication_container_webserver_port:8085 --env-file $authentication_container_config_path -e DOORMAN_PROXY_HOST=$(getDockerBridgeIp) -e DOORMAN_PROXY_PORT=$webserver_container_port --name $authentication_container_name cloud-authentication
  fi

  # Lauch authentication / editor container pair
  if [ ! -z $(getUserEditor $USER) ]; then
    echo "TODO"
  fi

done

