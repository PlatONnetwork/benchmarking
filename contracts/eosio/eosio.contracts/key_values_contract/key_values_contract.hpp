#include <eosio/contract.hpp>         // eosio::contract
#include <eosio/datastream.hpp>       // eosio::datastream
#include <eosio/name.hpp>             // eosio::name
#include <eosio/multi_index.hpp>      // eosio::indexed_by, eosio::multi_index
#include <eosio/print.hpp>            // eosio::print_f
#include <eosio/eosio.hpp>
#include <eosio/action.hpp>
#include <eosio/crypto.hpp>
#include <eosio/fixed_bytes.hpp>
#include <eosio/privileged.hpp>
#include <eosio/producer_schedule.hpp>
#include <stdio.h>

using eosio::checksum256;

class [[eosio::contract]] key_values_contract : public eosio::contract {
public:
   using contract::contract;
   key_values_contract(eosio::name receiver, eosio::name code, eosio::datastream<const char*> ds)
      : contract{receiver, code, ds}, _table{receiver, receiver.value}
   { }

   [[eosio::action]] void modifys(uint64_t v); 

   struct [[eosio::table]] structure {
       uint64_t  _primary_key;
       uint64_t  _content;

       uint64_t primary_key()   const { return _primary_key;   }
       uint64_t content() const { return _content; }
   };

   using index1 = eosio::indexed_by<"index1"_n, eosio::const_mem_fun<structure, uint64_t, &structure::primary_key>>;
   using table  = eosio::multi_index<"table"_n, structure, index1>;

private:
   table _table;
};
