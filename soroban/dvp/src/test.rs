extern crate std;
use crate::{DvP, DvPClient, Order};
use fmi_token::{SettlementToken, SettlementTokenClient};
use soroban_sdk::{testutils::{Address as _, Ledger}, Address, BytesN, Env};

struct World<'a> {
    e: Env,
    dvp: DvPClient<'a>,
    asset: SettlementTokenClient<'a>,
    cash: SettlementTokenClient<'a>,
    seller: Address,
    buyer: Address,
    pauser: Address,
}

fn world<'a>() -> World<'a> {
    let e = Env::default();
    e.mock_all_auths();
    let (admin, pauser, upgrader, minter) = (Address::generate(&e), Address::generate(&e), Address::generate(&e), Address::generate(&e));
    let args = (admin.clone(), pauser.clone(), upgrader.clone(), minter.clone());
    let asset = SettlementTokenClient::new(&e, &e.register(SettlementToken, args.clone()));
    let cash = SettlementTokenClient::new(&e, &e.register(SettlementToken, args));
    let dvp = DvPClient::new(&e, &e.register(DvP, ()));
    let (seller, buyer) = (Address::generate(&e), Address::generate(&e));
    asset.mint(&seller, &100, &minter);
    cash.mint(&buyer, &5_000, &minter);
    World { e, dvp, asset, cash, seller, buyer, pauser }
}

fn order(w: &World, asset_amount: i128, cash_amount: i128, nonce: u8) -> Order {
    Order {
        seller: w.seller.clone(),
        buyer: w.buyer.clone(),
        asset_token: w.asset.address.clone(),
        asset_amount,
        cash_token: w.cash.address.clone(),
        cash_amount,
        deadline: w.e.ledger().timestamp() + 3600,
        nonce: BytesN::from_array(&w.e, &[nonce; 32]),
    }
}

#[test]
fn settle_moves_both_legs_and_requires_both_parties() {
    let w = world();
    w.dvp.settle(&order(&w, 10, 1_000, 1));
    // The host recorded an authorisation by each party for the settle call.
    let auths = w.e.auths();
    assert!(auths.iter().any(|(a, _)| *a == w.seller) && auths.iter().any(|(a, _)| *a == w.buyer));
    assert_eq!((w.asset.balance(&w.buyer), w.asset.balance(&w.seller)), (10, 90));
    assert_eq!((w.cash.balance(&w.seller), w.cash.balance(&w.buyer)), (1_000, 4_000));
}

#[test]
fn cash_leg_failure_unwinds_asset_leg() {
    let w = world();
    assert!(w.dvp.try_settle(&order(&w, 10, 6_000, 1)).is_err()); // buyer holds 5,000
    assert_eq!((w.asset.balance(&w.seller), w.asset.balance(&w.buyer)), (100, 0));
    assert_eq!(w.cash.balance(&w.buyer), 5_000);
}

#[test]
fn replay_expiry_and_self_dealing_are_rejected() {
    let w = world();
    let o = order(&w, 10, 1_000, 1);
    w.dvp.settle(&o);
    assert!(w.dvp.try_settle(&o).is_err());

    let late = order(&w, 1, 1, 2);
    w.e.ledger().with_mut(|l| l.timestamp += 7200);
    assert!(w.dvp.try_settle(&late).is_err());

    let mut own = order(&w, 1, 1, 3);
    own.buyer = own.seller.clone();
    assert!(w.dvp.try_settle(&own).is_err());
}

#[test]
fn paused_token_blocks_the_whole_settlement() {
    let w = world();
    w.cash.pause(&w.pauser);
    assert!(w.dvp.try_settle(&order(&w, 10, 1_000, 1)).is_err());
    assert_eq!(w.asset.balance(&w.seller), 100);
}

#[test]
fn without_authorisation_nothing_moves() {
    let w = world();
    w.e.set_auths(&[]); // no party has authorised anything
    assert!(w.dvp.try_settle(&order(&w, 10, 1_000, 1)).is_err());
    assert_eq!((w.asset.balance(&w.seller), w.cash.balance(&w.buyer)), (100, 5_000));
}
