Cloud development frontend proxy
================================

> Nginx frontend proxy to manage multi-user cloud-development environment  

## What it does

This docker container binds to the host's 80/443 ports listing to outside requests. Based on the request's hostname
format it will proxy the request to one of two container types:

- A webserver container linked to the identified user
- A code-editor container linked to the identified user

[More details](./conf/nginx/README.md)

#### Ports mapping

The ports mapping to determine to what port we should proxy the request for user `foo` for both the editor/webserver container
needs to be provided through an external configuration file, that will be populated through the environment to nginx.

So user `clark_kent` will have a total of 4 containers running, say 8080 for auth webserver, 8081 webserver, 8082 auth code editor,
8083 code editor. And it has an id of 1, so it'll start on port 8080.

#### Virtual hosts configuration

The vhosts configuration for each hostname is generated dynamically on container startup using a
[shared common template](./conf/nginx/directives/virtual_host_template.conf). This configuration is included in the main
nginx http block.

## Container setup

The nginx is running as a supervisor process. Before the nginx process is launched by supervisor, a proxy generator
script runs.

## Managing & running the container

### Extra configuration

Additional `server {}` blocks can be added to the nginx container on runtime, map a volume with the
extra nginx configuration files to `/etc/nginx/extra`

### Requirements

##### SSL Certificates

Before building the image, place the server's ssl certificates in the folder `./certs` for running nginx over https.

```sh
./certs/cert.pem;
./certs/cert.key;
```

For local testing, check these [instructions](https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04)
on how to create a self-signed certificate.

##### Cloud users list

When running the container, a list of users w/ their unique ids has to be provided to the container via environment variables.
More details  the [proxy rules generator script](`./scripts/nginx_proxy_rules.sh`) for more details.


### Build

`docker build -t cloud-frontend-proxy ./`

where -t is the container's tag name.


### Run

To run the container, execute

`docker run -d -p 80:80 -p 443:443 -v /path/to/nginx/ssl-certs/folder/:/etc/nginx/certs/ -v /optional/path/to/extra/conf:/etc/nginx/extra --env-file path/to/users_ids_definition -e BASE_HOSTNAME=localhost -e PROXY_HOST=172.17.42.1 --name cloud-frontend-proxy cloud-frontend-proxy`

- `-p` here is binding to the usual 80 / 443 ports
- `--env-file` sources the environment variables from the provided file, which should contain a list of all user & their ids
- `BASE_HOSTNAME` should match the base hostname the frontend server will listen to
- `PROXY_HOST` should match the host that will server the code-editor/webserver containers (leave empty to use host calling script)
- optionally override build image certificates by pointing `cert.crt`, `cert.key` files to `/etc/nginx/certs`
