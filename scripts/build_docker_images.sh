#!/bin/bash
#
# Build required docker images to run the cloud development environment
# The webserver images need to be build manually, and tagged  matching the user config file

printf "----------------------------------"
printf "Building docker images..."
printf "----------------------------------"

docker build -t cloud-frontend-proxy ./../docker/frontend-proxy/
docker build -t cloud-authentication ./../docker/doorman-auth/

