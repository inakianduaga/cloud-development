Cloud development toolkit
=========================

> Dockerized multi-user capable environment to edit and preview server-based applications (php/nodejs)

Leveraging docker containers, for each predefined user you can easily set up an environment of the form

```
user1.view.myserver.com     # to preview user1 app,
user1.edit.myserver.com     # to edit user1 app
user2.view.myserver.com
user2.edit.myserver.com
user4.view.myserver.com
user5.view.myserver.com
...
```

where each subdomain will have per-user authentication options, per-user server application, and per-user editor.

## Features

- Separate cloud development for multiple users!
- Run a webserver behind an authentication proxy that previews a pre-defined application
- Run an [editor](https://github.com/inakianduaga/docker-codeboxide) behind an authentication proxy to edit a pre-defined application
   - For php/nginx applications view changes in realtime through the webserver proxy
- Several authentication methods provided through the included doorman auth proxy (or provide your own authentication container).

## Infrastructure overview

See [Infrastructure.md](./INFRASTRUCTURE.md)

## Config

The main configuration for assisted deployment lives in the `./config` folder. You should provide the list of users and
their respective docker images (that you must provide separately).

## Deploy

1. Build the required cloud-development docker images by running `./scripts/build_docker_images.sh`.
2. Build any other image(s) (like [CodeboxIde editor](https://github.com/inakianduaga/docker-codeboxide)), and webserver images
 based on the user configuration
3. The folder `./scripts/upstart` contains [upstart scripts](./scripts/upstart/README.md) to run the environment.

## Demo

A demo application is provided in the `./demo` folder, see [demo details](./demo/README.md) for how to install/run the demo.


