Cloud development upstart scripts
=================================

> Upstart scripts to automatically start/restart the cloud development environment
> Tested on Ubuntu 14.04 ONLY.

All containers are launched through a master upstart job `cloudDevelopment.conf`

## Configuration

- Modify the `couldDevelopment.conf` env variables block to match the paths of your cloud-development configuration
- The `MODE` parameter specifies whether we use upstart to launch the containers or launch them directly. Defaults
to *direct* mode because *upstart* seems to be bugged when specifying extra docker run parameters in the config

## Installation

- Run `./install.sh` to register the upstart jobs.Containers should launch on system startup automatically.

## Manually starting/stopping containers

When adding / removing users, you can restart the service manually

- Stop all cloud-development containers: `service cloudDevelopment stop`
- Start all cloud-development containers: `service cloudDevelopment start`
