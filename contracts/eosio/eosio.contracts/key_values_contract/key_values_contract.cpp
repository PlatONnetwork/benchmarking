#include "key_values_contract.hpp"

[[eosio::action]] void key_values_contract::modifys(uint64_t v) {
    eosio::print_f("`modifys` executing.\n");

    uint64_t key = _self.value;

    auto index{ _table.get_index<"index1"_n>() };

    auto iter{ index.find(key) };

    if (iter == _table.get_index<"index1"_n>().end()) {
        _table.emplace(_self, [&](auto& row) {
            row._primary_key = key;
            row._content = v;
        });
    } else {
        index.modify(iter, _self, [&](auto& row) {
            row._content = v;
        });
    }

}

