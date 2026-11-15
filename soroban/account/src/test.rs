extern crate std;
use crate::{AccountError, AgileAccount, AgileAccountClient, Signature, Signer};
use ed25519_dalek::{Signer as _, SigningKey};
use p256::ecdsa::{signature::hazmat::PrehashSigner, Signature as P256Sig, SigningKey as P256Key};
use soroban_sdk::{testutils::BytesN as _, vec, BytesN, Env, IntoVal};

// TEST KEYS ONLY: fixed public byte patterns.
fn ed_key() -> SigningKey {
    SigningKey::from_bytes(&[7u8; 32])
}
fn p256_key() -> P256Key {
    P256Key::from_slice(&[9u8; 32]).unwrap()
}
fn ed_sig(e: &Env, payload: &BytesN<32>) -> Signature {
    Signature::Ed25519(BytesN::from_array(e, &ed_key().sign(&payload.to_array()).to_bytes()))
}
fn p256_sig(e: &Env, payload: &BytesN<32>) -> Signature {
    let s: P256Sig = p256_key().sign_prehash(&payload.to_array()).unwrap();
    let s = s.normalize_s().unwrap_or(s); // the host requires low-s
    Signature::Secp256r1(BytesN::from_array(e, &s.to_bytes().into()))
}
fn p256_pub(e: &Env) -> Signer {
    let pt = p256_key().verifying_key().to_encoded_point(false);
    Signer::Secp256r1(BytesN::from_array(e, pt.as_bytes().try_into().unwrap()))
}

#[test]
fn scheme_changes_address_does_not() {
    let e = Env::default();
    let id = e.register(AgileAccount, (Signer::Ed25519(BytesN::from_array(&e, ed_key().verifying_key().as_bytes())),));
    let acct = AgileAccountClient::new(&e, &id);
    let payload = BytesN::<32>::random(&e);
    let check = |sig: Signature| e.try_invoke_contract_check_auth::<AccountError>(&id, &payload, sig.into_val(&e), &vec![&e]);

    assert!(check(ed_sig(&e, &payload)).is_ok());
    assert_eq!(check(p256_sig(&e, &payload)), Err(Ok(AccountError::SchemeMismatch)));

    e.mock_all_auths();
    acct.rotate(&p256_pub(&e)); // same account address, new scheme
    assert_eq!(acct.address, id);
    assert_eq!(acct.signer(), p256_pub(&e));

    assert!(check(p256_sig(&e, &payload)).is_ok());
    assert_eq!(check(ed_sig(&e, &payload)), Err(Ok(AccountError::SchemeMismatch)), "old key no longer authorises");
}

#[test]
fn wrong_key_and_wrong_message_are_rejected() {
    let e = Env::default();
    let id = e.register(AgileAccount, (Signer::Ed25519(BytesN::from_array(&e, ed_key().verifying_key().as_bytes())),));
    let payload = BytesN::<32>::random(&e);
    let other = BytesN::<32>::random(&e);
    let forged = Signature::Ed25519(BytesN::from_array(&e, &SigningKey::from_bytes(&[8u8; 32]).sign(&payload.to_array()).to_bytes()));
    assert!(e.try_invoke_contract_check_auth::<AccountError>(&id, &payload, forged.into_val(&e), &vec![&e]).is_err());
    assert!(e.try_invoke_contract_check_auth::<AccountError>(&id, &other, ed_sig(&e, &payload).into_val(&e), &vec![&e]).is_err());
}

#[test]
fn rotation_needs_the_accounts_own_authorisation() {
    let e = Env::default();
    let id = e.register(AgileAccount, (Signer::Ed25519(BytesN::from_array(&e, ed_key().verifying_key().as_bytes())),));
    assert!(AgileAccountClient::new(&e, &id).try_rotate(&p256_pub(&e)).is_err()); // no auth supplied
}
