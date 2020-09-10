#!/bin/bash
  
##gather nodes's info for validate files
 cat host|while read LINE
 do
       host=($LINE)
       echo "node_${host}">>./publickey.txt
       echo "">>./publickey.txt
       echo "nodeAddress:${host}">>./publickey.txt
       echo "nodePort:16789">>./publickey.txt
       echo "nodeRpcPort:6789">>./publickey.txt
       cat ./addr/${host}.addr|grep PublicKey|sed 's/PublicKey :  /nodePublicKey:/g'>>./publickey.txt
       cat ./bls/${host}.bls|grep PublicKey|sed 's/PublicKey :  /blsPubKey:/g'>>./publickey.txt
       echo "_______________________________">>./publickey.txt
done

mkdir ./gen_validator
cp publickey.txt ./gen_validator/

