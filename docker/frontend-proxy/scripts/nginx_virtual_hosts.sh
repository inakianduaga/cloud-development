#!/bin/bash

#
# Generates the nginx virtual hosts configuration to redirect requests to the proper container
#
# Convention:
#
# - Each user has *4* containers allocated
# - the starting port for *id = 1* is *8080*
#

USER_PREFIX='USER_'
SUBDOMAIN_EDITOR_STRING='edit'
SUBDOMAIN_WEBSERVER_STRING='view'
VIRTUAL_HOSTS_TEMPLATE_CONF='/etc/nginx/directives/virtual_host_template.conf'
BASE_HOSTNAME=${BASE_HOSTNAME:-localhost}
if [ -z $PROXY_HOST ]; then
    PROXY_HOST=`/sbin/ip route|awk '/default/ { print $3 }'`
fi

# Maps a user id to the editor auth container port
# @param int id
# @return integer
function mapUserIdToStartingContainerPort()
{
  echo $(( 8080 + 4 * ($1 - 1) ))
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
  AUTHENTICATION_EDITOR_PORT=$(( $(mapUserIdToStartingContainerPort $ID) + 1 ))
  AUTHENTICATION_WEBSERVER_PORT=$(( $(mapUserIdToStartingContainerPort $ID) + 3 ))

  # Bind to all authentication proxies
  echo "$(populateTemplate $USER $SUBDOMAIN_EDITOR_STRING $BASE_HOSTNAME $PROXY_HOST $AUTHENTICATION_EDITOR_PORT)"
  echo "$(populateTemplate $USER $SUBDOMAIN_WEBSERVER_STRING $BASE_HOSTNAME $PROXY_HOST $AUTHENTICATION_WEBSERVER_PORT)"

done