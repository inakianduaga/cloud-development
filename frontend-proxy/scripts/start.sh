#!/bin/bash

#Generate nginx user variables from environment user list
/scripts/nginx_env.sh >> /etc/nginx/nginx_environment

#Generate dynamic nginx proxy rules
/scripts/nginx_proxy_rules.sh >> /etc/nginx/dynamic_proxy_rules

#Run processes through supervisor
exec supervisord
