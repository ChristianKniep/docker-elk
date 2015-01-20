#!/bin/bash

## set htpasswd
if [ "X${HTUSER}" != "X" ];then
    if [ "X${HTPASSWD}" == "X" ];then
        HTPASSWD=${HTUSER}
    fi
    htpasswd -cb /etc/nginx/.htpasswd $HTUSER $HTPASSWD
else
    ### Delete Restricted access
    sed -i '/.*auth_basic "Restricted";/d' /etc/nginx/conf.d/kibana.conf
    sed -i '/.*auth_basic_user_file.*/d' /etc/nginx/conf.d/kibana.conf
fi

if [ "X${HTTPPORT}" == "X" ];then
    HTTPPORT=9200
fi

sed -i -e "s/HTTP_PORT/${HTTPPORT}/" /var/www/kibana/config.js

## Start nginx
/usr/sbin/nginx

