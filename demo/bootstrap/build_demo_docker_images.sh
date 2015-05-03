#!/bin/bash
#
# Build required docker images to run demo
#
printf "----------------------------------"
printf "Building required docker images..."
printf "----------------------------------"

docker build -t cloud-frontend-proxy ./../../docker/frontend-proxy/
docker build -t cloud-editor ./../../docker/codebox-ide/
docker build -t cloud-authentication ./../../docker/doorman-auth/
docker build -t cloud-webserver-php ./../webserver-php/
docker build -t cloud-webserver-nodejs ./../webserver-nodejs/
