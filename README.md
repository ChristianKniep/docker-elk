docker-elk
==========

Dockerfile creating ELK services (Elasticsearch/Logstash/Kibana)

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
export NAME=elk
docker run -d -h ${NAME} --name ${NAME} \
    -p 9200:9200 -p 9300:9300 -p 8080:80 -p 5514:5514 \
    qnib/elk
```

After the successfull start one might send an event to the dockerhost...

```
echo 'message2' | nc -w 1  192.168.59.103 5514
```
