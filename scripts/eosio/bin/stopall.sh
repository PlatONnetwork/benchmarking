#!/usr/bin/env bash

ID=`whoami`
eos_ids=`ps -fu $ID|grep nodeos|grep -v grep |awk -F' ' '{print $2}'|xargs`
echo $eos_ids
for id in $eos_ids; do
    kill $id
    echo "$id was killed"
done
keosd_ids=`ps -fu $ID|grep keosd|grep -v grep |awk -F' ' '{print $2}'|xargs`
echo $keosd_ids
for kid in $keosd_ids; do
    kill $kid
    echo "$kid was killed"
done
