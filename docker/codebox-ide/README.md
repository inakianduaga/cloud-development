Codebox IDE
============

> Dockerized codebox IDE server for editing on the cloud

This docker image runs a supervised codebox nodejs that provides a WebIDE for cloud development

## Managing & running the container

### Build

`docker build -t codebox ./`

where -t is the tag name we give the container

### Run

To run the container, execute

`docker run -d -p 8000:8000 -v /path/to/host/codebase:/var/www --name codebox codebox`

- container listens on port `8000` and expects code to be available on `/var/www/` inside the container
