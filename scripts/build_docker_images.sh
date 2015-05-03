#!/bin/bash
#
# Build required docker images to run demo
# The webserver images need to be build manually, and tagged as `cloud-webserver-php`, `cloud-webserver-nodejs` etc, where
# the suffix needs to match the user config file
#
printf "----------------------------------"
printf "Building docker images..."
printf "----------------------------------"

docker build -t cloud-frontend-proxy ./../frontend-proxy/
docker build -t cloud-editor ./../codebox-ide/
docker build -t cloud-authentication ./../doorman-auth/

