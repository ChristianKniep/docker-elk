docker-elk
==========
[![](https://badge.imagelayers.io/qnib/elk:latest.svg)](https://imagelayers.io/?images=qnib/elk:latest 'Get your own badge on imagelayers.io')

Dockerfile creating ELK services (Elasticsearch/Logstash/Kibana)

It's available on [hub.docker.com](https://registry.hub.docker.com/u/qnib/elk/), just pull it:
`docker pull qnib/elk`

## Parts

It will

- connects with consul, if available
- start sshd
- start logstash
- start diamond
- start StatsD
- start elasticsearch
- start nginx (kibana3)
- start kibana4

How to use kibana3 and kibana4 could be explored within this ['hello world' blog post](http://qnib.org/2015/05/26/elk-kibana4/).

### Within QNIBTerminal

To get the most out of it a carbon container might be added, but this will impose the question whether to go even further and distribute all the services.



### Known issues

##### Time mismatch in rsyslog

If you forward syslog from rsyslogd, you might encounter a mismatch between UTC and CET. To fix this use this configuration:

```
# Provide a propper timeformat to fix the UTC/CET mismatch
$template forward_template,"<%PRI%>%TIMESTAMP:::date-rfc3339% %HOSTNAME% %syslogtag:1:32%%msg:::sp-if-no-1st-sp%%msg%"
*.* @@127.0.0.1:5514;forward_template
```
