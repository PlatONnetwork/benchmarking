#!/usr/bin/env bash
$HOME/eosio/bin/stopall.sh
sleep 1
$HOME/eosio/bin/start_producer.sh
$HOME/eosio/bin/start_generator.sh
