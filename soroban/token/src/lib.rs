// SPDX-License-Identifier: Apache-2.0
// Generated with the OpenZeppelin Contracts Wizard for Stellar (via the OpenZeppelin MCP
// server) on 15 November 2026, options: roles, mintable, burnable, pausable, upgradeable.
// Compatible with OpenZeppelin Stellar Soroban Contracts ^0.7.2. Unmodified apart from this header.
#![no_std]

use soroban_sdk::{
    Address, BytesN, contract, contractimpl, Env, MuxedAddress, String, Symbol, Vec
};
use stellar_access::access_control::{self as access_control, AccessControl};
use stellar_contract_utils::pausable::{self as pausable, Pausable};
use stellar_contract_utils::upgradeable::{self as upgradeable, Upgradeable};
use stellar_macros::{only_role, when_not_paused};
use stellar_tokens::fungible::{Base, burnable::FungibleBurnable, FungibleToken};

#[contract]
pub struct SettlementToken;

#[contractimpl]
impl SettlementToken {
    pub fn __constructor(e: &Env, admin: Address, pauser: Address, upgrader: Address, minter: Address) {
        Base::set_metadata(e, 7, String::from_str(e, "SettlementToken"), String::from_str(e, "tdEUR"));
        access_control::set_admin(e, &admin);
        access_control::grant_role_no_auth(e, &pauser, &Symbol::new(e, "pauser"), &admin);
        access_control::grant_role_no_auth(e, &upgrader, &Symbol::new(e, "upgrader"), &admin);
        access_control::grant_role_no_auth(e, &minter, &Symbol::new(e, "minter"), &admin);
    }

    #[only_role(caller, "minter")]
    #[when_not_paused]
    pub fn mint(e: &Env, account: Address, amount: i128, caller: Address) {
        Base::mint(e, &account, amount);
    }
}

#[contractimpl(contracttrait)]
impl FungibleToken for SettlementToken {
    type ContractType = Base;

    #[when_not_paused]
    fn transfer(e: &Env, from: Address, to: MuxedAddress, amount: i128) {
        Self::ContractType::transfer(e, &from, &to, amount);
    }

    #[when_not_paused]
    fn transfer_from(e: &Env, spender: Address, from: Address, to: Address, amount: i128) {
        Self::ContractType::transfer_from(e, &spender, &from, &to, amount);
    }
}

//
// Extensions
//

#[contractimpl(contracttrait)]
impl FungibleBurnable for SettlementToken {
    #[when_not_paused]
    fn burn(e: &Env, from: Address, amount: i128) {
        Base::burn(e, &from, amount);
    }

    #[when_not_paused]
    fn burn_from(e: &Env, spender: Address, from: Address, amount: i128) {
        Base::burn_from(e, &spender, &from, amount);
    }
}

//
// Utils
//

#[contractimpl(contracttrait)]
impl AccessControl for SettlementToken {}

#[contractimpl]
impl Pausable for SettlementToken {
    fn paused(e: &Env) -> bool {
        pausable::paused(e)
    }

    #[only_role(caller, "pauser")]
    fn pause(e: &Env, caller: Address) {
        pausable::pause(e);
    }

    #[only_role(caller, "pauser")]
    fn unpause(e: &Env, caller: Address) {
        pausable::unpause(e);
    }
}

#[contractimpl]
impl Upgradeable for SettlementToken {
    #[only_role(operator, "upgrader")]
    fn upgrade(e: &Env, new_wasm_hash: BytesN<32>, operator: Address) {
        upgradeable::upgrade(e, &new_wasm_hash);
    }
}
