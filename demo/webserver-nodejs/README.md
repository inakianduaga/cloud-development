Nodejs + npm image
==================

> Provides minimum platform to run a nodejs app

- mount app on `/app` folder
- nodejs listens on port *8080*
## Run

`docker run -d -p 3000:8080 -v /path/to/app/:/app/ --name cloud-webserver-nodejs cloud-webserver-nodejs`