###### LEK (Logstash/Elasticsearch/Kibana3)
# A docker image that includes
# - logstash (1.4)
# - elasticsearch (1.0)
# - kibana (3.0)
#FROM qnib/fd20
FROM fedora
MAINTAINER "Christian Kniep <christian@qnib.org>"


ADD etc/yum.repos.d/logstash-1.4.repo /etc/yum.repos.d/logstash-1.4.repo
ADD etc/yum.repos.d/elasticsearch-1.0.repo /etc/yum.repos.d/elasticsearch-1.0.repo
RUN yum update -y -x systemd -x systemd-libs
# which is needed by bin/logstash :)
RUN yum install -y wget openssh-server which
RUN sshd-keygen

RUN yum install -y logstash elasticsearch
ADD etc/logstash/conf.d/syslog.conf /etc/logstash/conf.d/syslog.conf
RUN sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
RUN sed -i "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml


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

# Set (very simple) password for root
RUN echo "root:root"|chpasswd

EXPOSE 80
EXPOSE 514
EXPOSE 9200
EXPOSE 9300

ADD root/run.sh /root/run.sh
CMD /bin/bash /root/run.sh