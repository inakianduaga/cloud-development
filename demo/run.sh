#!/bin/bash

#
# Bootstraps the demo environment
#

# Build required docker images
./bootstrap/build_demo_docker_images.sh

# Add hosts file entry for each user
./bootstrap/populate_hosts.sh

# Initialize containers for each user
./../scripts/launch_containers.sh