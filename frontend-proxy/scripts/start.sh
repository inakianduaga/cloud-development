#!/bin/bash

# Generate nginx base hostname environment
/scripts/nginx_base_hostname.sh > /etc/nginx/base_hostname

#Generate nginx user variables from environment user list
#/scripts/nginx_user_env.sh >> /etc/nginx/nginx_environment

#Generate dynamic nginx proxy rules
/scripts/nginx_proxy_rules.sh >> /etc/nginx/dynamic_proxy_rules

#Run processes through supervisor
exec supervisord
