FROM ubuntu:trusty
MAINTAINER Inaki Anduaga <inaki@inakianduaga.com>

# Flag commands as non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Bootstrap & general tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get -y install wget curl supervisor

# installation
# https://github.com/docker/docker/issues/5383
RUN \
  apt-get -y install software-properties-common && \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  chown -R www-data:www-data /var/lib/nginx

# Configuration
COPY conf/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default
COPY conf/nginx/directives                   /etc/nginx/directives
COPY conf/nginx/location                     /etc/nginx/location
COPY conf/nginx/nginx.conf                   /etc/nginx/nginx.conf

# Run without daemon: http://stackoverflow.com/questions/18861300/how-to-run-nginx-within-docker-container-without-halting
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# add certificates
COPY certs /etc/nginx

# Expose ports nginx listens to
EXPOSE 80 443

# Startup scripts
ADD conf/supervisor/ /etc/supervisor/conf.d/
ADD scripts/ /scripts/
RUN chmod 755 /scripts/*.sh

# Default command
CMD ["/scripts/start.sh"]
