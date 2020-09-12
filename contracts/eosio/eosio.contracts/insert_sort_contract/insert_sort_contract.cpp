#include <eosio/contract.hpp>
#include <eosio/eosio.hpp>
#include <eosio/action.hpp>
#include <stdio.h>

class [[eosio::contract]] insert_sort_contract : public eosio::contract {
	
    public:
        using contract::contract;

		[[eosio::action]] void sort(int p1) {
			std::vector<int64_t> arr = {6747,2728,9661,6379,9095,3491,4075,6845,8607,5529,5723,200,7682,7410,8036,4170,6357,6883,103,5409};
			long i,j,key;
			long n = 20;
			for(i = 1; i < n; i++)
			{
				key = arr[i];
				j = i - 1;
				while(j >= 0 && arr[j] > key)
				{
					arr[j+1] = arr[j];
					j--;
				}
				arr[j+1] = key;
			}
		}
};
