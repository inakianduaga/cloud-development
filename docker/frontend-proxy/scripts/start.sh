#!/bin/bash

# Generate virtual hosts configuration
/scripts/nginx_virtual_hosts.sh > /etc/nginx/virtual_hosts.conf

#Run processes through supervisor
exec supervisord
