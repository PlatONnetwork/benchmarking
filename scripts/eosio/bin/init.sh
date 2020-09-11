#!/usr/bin/env bash
$HOME/eosio/bin/stopall.sh
$HOME/eosio/bin/cleardata.sh
sleep 2
$HOME/eosio/bin/start_producer.sh
$HOME/eosio/bin/unlock.sh
sleep 6
cleos create account eosio eosio.bpay EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.msig EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.names EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.ram EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.ramfee EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.saving EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.stake EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.token EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.vpay EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.rex EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do
cleos create account eosio eosio.kv EOS7D9f5kV9o99RVUpNBJmzRzxH68MpHxstunzgTUgE49TYMPp2do

curl -X POST http://127.0.0.1:8888/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}' | jq
sleep 4

cleos set contract eosio $HOME/eosio/eosio.contracts/build/contracts/eosio.boot/ -p eosio@active

cleos push transaction '{"delay_sec":0,"max_cpu_usage_ms":0,"actions":[{"account":"eosio","name":"activate","data":{"feature_digest":"299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"},"authorization":[{"actor":"eosio","permission":"active"}]}]}'
sleep 4
cleos set contract eosio $HOME/eosio/eosio.contracts/build/contracts/eosio.bios/ -p eosio
cleos set contract eosio.token $HOME/eosio/eosio.contracts/build/contracts/eosio.token -p eosio.token
cleos set contract eosio.kv $HOME/eosio/eosio.contracts/key_values_contract -p eosio.kv
cleos push action eosio.token create '["eosio", "100000000000.0000 SYS"]' -p eosio.token
cleos push action eosio.token issue '["eosio","100000000000.0000 SYS","issue"]' -p eosio

$HOME/eosio/bin/start_generator.sh

sleep 8
curl --data-binary '["eosio", "5J3kr9m8oA4SdxLwGG2v8grqCsHs1ieNGWsmmAgAGq9S7hepm5H"]' http://127.0.0.1:6666/v1/txn_test_gen/create_newAccountT
sleep 2
curl --data-binary '["eosio", "5J3kr9m8oA4SdxLwGG2v8grqCsHs1ieNGWsmmAgAGq9S7hepm5H"]' http://127.0.0.1:6666/v1/txn_test_gen/create_test_accounts
sleep 8
curl --data-binary '["eosio", "5J3kr9m8oA4SdxLwGG2v8grqCsHs1ieNGWsmmAgAGq9S7hepm5H"]' http://127.0.0.1:6666/v1/txn_test_gen/init_test_accounts
