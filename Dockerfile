### Docker Image
FROM qnib/logstash:fd22

ENV RUN_SERVER=true \
    BOOTSTRAP_CONSUL=true
ADD etc/yum.repos.d/elasticsearch.repo /etc/yum.repos.d/
RUN dnf install -y which zeromq

## nginx
RUN dnf install -y nginx httpd-tools
ADD etc/nginx/ /etc/nginx/
ADD etc/diamond/collectors/NginxCollector.conf /etc/diamond/collectors/NginxCollector.conf

# Add QNIBInc repo
# statsd
RUN dnf clean all; dnf install -y statsd
ADD etc/statsd/config.js /etc/statsd/

## Kibana3
ENV KIBANA_VER 3.1.2
WORKDIR /var/www/
RUN curl -s -o /tmp/kibana-${KIBANA_VER}.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VER}.tar.gz && \
    tar xf /tmp/kibana-${KIBANA_VER}.tar.gz && rm -f /tmp/kibana-${KIBANA_VER}.tar.gz && \
    mv kibana-${KIBANA_VER} kibana
ADD etc/nginx/conf.d/kibana.conf /etc/nginx/conf.d/kibana.conf
WORKDIR /etc/nginx/
# Config kibana-Dashboards
ADD var/www/kibana/app/dashboards/ /var/www/kibana/app/dashboards/
ADD var/www/kibana/config.js /var/www/kibana/config.js

## Kibana4
WORKDIR /opt/
ENV KIBANA_VER 4.0.2
RUN curl -s -L -o kibana-${KIBANA_VER}-linux-x64.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VER}-linux-x64.tar.gz && \
    tar xf kibana-${KIBANA_VER}-linux-x64.tar.gz && \
    rm /opt/kibana*.tar.gz
RUN ln -sf /opt/kibana-${KIBANA_VER}-linux-x64 /opt/kibana
ADD etc/supervisord.d/kibana.ini /etc/supervisord.d/
# Config kibana4
ADD opt/kibana/config/kibana.yml /opt/kibana/config/kibana.yml


# logstash config
ADD etc/default/logstash/ /etc/default/logstash/
ADD etc/grok/ /etc/grok/
ADD etc/consul.d/ /etc/consul.d/
#
# Should move to terminal
ADD opt/qnib/bin/ /opt/qnib/bin/
ADD etc/diamond/handlers/InfluxdbHandler.conf /etc/diamond/handlers/InfluxdbHandler.conf
ADD etc/supervisord.d/ /etc/supervisord.d/
