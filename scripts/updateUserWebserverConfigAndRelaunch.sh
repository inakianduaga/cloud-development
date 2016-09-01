#!/bin/bash

set -eo pipefail

#
# Script to update the webserver config for a user and hot-reload the container using the new settings
#
# Params:
#   USER  (must match one of the users in the config)
#   DOCKER_IMAGE
#   PORT
#   VOLUME
#   DOCKER_CMD_EXTRAS
#

# Retrieve helper classes

USERS_PATH=././../config/users
CONFIG_PATH=././../config/config
USER_METHODS=./user_config.sh
CONTAINER_METHODS=./containers.sh

source $USER_METHODS
source $CONTAINER_METHODS


# Read CLI parameters

USER=$1;
DOCKER_IMAGE=$2;
PORT=$3;
VOLUME=$4;
DOCKER_CMD_EXTRAS=$5


# Update Config

$(setUserWebserver $USER $DOCKER_IMAGE)
$(setUserWebserverPort $USER $PORT)
$(setUserWebserverVolume $USER $VOLUME)
$(setUserWebserverDockerCMDExtras $USER $DOCKER_CMD_EXTRAS)


# Relaunch server

#$(refreshWebserverFromConfigForUser $USER)