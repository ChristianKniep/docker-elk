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


## Prepare the environment I start the image as follows:

```
# To get all the /dev/* devices needed for sshd and alike:
export DEV_MOUNTS="-v /dev/null:/dev/null -v /dev/urandom:/dev/urandom -v /dev/random:/dev/random"
export DEV_MOUNTS="${DEV_MOUNTS} -v /dev/full:/dev/full -v /dev/zero:/dev/zero"
### OPTIONAL -> if you got an etcd/helixdns instance running
export DNS_STUFF="--dns=172.17.0.3"
### OPTIONAL -> link carbon container to provide metrics target
export LINK="--link carbon:carbon"
### OPTIONAL -> if you want to store Elasticsearchs data outside 
export ES_PERSIST="-v ${HOME}/elasticsearch:/var/lib/elasticsearch"
### OPTIONAL -> To use a mapped in configuration directory
# if not used, the default will be used within the container
export LS_CONF="-v ${HOME}/logstash.d/:/etc/logstash/conf.d/"
### OPTIONAL -> map apache2 config into container
export AP_LOG="-v ${HOME}/var/log/apache2/:/var/log/apache2"
### OPTIONAL -> set the external port to something else then 80
export HTTP_PORT="-e HTTPPORT=8080 -p 8080:80"
### OPTIONAL -> To secure kibana and elasticsearch user/passwd could be set
# if a user is set and no passwd, the user will be set as password
export HTUSER=kibana
export HTPASSWD=secretpw
```
### Run container interactivly
```
docker run -t -i --rm -h elk --name elk --privileged \
    ${DNS_STUFF} ${DEV_MOUNTS} ${LINK} \
    ${HTTP_PORT} ${LS_CONF} ${AP_LOG} \
    -e HTUSER=${HTUSER} -e HTPASSWD=${HTPASSWD} \
    ${ES_PERSIST} qnib/elk:latest bash
bash-4.2# supervisor_daemonize.sh
# supervisorctl status
diamond                          RUNNING   pid 21, uptime 0:00:04
elasticsearch                    RUNNING   pid 16, uptime 0:00:04
logstash                         RUNNING   pid 89, uptime 0:00:03
logstash_watchdog                RUNNING   pid 17, uptime 0:00:04
nginx                            RUNNING   pid 24, uptime 0:00:04
setup                            RUNNING   pid 15, uptime 0:00:04
sshd                             RUNNING   pid 20, uptime 0:00:04
statsd                           RUNNING   pid 115, uptime 0:00:02
syslog-ng                        STOPPED   Not started
```

### Run container detached
```
docker run -d-h elk --name elk --privileged \
    ${DNS_STUFF} ${DEV_MOUNTS} ${LINK} \
    ${HTTP_PORT} ${LS_CONF} ${AP_LOG} \
    -e HTUSER=${HTUSER} -e HTPASSWD=${HTPASSWD} \
    ${ES_PERSIST} qnib/elk:latest 
```

## Feed the beast

After the successfull start one might send an event to the dockerhost...

```
echo 'message2' | nc -w 1  192.168.59.103 5514
```

Sending logs to apache2

```
cat << EOF >> ~/var/log/apache2/apache.log
10.10.0.1 - - [29/Oct/2014:18:42:18 +0100] "GET / HTTP/1.1" 200 2740 "-" "Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B411 Safari/600.1.4"
10.10.0.1 - - [29/Oct/2014:18:42:19 +0100] "GET /css/main.css HTTP/1.1" 200 2805 "http://qnib.org/" "Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B411 Safari/600.1.4"
10.10.0.1 - - [29/Oct/2014:18:42:19 +0100] "GET /pics/second_strike_trans.png HTTP/1.1" 200 29636 "http://qnib.org/" "Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B411 Safari/600.1.4"
EOF
```


