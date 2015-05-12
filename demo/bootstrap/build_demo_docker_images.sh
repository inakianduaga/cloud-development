#!/bin/bash
#
# Build required docker images to run demo
#
printf "----------------------------------"
printf "Building required docker images..."
printf "----------------------------------"

#http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

docker build -t cloud-frontend-proxy ${CURRENT_DIR}/../../docker/frontend-proxy/
docker build -t cloud-editor-codebox ${CURRENT_DIR}/../../docker/codebox-ide/
docker build -t cloud-authentication ${CURRENT_DIR}/../../docker/doorman-auth/
docker build -t cloud-webserver-php ${CURRENT_DIR}/../webserver-php/
docker build -t cloud-webserver-nodejs ${CURRENT_DIR}/../webserver-nodejs/
