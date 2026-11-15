# Daml/Canton powers model (minimal)

Purpose: show who holds which power over a tokenised deposit and a DvP when the ledger is Daml/Canton, for comparison with the EVM model in `../contracts`.

| Power | Who holds it here | How it is granted |
|---|---|---|
| Create, change or archive a holding | issuer **and** owner together | both are signatories; the built-in `Archive` needs both (`test_neither_party_archives_alone`) |
| Move a holding | owner only (`Transfer`), receiver must accept | choice controller; the issuer's authority comes from its signature (`test_issuer_cannot_move_funds`, `test_receiver_must_accept`) |
| Freeze and unfreeze | issuer only (`SetFrozen`) | written into the contract the owner signed (`test_only_issuer_freezes_and_claws_back`) |
| Claw back | issuer alone (`ClawBack`) | same: present only because the owner signed a contract containing it |
| Settle a DvP | seller (proposal signatory) and buyer (choice controller); both legs in one transaction | `test_dvp_settles_both_legs`, `test_frozen_cash_blocks_whole_settlement` |
| Sign for a party | the party's participant node, under the node's keys | outside the model: Canton topology and key management (see `../cbom`, Canton row) |
| Change the code (package upgrade) | not modelled here; see below | — |

Contrast with the EVM model: there, freeze, claw-back and upgrade sit in roles held by addresses that the holder never signed anything for; the holder relies on the token's code and its governance. Here every such power is visible in the contract text the holder signed, and nothing outside that text can bind them. The cryptography protecting the signatures is a different layer: on Canton it is the participant's and synchroniser's keys (Ed25519 or ECDSA in the published scheme list), and changing that layer is a network-governance matter, as on any ledger.

**Package upgrades.** Per the Canton documentation (read 15 Nov 2026, `research/primary/technical.md` item 2), a new package version must pass upgrade-compatibility checks at build time (`upgrades:` in `daml.yaml`) and again when each participant uploads it; there is no separate authorisation ceremony. The upgrade power therefore sits with each participant node's operator. The SDK's `dpm upgrade-check` runs the same check offline.

Run: `dpm build && dpm test` (Daml SDK 3.7.1 via `dpm`). Six tests. Reference code; not for production use.
