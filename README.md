docker-lek
==========

Dockerfile creating LEK services (Logstash/Elasticsearch/Kibana)

It will

- start sshd
- start diamond (which is not installed yet) 
- send the current IP to an expected etcd instance running on the first nameserver under the name

  - logstash
  - elasticsearch
  - $(hostname)
  - kibana

- start elasticsearch
- start nginx (kibana)
- start logstash (this one will be keept in foreground)


I start the image as follows:

```
export NAME=lek
docker run -d -h ${NAME} --name ${NAME} \
    --dns $(docker inspect -format '{{ .NetworkSettings.IPAddress }}' master) \
    --dns=$(cat /etc/resolv.conf |grep nameserver|head -n1|awk '{print $2}') \
    -p 9200:9200 -p 9300:9300 -p 8080:80 -p 5514:5514 \
    qnib/docker-lek
```