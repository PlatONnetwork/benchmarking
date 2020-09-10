#!/bin/bash
for i in {11..36}
do
    node=`grep PublicKey ./addr/10.1.1.${i}.addr |awk '{print $3}'`
    bls=`grep PublicKey ./bls/10.1.1.${i}.bls |awk '{print $3}'`
    echo -e "        {"
    echo -e "          \"node\": \"enode://$node@10.1.1.$i:16789\"",
    echo -e "          \"blsPubKey\": \"$bls\""
    echo -e "        },\n"
done
for i in {141..143}
do
    node=`grep PublicKey ./addr/10.10.8.${i}.addr |awk '{print $3}'`
    bls=`grep PublicKey ./bls/10.10.8.${i}.bls |awk '{print $3}'`
    echo -e "        {"
    echo -e "          \"node\": \"enode://$node@10.10.8.$i:16789\"",
    echo -e "          \"blsPubKey\": \"$bls\""
    echo -e "        },\n"
done
#node=

