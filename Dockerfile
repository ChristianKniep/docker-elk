FROM qnib/logstash
MAINTAINER "Christian Kniep <christian@qnib.org>"

ADD etc/yum.repos.d/elasticsearch-1.4.repo /etc/yum.repos.d/
RUN yum install -y which zeromq && \
    ln -s /usr/lib64/libzmq.so.1 /usr/lib64/libzmq.so

# elasticsearch
RUN yum install -y elasticsearch && \
    sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
## Makes no sense to be done while building
#RUN sed -i "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml
ADD etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini
# diamond collector
ADD etc/diamond/collectors/ElasticSearchCollector.conf /etc/diamond/collectors/ElasticSearchCollector.conf 

## nginx
RUN yum install -y nginx httpd-tools
ADD etc/nginx/ /etc/nginx/
ADD etc/diamond/collectors/NginxCollector.conf /etc/diamond/collectors/NginxCollector.conf

# Add QNIBInc repo
# statsd
RUN echo "20140917.1"; yum clean all; yum install -y qnib-statsd qnib-grok-patterns 

## Kibana
WORKDIR /opt/
ADD kibana-3.1.1.tar.gz /opt/
WORKDIR /etc/nginx/conf.d
ADD etc/nginx/conf.d/kibana.conf /etc/nginx/conf.d/kibana.conf
WORKDIR /etc/nginx/
RUN mkdir -p /var/www; ln -s /opt/kibana-3.1.1 /var/www/kibana && \
    if ! grep "daemon off" nginx.conf ;then sed -i '/worker_processes.*/a daemon off;' nginx.conf;fi

# Config kibana-Dashboards
ADD var/www/kibana/app/dashboards/ /var/www/kibana/app/dashboards/
ADD var/www/kibana/config.js /var/www/kibana/config.js

# logstash config
ADD etc/default/logstash/ /etc/default/logstash/

ADD etc/consul.d/ /etc/consul.d/
#
# Should move to terminal
ADD opt/qnib/bin/ /opt/qnib/bin/
ADD etc/diamond/handlers/InfluxdbHandler.conf /etc/diamond/handlers/InfluxdbHandler.conf
ADD etc/supervisord.d/ /etc/supervisord.d/
