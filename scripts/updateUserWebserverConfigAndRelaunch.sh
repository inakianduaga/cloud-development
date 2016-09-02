#!/bin/bash
#
# Script to update the webserver config for a user and hot-reload the container using the new settings
#
# Params:
#   USERS_PATH (filepath of sandbox users definitions)
#   CONFIG_PATH (filepath of sandbox general config)
#   USER  (must match one of the users in the config)
#   DOCKER_IMAGE
#   PORT
#   VOLUME
#   DOCKER_CMD_EXTRAS
#

set -eo pipefail

# Switch to current script's folder
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASE_DIR


# Read CLI parameters
USERS_PATH=$1
CONFIG_PATH=$2
USER=$3;
DOCKER_IMAGE=$4;
PORT=$5;
VOLUME=$6;
DOCKER_CMD_EXTRAS=$7


# Retrieve helper classes

USER_METHODS=$BASE_DIR/user_config.sh
CONTAINER_METHODS=$BASE_DIR/containers.sh

source $USER_METHODS
source $CONTAINER_METHODS

# Update Config

$(setUserWebserver $USER $DOCKER_IMAGE)
$(setUserWebserverPort $USER $PORT)
$(setUserWebserverVolume $USER $VOLUME)
$(setUserWebserverDockerCMDExtras $USER "$DOCKER_CMD_EXTRAS")


# Relaunch server

$(refreshWebserverFromConfigForUser $USER)