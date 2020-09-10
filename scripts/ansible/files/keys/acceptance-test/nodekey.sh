#!/bin/bash
function getkey()
{  
##special nodes's dir is /opt/splaton; other nodes's dir is /opt/platon ; 
remotedir=$1
read -p"Please input the login user:" user
[ ! -d "./nodekey" ] && mkdir ./nodekey
[ ! -d "./nodeblskey" ] && mkdir ./nodeblskey

while read LINE  
do
  host=($LINE)

##get and distribute nodekeys
  # ./keytool genkeypair >./addr/${host}.addr
  # grep PrivateKey ./addr/${host}.addr |sed 's/PrivateKey:  //g'>./nodekey/${host}.key
  scp -o StrictHostKeyChecking=no ./nodekey/${host}.key $user@${host}:${remotedir}/nodekey.txt

##get and distribute nodeblskeys
  # ./keytool genblskeypair >./bls/${host}.bls
  # grep PrivateKey ./bls/${host}.bls |sed 's/PrivateKey:  //g'>./nodeblskey/${host}.bls
  scp -o StrictHostKeyChecking=no ./nodeblskey/${host}.bls $user@${host}:${remotedir}/nodeblskey.txt

done <host
}

case $1 in
    getkey)
		getkey $2
		;;
    *)
        echo "no"
		;;
esac
