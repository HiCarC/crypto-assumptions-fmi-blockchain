// SPDX-License-Identifier: Apache-2.0
//! A contract account whose signature scheme can be replaced without changing its address
//! or touching any balance it holds. Tokens and the DvP contract never see the scheme:
//! they call `require_auth`, and the ledger asks this contract to check the signature.
//!
//! Schemes here are the two the Soroban host verifies natively today (Ed25519, ECDSA
//! P-256). Stellar's published plan adds ML-DSA verification as a host function; when it
//! exists, a third arm in `__check_auth` is the whole migration for this account.
//! Reference code for research. Not audited. Not for production use.
#![no_std]
use soroban_sdk::{
    auth::{Context, CustomAccountInterface},
    contract, contracterror, contractimpl, contracttype,
    crypto::Hash,
    BytesN, Env, Vec,
};

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Signer {
    Ed25519(BytesN<32>),
    Secp256r1(BytesN<65>),
}

#[contracttype]
#[derive(Clone)]
pub enum Signature {
    Ed25519(BytesN<64>),
    Secp256r1(BytesN<64>),
}

#[contracttype]
enum DataKey {
    Signer,
}

#[contracterror]
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
#[repr(u32)]
pub enum AccountError {
    SchemeMismatch = 1,
}

#[contract]
pub struct AgileAccount;

#[contractimpl]
impl AgileAccount {
    pub fn __constructor(e: Env, signer: Signer) {
        e.storage().instance().set(&DataKey::Signer, &signer);
    }

    pub fn signer(e: Env) -> Signer {
        e.storage().instance().get(&DataKey::Signer).unwrap()
    }

    /// Replace the key, possibly with one of another scheme. Authorised by the current key.
    pub fn rotate(e: Env, new_signer: Signer) {
        e.current_contract_address().require_auth();
        e.storage().instance().set(&DataKey::Signer, &new_signer);
    }
}

#[contractimpl]
impl CustomAccountInterface for AgileAccount {
    type Signature = Signature;
    type Error = AccountError;

    #[allow(non_snake_case)]
    fn __check_auth(e: Env, payload: Hash<32>, signature: Signature, _contexts: Vec<Context>) -> Result<(), AccountError> {
        let signer: Signer = e.storage().instance().get(&DataKey::Signer).unwrap();
        match (signer, signature) {
            (Signer::Ed25519(pk), Signature::Ed25519(sig)) => e.crypto().ed25519_verify(&pk, &payload.into(), &sig),
            (Signer::Secp256r1(pk), Signature::Secp256r1(sig)) => e.crypto().secp256r1_verify(&pk, &payload, &sig),
            _ => return Err(AccountError::SchemeMismatch),
        }
        Ok(())
    }
}

#[cfg(test)]
mod test;
