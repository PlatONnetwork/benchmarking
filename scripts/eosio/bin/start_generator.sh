#!/usr/bin/env bash
nodeos -d ~/eosio/data/generator --genesis-json ~/eosio/config/genesis.json -c ~/eosio/config/generator.ini -l ~/eosio/config/logging.json > generator.log 2>&1 &
