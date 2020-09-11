#!/usr/bin/env bash

ID=`whoami`
eos_ids=`ps -fu $ID|grep nodeos|grep generator|grep -v grep |awk -F' ' '{print $2}'|xargs`
echo $eos_ids
for id in $eos_ids; do
    kill $id
    echo "$id was killed"
done
