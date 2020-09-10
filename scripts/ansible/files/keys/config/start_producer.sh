#!/usr/bin/env bash
/home/pchuant/eosio/2.0/bin/nodeos -d /home/pchuant/eosio/data/producer --genesis-json /home/pchuant/eosio/config/genesis.json -c /home/pchuant/eosio/config/producer.ini -l /home/pchuant/eosio/config/logging.json > /home/pchuant/eosio/bin/producer.log 2>&1 &
