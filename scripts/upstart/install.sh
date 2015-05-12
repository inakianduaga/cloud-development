#!/bin/bash

# Register upstart services
cp ./*.conf /etc/init
initctl reload-configuration