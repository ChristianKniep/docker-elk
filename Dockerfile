###### LEK (Logstash/Elasticsearch/Kibana3)
# A docker image that includes
# - logstash (1.4)
# - elasticsearch (1.0)
# - kibana (3.0)
FROM qnib/fd20
MAINTAINER "Christian Kniep <christian@qnib.org>"

# setup 
ADD root/bin /root/bin
ADD etc/supervisord.d/setup.ini /etc/supervisord.d/setup.ini

## supervisord
RUN yum install -y supervisor 
RUN mkdir -p /var/log/supervisor
RUN sed -i -e 's/nodaemon=false/nodaemon=true/' /etc/supervisord.conf

ADD etc/yum.repos.d/logstash-1.4.repo /etc/yum.repos.d/logstash-1.4.repo
ADD etc/yum.repos.d/elasticsearch-1.0.repo /etc/yum.repos.d/elasticsearch-1.0.repo
# which is needed by bin/logstash :)
RUN yum install -y openssh-server which
RUN sshd-keygen

## kibana && nginx
RUN yum install -y nginx
WORKDIR /opt/
RUN wget -q https://download.elasticsearch.org/kibana/kibana/kibana-3.0.0.tar.gz
RUN tar xf kibana-3.0.0.tar.gz
WORKDIR /etc/nginx/conf.d
RUN wget -q https://raw.githubusercontent.com/elasticsearch/kibana/master/sample/nginx.conf
RUN sed -i -e 's/kibana.myhost.org;/localhost;/' nginx.conf
RUN sed -i -e 's#/usr/share/kibana3#/opt/kibana-3.0.0/#' nginx.conf
RUN #if ! grep "daemon off" nginx.conf ;then sed -i '/worker_processes.*/a daemon off;' nginx.conf;fi
ADD etc/supervisord.d/nginx.ini /etc/supervisord.d/nginx.ini

# logstash
RUN yum install -y logstash 
ADD etc/logstash/conf.d/syslog.conf /etc/logstash/conf.d/syslog.conf
ADD etc/supervisord.d/logstash.ini /etc/supervisord.d/logstash.ini

# elasticsearch
RUN yum install -y elasticsearch
RUN sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
## Makes no sense to be done while building
#RUN sed -i "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini

# syslog
RUN yum install -y syslog-ng
ADD etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
ADD etc/supervisord.d/syslog-ng.ini /etc/supervisord.d/

EXPOSE 80
EXPOSE 514
EXPOSE 9200
EXPOSE 9300


ADD etc/supervisord.d /etc/
CMD /bin/supervisord -c /etc/supervisord.conf
