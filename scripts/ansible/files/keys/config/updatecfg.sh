#!/bin/bash

remoteuser=pchuant
remotedir=/home/$remoteuser/eosio
localip=47.241.16.204

updatePeerAddress()
{
    for tmpline in `cat ./tmp`
    do
	dirname=$tmpline
	if [ "$1" = "$dirname" ]; then
	    continue
	else
	    echo "p2p-peer-address = $1:9875" >> $dirname/producer.ini
	    echo "write to $1/producer.ini"
	fi
    done
}

for line in `cat ./hostsinfo`
do
    echo $line
    ip=`echo $line | cut -d ',' -f1`
    name=`echo $line | cut -d ',' -f2`
    pubkey=`echo $line | cut -d ',' -f4`
    prikey=`echo $line | cut -d ',' -f3`

    rm -rf "$ip" && mkdir "$ip"
    cp ./producer.ini ./generator.ini $ip
    echo "$ip" >> tmp
    echo "" >> $ip/producer.ini
    echo "" >> $ip/generator.ini
    echo "producer-name = $name" >> $ip/producer.ini
    echo "private-key = [\"$pubkey\",\"$prikey\"]" >> $ip/producer.ini
    if [ $name = 'eosio' ]; then
        echo "txn-test-gen-account-prefix=tx" >> $ip/generator.ini
        echo "http-server-address = 0.0.0.0:8888" >> $ip/producer.ini
    else
	echo "txn-test-gen-account-prefix=$name" >> $ip/generator.ini
    fi
done

for line in `cat ./hostsinfo`
do
    ip=`echo $line | cut -d ',' -f1`
    updatePeerAddress $ip
done

# upload config to hosts
for host in `cat ./tmp`
do
    if [ "$host" = "$localip" ]; then
        cp ./$localip/producer.ini ./genesis.json ./$localip/generator.ini $HOME/eosio/config/
        cp ./start*.sh ./creategenAccount.sh ./cleardata.sh $HOME/eosio/bin/
        cp ./hostsinfo $HOME/eosio/bin/
    else
        scp -o StrictHostKeyChecking=no ./$host/producer.ini ./genesis.json ./$host/generator.ini $remoteuser@${host}:${remotedir}/config/
        scp -o StrictHostKeyChecking=no ./start*.sh ./creategenAccount.sh ./cleardata.sh $remoteuser@${host}:${remotedir}/bin/
    fi
done

rm tmp
