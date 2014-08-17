docker-elk
==========

Dockerfile creating ELK services (Elasticsearch/Logstash/Kibana)

It will

- start sshd
- start diamond
- start StatsD
- send the current IP to an expected etcd instance running on the first nameserver under the name

  - logstash
  - elasticsearch
  - $(hostname)
  - kibana

- start elasticsearch
- start nginx (kibana)
- start logstash


I start the image as follows:

```
# To get all the /dev/* devices needed for sshd and alike:
export DEV_MOUNTS="-v /dev/null:/dev/null -v /dev/urandom:/dev/urandom -v /dev/random:/dev/random"
export DEV_MOUNTS="${DEV_MOUNTS} -v /dev/full:/dev/full -v /dev/zero:/dev/zero"
# if you got an etcd/helixdns instance running
export DNS_STUFF="--dns=172.17.0.3"
# if you want to store Elasticsearchs data outside 
mkdir -p ${HOME}/elasticsearch
export ES_PERSIST="-v ${HOME}/elasticsearch:/var/lib/elasticsearch"
docker run -t -i --rm -h elk --name elk --privileged \
    --link carbon:carbon --privileged ${DNS_STUFF} ${DEV_MOUNTS} \
    ${ES_PERSIST} qnib/elk:latest -p 9200:9200 -p 9300:9300 -p 8080:80 -p 5514:5514 /bin/bash

```

After the successfull start one might send an event to the dockerhost...

```
echo 'message2' | nc -w 1  192.168.59.103 5514
```
