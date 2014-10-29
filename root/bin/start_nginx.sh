#!/bin/bash

## set htpasswd
if [ "X${HTPASSWD}" == "X" ];then
    HTPASSWD=`tr -dc a-z0-9_ < /dev/urandom | head -c 16`
    echo Password set to: $HTPASSWD
fi

if [ "X${HTUSER}" == "X" ];then
    HTUSER=kibana
    echo User set to: $HTUSER
fi

htpasswd -cb /etc/nginx/.htpasswd $HTUSER $HTPASSWD

## Start nginx
/usr/sbin/nginx

