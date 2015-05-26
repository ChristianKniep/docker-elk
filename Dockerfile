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

# Add QNIBInc repo
# statsd
RUN echo "20140917.1"; yum clean all; yum install -y qnib-statsd qnib-grok-patterns 

## Kibana
WORKDIR /opt/
ENV KIBANA_VER 4.0.2
RUN curl -s -L -o kibana-${KIBANA_VER}-linux-x64.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VER}-linux-x64.tar.gz && \
    tar xf kibana-${KIBANA_VER}-linux-x64.tar.gz && \
    rm /opt/kibana*.tar.gz
RUN ln -sf /opt/kibana-${KIBANA_VER}-linux-x64 /opt/kibana
ADD etc/supervisord.d/kibana.ini /etc/supervisord.d/
ADD etc/consul.d/check_kibana.json /etc/consul.d/check_kibana.json
# Config kibana
ADD opt/kibana/config/kibana.yml /opt/kibana/config/kibana.yml

# logstash config
ADD etc/default/logstash/ /etc/default/logstash/

ADD etc/consul.d/ /etc/consul.d/
#
# Should move to terminal
ADD opt/qnib/bin/ /opt/qnib/bin/
ADD etc/diamond/handlers/InfluxdbHandler.conf /etc/diamond/handlers/InfluxdbHandler.conf
ADD etc/supervisord.d/ /etc/supervisord.d/
