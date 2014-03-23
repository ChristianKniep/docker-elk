#!/usr/bin/bash

if ps -ef|grep -v grep|grep -c sshd >/dev/null;then
    echo "sshd already running"
else
    echo "starting sshd"
    /usr/sbin/sshd
fi
if ps -ef|grep -v grep|grep -c diamond >/dev/null;then
    echo "diamond already running"
else
    echo "starting diamond"
    /bin/diamond
fi
MASTER_IP=$(cat /etc/resolv.conf |grep nameserver|head -n1 |awk '{print $2}')
MY_IP=$(ip -o -4 addr|grep eth0|awk '{print $4}'|awk -F/ '{print $1}')
for alias in $(hostname) logstash elasticsearch kibana;do
    curl -o /dev/null -s -XPUT http://${MASTER_IP}:4001/v2/keys/helix/${alias}/A -d value="${MY_IP}"
done
service elasticsearch start

if ps -ef|grep -v grep|grep -c nginx >/dev/null;then
    echo "nginx already running"
else
    echo "starting nginx"
    nginx
fi
if ps -ef|grep -v grep|grep -c logstash >/dev/null;then
    echo "logstash already running"
else
    echo "starting logstash"
    /opt/logstash/bin/logstash agent -f /etc/logstash/conf.d/ -l /var/log/logstash/logstash.log
fi
