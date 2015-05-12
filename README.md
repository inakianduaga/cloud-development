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
- Several authentication methods provided through the included authentication proxy (doorman), or provide your own container.

## Infrastructure overview

See [Infrastructure.md](./INFRASTRUCTURE.md)

### Docker container structure

The following diagram shows the docker container structure, starting with a host that spawns:

- A frontend proxy container that routes external requests
- Per user, 1 auth-webserver container pair, 1 auth-editor container pair (former or latter can be optional as per config)

```
+-------------------------------------------------------------------------+
|                                                                         |
|                                                                         |
|         Host                      /var/cloud-development/users/user1 +-------+
|                                   ...                                   |    |
|                                                                         |    |
|                                                                         |    |
+----+-----------+-------------+----+------------------------+------+-----+    |
     |           |             |    |                        |      |          |
     |           |             |    |                        |      |          |
     |           |             |    |                        |      |          |
     |           |             |    |      +----------+      |      |          |
     |           |             |    |      |  USER1   |      |      |          |
     |           |             |    |  +---+----------+---+  |      |          |
     |           |             |    |  |                  |  |      |          |
     |           |             |    |  v                  v  |      |          |
+----+-----------+-------+     |    |                        |      |          |
|                        |     |   ++-----------+   +--------+--+   |          |
|                        |     |   |            |   |           |   |          |
|    Frontend Proxy      |     |   |    Auth    |   |   Auth    |   |          |
|       container        |     |   |  container |   | container |   |          |
|                        |     |   |  webserver |   |  editor   |   |          |
|                        |     |   |    user1   |   |  user1    |   |          |
+------------------------+     |   |            |   |           |   |          |
                               |   +------------+   +-----------+   |          |
                               |                                    |          |
                               |                                    |          |
                               |   +------------+   +------------+  |          |
                               |   |            |   |            |  |          |
                               |   | Webserver  |   |   Editor   |  |          |
                               |   | container  |   | Container  |  |          |
                               +---+   User1    |   |   User1    +--+          |
                                   |            |   |            |             |
                                   +---------^--+   +--------^---+             |
                                             |               |                 |
                                             |               |                 |
                                             |               |                 |
                                             +---------------+-----------------+

                                                       Shared volume
                                                       with containers
```

### Requests lifecycle

The following example shows the routing structure for an external request that by convention requests the webserver for *user1*. Only
the *frontend-proxy container* listens to the outside world, the rest of the containers listen on the internal docker0 network interface.

1. The frontend proxy receives the request and proxies it to the corresponding *user1 webserver auth container* that is listening
  on the docker0 interface
2. The auth container, after successful authentication, proxies the request to the *user1 webserver container* so the webserver
can be displayed

```
   Https

    +
    | user1.view.server.com
    v
    |
+-------------------------------------------------------------------------+
|   |                                                                     |
|   |                               +--------------------------+          |
|   |                               |                          |          |
|   |     Host   +--------->----------+  Docker0 Interface     |          |
|   |            |                  | |                        |          |
|   |            |                  +----------+->-+-----------+          |
|   |            |                    |        |   |                      |
+-------------------------------------------------------------------------+
    |            |                    |        |   |
    |            |                    |        |   |
    v            |                    |        |   |
    |            |                    v        |   |
    |            ^                    |        ^   v
    |            |                    |        |   |
    |            |                    |        |   |
    |            |                    |        |   |
+------------------------+            |        |   |
|   |            |       |         +--v--------++  |   +-----------+
|   v------------^       |         |            |  |   |           |
|                        |         |    Auth    |  |   |   Auth    |
|    Frontend Proxy      |         |  container |  |   | container |
|       container        |         |  webserver |  |   |  editor   |
|                        |         |    user1   |  |   |  user1    |
+------------------------+         |            |  |   |           |
                                   +------------+  |   +-----------+
                                                   |
                                                   |
                                   +------------+  |   +------------+
                                   |            |  |   |            |
                                   | Webserver  |  |   |   Editor   |
                                   | container  <--+   | Container  |
                                   |   User1    |      |   User1    |
                                   |            |      |            |
                                   +------------+      +------------+
```


## Config

The main configuration files for assisted deployment live in the `./config` folder. You should provide the list of users and
their respective docker images (that you must provide separately).

## Deploy

1. Build the required cloud-development docker images by running `./scripts/build_docker_images.sh`.
2. Build any other image(s) (like [CodeboxIde editor](https://github.com/inakianduaga/docker-codeboxide)), and webserver images
 based on your user configuration specifics.
3. The folder `./scripts/upstart` contains [upstart scripts](./scripts/upstart/README.md) to run the environment automatically on
startup, plus autorestart containers in case they die.

## Demo

A demo application is provided in the `./demo` folder, see [demo details](./demo/README.md) for how to install/run the demo.


