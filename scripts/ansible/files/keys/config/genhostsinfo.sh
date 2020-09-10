#!/usr/bin/env bash

names=(aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt bu bv bw bx by bz ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cq cr cs ct cu cv cw cx cy cz da db dc dd de df dg dh di dj dk dl dm dn do dp dq dr ds dt du dv dw dx dy dz ea eb ec ed ef eg)

rm hostsinfo
i=0
for host in `cat ./hosts`
do
    if [ $i == 0 ];then
        name='eosio'
	PK="EOS5PsdQvdpwTZdhRhiPqeCqZ1Hmz2L2QEe7m5rz2JbqkFsGYkjqG"
	SK="5J3kr9m8oA4SdxLwGG2v8grqCsHs1ieNGWsmmAgAGq9S7hepm5H"
        echo "$host,$name,$SK,$PK" >> hostsinfo
    else
        key=`cleos create key --to-console|awk -F: '{print $2}'|xargs|sed 's/ /,/g'`
        echo "$host,${names[$i]},$key" >> hostsinfo
    fi
    let i=$i+1
done
