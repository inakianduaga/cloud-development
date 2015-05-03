Cloud development demo
======================

> Basic demo to test the cloud development workflow

This demo attemps to run the development environment running for 2 users, `clark_kent` (w/ a simple hello world app) and
`bruce_wayne` (with a simple nodejs hello world). Github functionality is disabled since the `./repo` folders are not real
 git folders.

## Setup

### Required docker images

- Nodejs
- nginx php webserver
- Doorman authentication
- Frontend proxy
- CodeboxIde

We can launch all images on their respective ports using the `bootstrap.sh` script.

### Authentication

Doorman has been pre-configured with a simple password authentication for each user

```
clark_kent :CFcPHRKC86CNaZwWj8Da
bruce_wayne: YuDmNVSNabkuYVG359SS
```



#### Ports mapping

The ports mapping to determine to what port we should proxy the request for user `foo` for both the editor/webserver container
needs to be provided through an external configuration file, that will be populated through the environment to nginx.

So user `clark_kent` will have a total of 4 containers running, say 8080 for auth webserver, 8081 webserver, 8082 auth code editor,
8083 code editor. And it has an id of 1, so it'll start on port 8080.


## Container setup

The nginx is running as a supervisor process. Before the nginx process is launched by supervisor, a proxy generator
script runs.

## Managing & running the container

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

`docker run -d -p 80:80 -p 443:443 --env-file path/to/users_ids_definition -e BASE_HOSTNAME=localhost cloud-frontend-proxy`

- `-p` here is binding to the usual 80 / 443 ports
- `--env-file` sources the environment variables from the provided file, which should contain a list of all user ids
- `BASE_HOSTNAME` should match the base hostname we want
