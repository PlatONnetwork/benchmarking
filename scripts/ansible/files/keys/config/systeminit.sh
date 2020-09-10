#!/usr/bin/env bash

cleos set contract eosio $HOME/eosio/eosio.contracts/build/contracts/eosio.system -p eosio
cleos push action eosio init '[0,"4,SYS"]' -p eosio@active

votetoall()
{
    for tmpline in `cat ./hostsinfo`
    do
        n=`echo $tmpline | cut -d ',' -f2`
	if [ $n = 'eosio' ]; then
            continue
	else
	    cleos system voteproducer prods $1 $n
	    echo "$1 vote to $n"
        fi
    done
}

for line in `cat ./hostsinfo`
do
    name=`echo $line | cut -d ',' -f2`
    pubkey=`echo $line | cut -d ',' -f4`
    if [ $name = "eosio" ]; then
        continue
    else
        echo begin create account $name $pubkey
        cleos system newaccount --transfer eosio $name $pubkey $pubkey --stake-net "100000000.0000 SYS" --stake-cpu "100000000.0000 SYS" --buy-ram "20000.0000 SYS" 
        sleep 1
        echo begin regproducer $name $pubkey
        cleos system regproducer $name $pubkey
        sleep 1
        echo begin transfer to $name
        cleos push action eosio.token transfer '['eosio', "'${name}'","100000000.0000 SYS","vote"]' -p eosio
        sleep 1
        echo begin delegatebw to $name
        cleos system delegatebw $name $name '2500000.0000 SYS' '2500000.0000 SYS'
    fi 
done

for destinfo in `cat ./hostsinfo`
do
    destname=`echo $destinfo | cut -d ',' -f2`
    if [ $destname = 'eosio' ]; then
	continue
    else
        votetoall $destname
    fi
done

