#!/bin/bash
#
# Generates the nginx virtual hosts configuration to redirect requests to the proper container
#
# Convention:
#
# - Each user has *4* containers allocated
# - the starting port for *id = 1* is *$CLOUD_STARTING_PORT*
#

VIRTUAL_HOSTS_TEMPLATE_CONF='/etc/nginx/directives/virtual_host_template.conf'
USER_PREFIX='USER_'
BASE_HOSTNAME=${BASE_HOSTNAME:-localhost}
FRONTEND_PROXY_VHOSTS_CONVERT_UNDERSCORE_TO_HYPENS=${FRONTEND_PROXY_VHOSTS_CONVERT_UNDERSCORE_TO_HYPENS:-false}

if [ -z $PROXY_HOST ]; then
    PROXY_HOST=`/sbin/ip route|awk '/default/ { print $3 }'`
fi

# Maps a user id to the editor auth container port
# @param int id
# @return integer
function mapUserIdToStartingContainerPort()
{
  local starting_port=$CLOUD_STARTING_PORT
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

# Returns the vhosts template populated with the input variables
function populateTemplate()
{
    #Read arguments
    local USER_PLACEHOLDER=$1
    local APP_PLACEHOLDER=$2
    local BASE_HOSTNAME_PLACEHOLDER=$3
    local PROXY_HOST_PLACEHOLDER=$4
    local PROXY_PORT_PLACEHOLDER=$5

    local TEMPLATE=$(<$VIRTUAL_HOSTS_TEMPLATE_CONF)

    # Optionally map underscores to hyphens on vhost
    if [ "$FRONTEND_PROXY_VHOSTS_CONVERT_UNDERSCORE_TO_HYPENS" = true ] ; then
       USER_PLACEHOLDER=${USER_PLACEHOLDER//_/-}
    fi

    # Replace placeholders
    TEMPLATE=${TEMPLATE/USER_PLACEHOLDER/$USER_PLACEHOLDER}
    TEMPLATE=${TEMPLATE/APP_PLACEHOLDER/$APP_PLACEHOLDER}
    TEMPLATE=${TEMPLATE/BASE_HOSTNAME_PLACEHOLDER/$BASE_HOSTNAME_PLACEHOLDER}
    TEMPLATE=${TEMPLATE/PROXY_HOST_PLACEHOLDER/$PROXY_HOST_PLACEHOLDER}
    TEMPLATE=${TEMPLATE/PROXY_PORT_PLACEHOLDER/$PROXY_PORT_PLACEHOLDER}

    echo "$TEMPLATE"
}

# Get the list of all users, based on prefix
USERS=$(printenv | grep "$USER_PREFIX")

# Loop over all users
# http://stackoverflow.com/questions/11655770/bash-scripting-looping-through-a-environmental-variable-path-list
for p in ${USERS///$'\n'} ; do

  #http://stackoverflow.com/questions/10638538/split-string-with-bash-with-symbol
  IFS== read PREFIXED_USER ID <<< $p;

  # Useful variables
  USER=${PREFIXED_USER#$USER_PREFIX}
  USER=${USER,,} # to lowercase
  AUTHENTICATION_EDITOR_PORT=$(getAuthenticationEditorPortByUserId $ID)
  AUTHENTICATION_WEBSERVER_PORT=$(getAuthenticationWebserverPortByUserId $ID)

  # Bind to all authentication proxies
  echo "$(populateTemplate $USER "$SUBDOMAIN_EDITOR_STRING" $BASE_HOSTNAME $PROXY_HOST $AUTHENTICATION_EDITOR_PORT)"
  echo "$(populateTemplate $USER "$SUBDOMAIN_WEBSERVER_STRING" $BASE_HOSTNAME $PROXY_HOST $AUTHENTICATION_WEBSERVER_PORT)"

done