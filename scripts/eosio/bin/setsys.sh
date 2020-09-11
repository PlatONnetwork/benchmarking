#!/usr/bin/env bash
cleos set contract eosio /home/jht/eosio/eosio.contracts/build/contracts/eosio.system -p eosio
cleos push action eosio init '[0,"4,SYS"]' -p eosio@active
