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
ADD etc/yum.repos.d/local_logstash-1.4.repo /etc/yum.repos.d/
ADD etc/yum.repos.d/local_elasticsearch-1.2.repo /etc/yum.repos.d/
# which is needed by bin/logstash :)
RUN yum install -y which zeromq
RUN ln -s /usr/lib64/libzmq.so.1 /usr/lib64/libzmq.so

## kibana && nginx
RUN yum install -y nginx
WORKDIR /opt/
ADD kibana-3.1.0.tar.gz /opt/
WORKDIR /etc/nginx/conf.d
ADD etc/nginx/conf.d/kibana.conf /etc/nginx/conf.d/kibana.conf
RUN sed -i -e 's/kibana.myhost.org;/localhost;/' nginx.conf
RUN sed -i -e 's#/usr/share/kibana3#/var/www/#' nginx.conf
RUN mkdir -p /var/www
RUN ln -s /opt/kibana-3.1.0 /var/www/kibana
WORKDIR /etc/nginx/
RUN if ! grep "daemon off" nginx.conf ;then sed -i '/worker_processes.*/a daemon off;' nginx.conf;fi
ADD etc/supervisord.d/nginx.ini /etc/supervisord.d/nginx.ini

# logstash
RUN useradd jls
RUN yum install -y logstash
ADD etc/supervisord.d/logstash.ini /etc/supervisord.d/

# elasticsearch
RUN yum install -y elasticsearch
RUN sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
## Makes no sense to be done while building
#RUN sed -i "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini

# Add QNIBInc repo
RUN echo "20140815.1"; yum clean all
# statsd
RUN yum install -y qnib-statsd
# qnib-grok
RUN yum install -y qnib-grok-patterns
# logstash-conf
RUN yum install -y qnib-logstash-conf

# Config kibana-Dashboards
ADD opt/kibana-3.1.0/app/dashboards/ /opt/kibana-3.1.0/app/dashboards/

EXPOSE 5514

CMD /bin/supervisord -c /etc/supervisord.conf
