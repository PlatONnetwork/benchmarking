#!/bin/bash
function getkey()
{  
##special nodes's dir is /opt/splaton; other nodes's dir is /opt/platon ; 
remotedir=/opt/platon7
read -p"Please input the login user:" user
[ ! -d "./addr" ] && mkdir ./addr
[ ! -d "./bls" ] && mkdir ./bls
[ ! -d "./nodekey" ] && mkdir ./nodekey
[ ! -d "./nodeblskey" ] && mkdir ./nodeblskey

while read LINE  
do
  host=($LINE)

##get and distribute nodekeys
  ./keytool genkeypair >./addr/${host}.addr
  grep PrivateKey ./addr/${host}.addr |sed 's/PrivateKey:  //g'>./nodekey/${host}.key
  scp -o StrictHostKeyChecking=no ./nodekey/${host}.key $user@${host}:${remotedir}/nodekey.txt

##get and distribute nodeblskeys
  ./keytool genblskeypair >./bls/${host}.bls
  grep PrivateKey ./bls/${host}.bls |sed 's/PrivateKey:  //g'>./nodeblskey/${host}.bls
  scp -o StrictHostKeyChecking=no ./nodeblskey/${host}.bls $user@${host}:${remotedir}/nodeblskey.txt

done <host
}
function keytodev(){
##gather seed nodes's and fdn nodes's info for dev
 cat host|while read LINE
 do
       host=($LINE)
       node_id=`cat ./addr/${host}.addr|grep PublicKey|sed 's/PublicKey :  //g'`
       blspubkey=`cat ./bls/${host}.bls|grep PublicKey|sed 's/PublicKey :  //g'`
       echo "${node_id}    ${blspubkey}   ${host}  16789">>./key2dev.txt
done
}
function publickey(){
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
}
case $1 in
    keytodev)
        keytodev
    ;;
    getkey)
	getkey
    ;;
    *)
        echo "no"
    ;;
esac
