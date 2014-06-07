###### LEK (Logstash/Elasticsearch/Kibana3)
# A docker image that includes
# - logstash (1.4)
# - elasticsearch (1.0)
# - kibana (3.0)
FROM qnib-terminal
MAINTAINER "Christian Kniep <christian@qnib.org>"

ADD etc/yum.repos.d/logstash-1.4.repo /etc/yum.repos.d/logstash-1.4.repo
ADD etc/yum.repos.d/elasticsearch-1.2.repo /etc/yum.repos.d/elasticsearch-1.2.repo
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
RUN sed -i -e 's#/usr/share/kibana3#/var/www/#' nginx.conf
RUN mkdir -p /var/www
RUN ln -s /opt/kibana-3.0.0 /var/www/kibana
WORKDIR /etc/nginx/
RUN if ! grep "daemon off" nginx.conf ;then sed -i '/worker_processes.*/a daemon off;' nginx.conf;fi
ADD etc/supervisord.d/nginx.ini /etc/supervisord.d/nginx.ini

# qnib-grok
ADD yum-cache/grok /tmp/yum-cache/grok
RUN yum install -y /tmp/yum-cache/grok/qnib-groks-1.0.0-20140426.1.noarch.rpm
RUN yum install -y /tmp/yum-cache/grok/python-envoy-0.0.2-1.noarch.rpm
RUN rm -rf /tmp/yum-cache/grok

# logstash
RUN useradd jls
RUN yum install -y logstash
ADD etc/logstash/conf.d/syslog.conf /etc/logstash/conf.d/syslog.conf
ADD etc/supervisord.d/logstash.ini /etc/supervisord.d/logstash.ini

# elasticsearch
RUN yum install -y elasticsearch
RUN sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
## Makes no sense to be done while building
#RUN sed -i "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini

##### Provide tools to do stuff
# grok testing
RUN yum install -y python-docopt python-simplejson python-envoy rubygems
### WORKAROUND
RUN yum install -y ruby-devel make gcc
RUN gem install jls-grok

CMD /bin/supervisord -c /etc/supervisord.conf
