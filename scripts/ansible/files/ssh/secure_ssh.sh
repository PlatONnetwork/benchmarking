#!/bin/bash
cat /var/log/auth.log |grep ": Failed" |awk '{print$(NF-3)}'|sort |uniq -c|awk '{print$2"="$1}' > /usr/local/bin/black.list
for i in `cat /usr/local/bin/black.list`
do
        IP=`echo $i |awk -F'=' '{print $1}'`
        NUM=`echo $i |awk -F'=' '{print $2}'`
        if [ ${NUM} -gt 10 ]; then
                grep $IP /etc/hosts.deny > /dev/null
                if [ $? == 1 ]; then
                        echo "sshd:$IP:deny" >> /etc/hosts.deny
                fi
        fi
done
