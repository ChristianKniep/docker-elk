###### LEK (Logstash/Elasticsearch/Kibana3)
# A docker image that includes
# - logstash (1.4)
# - elasticsearch (1.0)
# - kibana (3.0)
# - StatsD (to fetch stuff from logstash)
FROM qnib/terminal
MAINTAINER "Christian Kniep <christian@qnib.org>"

ADD etc/yum.repos.d/logstash-1.4.repo /etc/yum.repos.d/
ADD etc/yum.repos.d/elasticsearch-1.2.repo /etc/yum.repos.d/
#ADD etc/yum.repos.d/local_logstash-1.4.repo /etc/yum.repos.d/
#ADD etc/yum.repos.d/local_elasticsearch-1.2.repo /etc/yum.repos.d/
# which is needed by bin/logstash :)
RUN yum install -y which zeromq && \
    ln -s /usr/lib64/libzmq.so.1 /usr/lib64/libzmq.so

# logstash
RUN useradd jls && \
    yum install -y logstash
ADD etc/supervisord.d/logstash.ini /etc/supervisord.d/

# elasticsearch
RUN yum install -y elasticsearch && \
    sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
## Makes no sense to be done while building
#RUN sed -i "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini
# diamond collector
ADD etc/diamond/collectors/ElasticSearchCollector.conf /etc/diamond/collectors/ElasticSearchCollector.conf 

## nginx
RUN yum install -y nginx httpd-tools
ADD etc/nginx/conf.d/diamond.conf /etc/nginx/conf.d/diamond.conf
ADD etc/diamond/collectors/NginxCollector.conf /etc/diamond/collectors/NginxCollector.conf

# Add QNIBInc repo
RUN echo "20140913.1"; yum clean all
# statsd
RUN yum install -y qnib-statsd qnib-grok-patterns qnib-logstash-conf

## Kibana
WORKDIR /opt/
ADD kibana-3.1.1.tar.gz /opt/
WORKDIR /etc/nginx/conf.d
ADD etc/nginx/conf.d/kibana.conf /etc/nginx/conf.d/kibana.conf
RUN mkdir -p /var/www; ln -s /opt/kibana-3.1.1 /var/www/kibana
WORKDIR /etc/nginx/
RUN if ! grep "daemon off" nginx.conf ;then sed -i '/worker_processes.*/a daemon off;' nginx.conf;fi

# Config kibana-Dashboards
ADD var/www/kibana/app/dashboards/ /var/www/kibana/app/dashboards/
ADD var/www/kibana/config.js /var/www/kibana/config.js

# logstash watchdog
ADD root/bin/ /root/bin/
ADD etc/default/logstash/ /etc/default/logstash/
ADD etc/logstash/conf.d/ /etc/logstash/conf.d/

ADD etc/consul.d/check_elasticsearch.json /etc/consul.d/check_elasticsearch.json
ADD etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD etc/syslog-ng/conf.d/logstash.conf /etc/syslog-ng/conf.d/logstash.conf
# Should move to terminal
ADD opt/qnib/bin/ /opt/qnib/bin/
ADD etc/diamond/handlers/InfluxdbHandler.conf /etc/diamond/handlers/InfluxdbHandler.conf
ADD etc/supervisord.d/ /etc/supervisord.d/

# move up
RUN rm -f /root/bin/* && \
    ln -s /opt/qnib/bin/* /root/bin/
