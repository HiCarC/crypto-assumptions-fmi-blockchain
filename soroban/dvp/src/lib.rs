// SPDX-License-Identifier: Apache-2.0
//! Delivery versus payment on Soroban. Seller and buyer both authorise the same order;
//! both legs move in one invocation or neither does.
//!
//! Contrast with the EVM version (contracts/src/DvP.sol): there is no signature-checking
//! code here at all. `require_auth` hands verification to each party's ACCOUNT, which on
//! Stellar may be a classic Ed25519 account or a contract account with its own scheme
//! (see ../account). The ledger also consumes each authorisation's nonce itself.
#![no_std]
use soroban_sdk::{contract, contracterror, contractimpl, contracttype, panic_with_error, token, xdr::ToXdr, Address, BytesN, Env};

#[contracttype]
#[derive(Clone)]
pub struct Order {
    pub seller: Address,
    pub buyer: Address,
    pub asset_token: Address,
    pub asset_amount: i128,
    pub cash_token: Address,
    pub cash_amount: i128,
    pub deadline: u64,
    pub nonce: BytesN<32>,
}

#[contracttype]
enum DataKey {
    Settled(BytesN<32>),
}

#[contracterror]
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
#[repr(u32)]
pub enum DvPError {
    Expired = 1,
    AlreadySettled = 2,
    SameParty = 3,
}

#[contract]
pub struct DvP;

#[contractimpl]
impl DvP {
    pub fn settle(e: Env, order: Order) {
        if e.ledger().timestamp() > order.deadline {
            panic_with_error!(&e, DvPError::Expired);
        }
        if order.seller == order.buyer {
            panic_with_error!(&e, DvPError::SameParty);
        }
        let id: BytesN<32> = e.crypto().sha256(&order.clone().to_xdr(&e)).into();
        let key = DataKey::Settled(id);
        if e.storage().persistent().has(&key) {
            panic_with_error!(&e, DvPError::AlreadySettled);
        }
        // Each party authorises this exact call with this exact order.
        order.seller.require_auth();
        order.buyer.require_auth();
        e.storage().persistent().set(&key, &true);

        token::TokenClient::new(&e, &order.asset_token).transfer(&order.seller, &order.buyer, &order.asset_amount);
        token::TokenClient::new(&e, &order.cash_token).transfer(&order.buyer, &order.seller, &order.cash_amount);
    }
}

#[cfg(test)]
mod test;
