| Platform | Signature schemes | Who can freeze or claw back | Who can upgrade | Who sets signer / transaction policy | Post-quantum roadmap |
|---|---|---|---|---|---|
| Ethereum L1 | ECDSA secp256k1 (accounts); BLS12-381 (consensus) [R] | none at protocol level found [U] | hard fork adopted by client teams and node operators [R] | each key holder [R] | yes: hash-based consensus signatures in development; ML-DSA and Falcon precompiles proposed (EIP-8051, EIP-8052); no committed date [R] |
| Base | as Ethereum accounts [R] | not found [U] | Coordinator multisig plus Security Council; no delay [R] | not found [U] | not found [U] |
| Arbitrum One | as Ethereum accounts [R] | not found [U] | DAO path with about 17-day delay; Security Council 9 of 12 with no delay [R] | not found [U] | not found [U] |
| Linea | as Ethereum accounts [R] | not found [U] | Linea Security Council; no delay [R] | not found [U] | not found [U] |
| ZKsync Era | as Ethereum accounts [R] | not found [U] | standard path with a delay of several days; emergency board with no delay [R] | not found [U] | not found [U] |
| ZKsync Prividium | not found [U] | not found [U] | not found [U] | chain operator and its permissioning administrators [V] | not found [U] |
| Bitcoin | ECDSA and Schnorr on secp256k1 [R] | none found [U] | soft or hard fork adopted by node operators and miners [R] | each key holder [R] | proposal only: BIP-360 (draft) hides public keys until spend; contains no post-quantum signature [V] |
| Stellar | Ed25519 [R] | the asset's issuer, if it enabled revocation and clawback flags [V] | validator vote [R] | issuer for its asset; account holder for its signers [V] | yes: ML-DSA verification in contracts planned for 2026, quantum-safe account signers for 2027 [V] |
| Hedera | not found [U] | holder of the token's freeze key, if one was set [R] | Governing Council [R] | key holders per token [R] | not found [U] |
| XRP Ledger | not found [U] | the issuer (freeze; clawback only if enabled before issuance) [R] | amendment voting by validators [U] | not found [U] | not found [U] |
| Solana (Token-2022) | not found [U] | the mint's freeze authority; a permanent delegate can move or burn [R] | not found [U] | not found [U] | not found [U] |
| USDC (Circle) | as host chain [R] | Circle (block-listing and freezing, per its terms) [V] | not stated in the terms [U] | Circle [V] | not found [U] |
| USDT (Tether) | as host chain [R] | Tether (freeze and blacklist, per its terms) [V] | not found [U] | Tether [V] | not found [U] |
| Canton Network / Global Synchronizer | Ed25519 (default); ECDSA P-256 (cloud KMS default), P-384, secp256k1 [V] | not defined at network level; set per application [U] | Super Validator governance vote; who controls the software itself is not stated [V] | Super Validator vote for network settings; detail not stated [V] | none in the published cryptographic-schemes reference [V] |
| Kinexys by J.P. Morgan (JPMD) | as host chain [R] | the bank as issuer; mechanism not found [U] | not found [U] | J.P. Morgan (permissioned access) [R] | not found [U] |
| Citi Token Services | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
| Swift shared ledger | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
| HSBC Orion / Tokenised Deposit Service | not found [U] | HSBC (private chain managed by the bank) [R] | not found [U] | HSBC [R] | not found [U] |
| Clearstream D7 DLT | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
| Partior | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
| Fnality (Sterling) | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
| Broadridge DLR | as Canton [R] | not found [U] | as Canton [R] | not found [U] | not found [U] |
| DTCC tokenisation service | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
| Eurosystem Pontes | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
| Digital euro | not found [U] | not found [U] | not found [U] | not found [U] | cryptographic agility stated as a design aim; no algorithm named [R] |
| BIS Project Agorá | not found [U] | not found [U] | not found [U] | not found [U] | none on the report page [V] |
| mBridge | not found [U] | not found [U] | not found [U] | not found [U] | not found [U] |
