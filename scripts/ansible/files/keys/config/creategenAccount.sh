#!/usr/bin/env bash
curl --data-binary '["eosio", "5J3kr9m8oA4SdxLwGG2v8grqCsHs1ieNGWsmmAgAGq9S7hepm5H"]' http://127.0.0.1:6666/v1/txn_test_gen/create_test_accounts
sleep 8
curl --data-binary '["eosio", "5J3kr9m8oA4SdxLwGG2v8grqCsHs1ieNGWsmmAgAGq9S7hepm5H"]' http://127.0.0.1:6666/v1/txn_test_gen/init_test_accounts
