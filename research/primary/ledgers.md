# Who holds which power: ledger / FMI inventory (primary sources)

Compiled 2026-11-15. All "date" fields = access date 2026-11-15 unless a publication date is given.

Labels
- V  = official/primary page fetched and read in full this run.
- R  = secondary source only, OR official-domain page seen only as a search-result excerpt (page body not fetched/blocked). Treat as unverified.
- U  = not publicly documented (where a source says so or nothing was found in an official source searched).
- U* = NOT RETRIEVED in this run (budget/blocked). This does NOT mean non-public. Must be filled before use.

Retrieval problems affecting the file
- l2beat.com URLs (base, arbitrum, linea, zksync-era) return 301 to ethbeat.org (a different domain; not followed, not treated as L2BEAT). L2 rows therefore rest on search-engine excerpts of l2beat.com pages (R) only.
- swift.com press/product pages returned HTTP 403 to fetch; Swift rows rest on search excerpts of swift.com (R).
- solana.com permanent-delegate page returned HTTP 429.
- xrpl.org clawback concept URL 404; XRPL rows from search excerpts of xrpl.org (R).

---------------------------------------------------------------------
## PUBLIC LEDGERS

### Ethereum L1
- (a) live. U* (ethereum.org status page not fetched; live is not in doubt but unlabelled here).
- (b)-(e) account/EVM chain, PoS. Signature/hash/consensus/privacy details: U* (not fetched this run).
- (g) freeze/claw back at protocol level: U* (not fetched).
- (h) upgrade: social-consensus hard forks via client teams/EIPs; details U*.
- (j) PQ roadmap: R. ethereum.org/roadmap/security/quantum-resistance and pq.ethereum.org (search excerpts, 2026-11-15): "Lean Ethereum" plan; consensus-layer BLS to hash-based leanXMSS; staged milestones (PQ key registry, PQ sig precompiles, PQ attestations/aggregation via SNARKs, leanVM); EIP-8051 (ML-DSA precompile) and EIP-8052 (Falcon precompile) proposed; target ~2029 comes from a Justin Drake interview, described as his own target, not a formal commitment. Label R (excerpts only).
- (k) incidents/audits: U*.

### Base (OP Stack L2) - R (l2beat excerpt via search, cached, possibly stale)
- (a) live. (b) Ethereum L2 rollup. (c)-(e) U*.
- (h) upgrades need two-party approval by Base Coordinator Multisig + Base Security Council; no delay, no exit window (l2beat.com/layer2s/projects/base excerpt).
- (g) freeze: U*. (i) sequencer/tx policy: U*. Stage and proof system: U* (excerpt did not state).
- (j) U*. (k) U*.

### Arbitrum One - R
- (a) live. (b) Ethereum L2 optimistic rollup.
- (h) 17d 8h delay on code upgrades unless initiated by the Security Council (9/12, instant, no timelock/no exit window) (l2beat excerpt).
- Stage/proof system/freeze/PQ/audits: U*.

### Linea - R
- (a) live. (b) Ethereum L2 zk-rollup. (h) Linea Security Council, 0s delay on code upgrades (l2beat excerpt). Rest U*.

### ZKsync Era - R
- (a) live. (b) Ethereum L2 zk-rollup.
- (h) delay on code upgrades 4d3h-8d3h in one cached copy (5d-9d in an older snapshot) unless initiated by EmergencyUpgradeBoard (no delay); emergency path needs Security Council + Guardians + ZKsync Foundation multisig. A l2beat forum post (~650 days old) argued Era could not be Stage 1 because a Security Council supermajority is needed to disable a malicious TransactionFilterer. Current stage: U*.
- Rest U*.

### ZKsync Prividium - V (docs fetched) / R (search)
- Source: https://docs.zksync.io/zk-stack/prividium/architecture (V, fetched) and /overview, /features (R, excerpts).
- (a) product/framework; live status of specific deployments U*. (b) permissioned Validium settling to Ethereum; state, calldata held in operator-controlled off-chain DB (R). Sequencer + prover run inside the operating organisation (V).
- (c) V page does NOT name proof system; search excerpt says STARK proof posted by relayer (R). Signature/hash: U.
- (e) privacy = access control, not cryptographic: Proxy RPC validates tokens (Okta SSO or SIWE) and enforces role/argument-level rules; L1 sees only state roots, proofs, metadata (V/R).
- (f) U. (g) freeze/admin: admins define users/roles/permissions via Admin Dashboard (V); asset freeze power: U. (h) upgrade: U in architecture page. (i) tx/signer policy: chain operator via permissioning system (V). (j) U. (k) U*.

### Bitcoin
- All fields except PQ: U* (not fetched).
- (j) PQ: R. BIP-360 "Pay-to-Merkle-Root (P2MR)", status Draft v0.12.1 per bips.dev mirror (not the bitcoin/bips repo): new SegWit v2 output removing key-path spend to avoid public-key exposure; does not address short-exposure attacks; PQ signatures left for a future proposal. No activation. Label R.

### Stellar
- Clawback/authorization: V. https://developers.stellar.org/docs/learn/fundamentals/transactions/list-of-operations (fetched). Only the issuer account can Clawback (burns from holder) and use SetTrustLineFlags. Revoking trustline authorization requires AUTH_REVOCABLE on the issuer; AUTH_CLAWBACK_ENABLED requires AUTH_REVOCABLE; clawback fails unless trustline clawback-enabled; claimable-balance clawback needs CLAIMABLE_BALANCE_CLAWBACK_ENABLED; no issuer "freeze" op per se (revoke/maintain-offers flag instead). Separately network-config trustline freezes (CAP-77) are not issuer-controlled (V statement on page).
- Upgrades/consensus: R (stellar.org + developers.stellar.org excerpts): protocol upgrades and Soroban settings changes need validator consensus via SCP vote; SCP messages authenticated with Ed25519 (R from quantum plan post).
- (j) PQ: R. stellar.org "Quantum Preparedness Plan": Stage 1 (2026) ML-DSA-44/65 verification host functions in Soroban; by end 2027 every account able to add a quantum-safe signer; detailed specs to follow; no CAP/vote found.
- Soroban details, audits, incidents: U*.

### Hedera
- R. HTS freeze key is optional per token; freezes one account for that token only; if no key defined, no freeze ability; contracts may freeze only if listed as key (docs.hedera.com excerpts).
- Governance: off-chain Governing Council, votes signed on-chain; council-signed upgrade after 2022 precompile attack (mainnet upgrade completed 41h after discovery); upgrades require 5 business days' notice (blog excerpts, R, 2020-2023 sources).
- Everything else incl. PQ: U*.

### XRP Ledger
- R (xrpl.org search excerpts): Individual Freeze, Deep Freeze, Global Freeze (issuer-only AccountSet); No Freeze flag permanently removes issuer freeze ability; Clawback only if Allow Trust Line Clawback was set before any issuance; clawback and No Freeze mutually exclusive; clawback works on frozen balances; MPTs use locking per issuance. Direct clawback concept page URL 404 so not V.
- Upgrade (amendments/validator voting), PQ, audits: U*.

### Solana (Token-2022)
- R (solana.com excerpts; direct page 429): freeze authority is optional mint-level authority to freeze token accounts; permanent delegate can transfer/burn for all token accounts of the mint (claw-back); Token ACL transfers freeze authority to a PDA config; default-frozen accounts need thaw by freeze authority. DvP docs list freeze/pause/permanent delegate as risks to escrowed tokens.
- Protocol upgrade, consensus assumptions, PQ, incidents: U*.

### Polygon (PoS)
- R (forum.polygon.technology / polygon.technology excerpts): governance via PIP process; Protocol Council multisig with timelock (PIP-77 Feb 2026 changes signer composition, timelock unchanged); a PIP on recovery of funds held in blocked addresses (Polymarket/Binance incidents) is consensus-breaking, presentation scheduled 5 Nov 2026 - outcome U*. This shows a validator-adopted fork path for moving funds.
- PQ: no source found (U). Rest U*.

### Avalanche
- R (build.avax.network excerpts): Snowman/Snowman++ consensus, stake-weighted sampled proposer; upgrades via ACPs (e.g. Helicon bundle, ACP-267 uptime 80->90%). PQ: only community forum idea AIP-QR-001 (dual ECDSA + Falcon/Dilithium); not adopted. No official PQ page found (U).

---------------------------------------------------------------------
## STABLECOINS (freeze-key examples)

### USDC (Circle)
- (g) V. https://www.circle.com/legal/usdc-terms (fetched): Sec. 13 - Circle may block addresses and, for Circle-custodied addresses, freeze USDC temporarily or permanently, at its sole discretion if tied to illegal activity/terms violations, or on valid government legal order. "Blocklisting" subsection reserves right to block transfers to/from an address on chain.
- (h) V: terms give right to migrate USDC to another chain/protocol (Sec. 9) and to choose fork support (Sec. 8); no statement of contract upgrade mechanism or delay in terms -> U for delay/key holder.
- Contract-level admin/blacklister keys, audits: U* (not read from Circle docs).

### USDT (Tether)
- (g) V. https://tether.to/en/legal/ (fetched): Tether may freeze tokens held by a user (prudence/legal requirement), blacklist addresses on suspected prohibited use, bar transactions at any time subject to law, "freeze or seize and recover"; disclaims liability for freezes. Terms do not describe burning, contract upgrade, or key holders -> U for those.

---------------------------------------------------------------------
## INSTITUTIONAL

### Canton Network / Global Synchronizer
- (a) live. (b) Canton (Daml) privacy-enabled network; Global Synchronizer run by Super Validators. R/V mix.
- (c) V. https://docs.canton.network/global-synchronizer/reference/crypto-schemes.md (fetched): signing key specs EC-Curve25519, EC-P256, EC-P384, EC-Secp256k1; algorithms Ed25519, EC-DSA-SHA256, EC-DSA-SHA384; asymmetric encryption ECIES-HMAC-SHA256-AES128-CBC (P-256), RSA-OAEP-SHA256 (RSA-2048); symmetric AES128-GCM (fixed); hash SHA-256 (fixed); PBKDF Argon2id (fixed). Defaults: JCE Ed25519; AWS/GCP KMS EC-DSA-SHA256 on P-256.
- (d) V. https://docs.canton.network/global-synchronizer/understand/overview.md: BFT ordering/confirmation requiring 2/3 majority; security assumes 2/3 honest.
- (e) privacy: sub-transaction privacy by design (page "what-is-canton" not fetched) U*.
- (f) R: docs.canton.network/global-synchronizer/production-operations/key-management and docs.digitalasset.com 3.4/3.5 excerpts: key usages Namespace, SequencerAuthentication, Protocol; KMS support; 3.5 offline root key procedure moved from P-256 to Ed25519.
- (g) freeze/claw back at network level: U (not stated; asset-level controls are per Daml application). (h) V: overview says validators coordinate upgrades/migrations; who can change software: not specified on that page -> U. Governance: on-chain governance app, BFT majority vote of SVs; Canton Foundation coordinates with Linux Foundation and runs an SV (V). (i) topology/policy holder: not specified (V says so) -> U beyond "SV governance vote".
- (j) PQ: crypto-schemes page does not mention PQ (V negative).  (k) U*.

### Kinexys by J.P. Morgan / JPM Coin (JPMD)
- (a) JPMD live on Base (institutional clients; launch/availability per jpmorgan.com newsroom, search excerpts, R), and live on Ethereum L1 (jpmorgan.com "jpm-coin-live-on-ethereum", ~Oct 2026, R). Canton: announced 7 Jan 2026 intention to issue natively on Canton with phased 2026 rollout (secondary coverage: The Block, Decrypt; the jpmorgan.com results did not show it) - status "announced", completion U*.
- (b) permissioned deposit token on public chains (access restricted to approved institutional clients) R.
- (g) freeze: issuer is the bank; mechanism U*. (h) upgrade/signer policy: U*. (c)(d)(f)(j)(k): U*.

### Citi Token Services
- R (citigroup.com press-release titles via search): live in 7 markets (US, Ireland, HK, Singapore, UK, Japan, UAE) per Q3 2026 earnings call (13 Oct 2026) and 28 Sep 2026 release; Citi live transactions on Swift ledger (pilot July-Dec 2026, ~$1bn processed per excerpt). Ledger technology, crypto, freeze, upgrade, PQ, audits: U*.

### Swift blockchain shared ledger
- (a) R (swift.com press release 9 Jul 2026, excerpt only; fetch 403): "ready for initial use"; 17 banks (ANZ, BNP Paribas, BNY, Citi, DBS, FAB, FirstRand, Itau Unibanco, HSBC, Lloyds, Mashreq, MUFG, OCBC, Standard Chartered, UBS, UOB, Wells Fargo) preparing to pilot live transactions; orchestration layer for bank-issued tokenised deposits on banks' own ledgers; final settlement remains in existing systems. Swift blog says ledger live and used by early adopters. So "pilot reported live 9 July 2026" is consistent with swift.com excerpts but not read in full.
- (b) Consensys/Besu/permissioned: NOT CONFIRMED on swift.com. swift.com Sept 2025 release excerpt says Consensys to build a conceptual prototype (R). Besu named only by secondary sources (genfinity, eco.com etc.) -> R only. Chainlink CCIP mention also secondary only.
- (c)-(k): U* (not documented in retrieved material).

### HSBC Orion and Tokenised Deposit Service
- R (hsbc.com / business.hsbc.com excerpts): TDS live in HK, Luxembourg, Singapore, UK, US (currencies EUR, HKD, GBP, SGD, USD; AED added); tokens on HSBC's private blockchain managed by the bank; simulation on Canton completed. Orion: digital bond platform; chosen Feb 2026 by HM Treasury for DIGIT pilot; issuance volume figures conflict ($3.5bn vs $5bn+), unresolved.
- (c)-(k): U*.

### Deutsche Boerse / Clearstream D7 DLT
- R (clearstream.com / deutsche-boerse.com press excerpts): D7 DLT launched Nov 2025, built by Deutsche Boerse Group on Google Cloud, sits alongside D7 Digital; tested with CBDC in ECB trials; connects to 360X MTF; EIB issued DLT-native commercial paper; Clearstream is a Pontes DLT market operator (also named in ECB release, V). Underlying ledger tech, crypto, freeze, upgrade, PQ, audits: U*.

### Partior
- R (partior.com excerpts): FAQ says "global private permissioned ledger", authorised FIs only; origins Project Ubin; backers DBS, JPM, StanChart, Temasek, Peak XV. Ledger stack not stated in retrieved material (U*). Rest U*.

### Fnality (Sterling Fnality Payment System)
- R (fnality.com excerpts): live in controlled initial phase since Dec 2023 (omnibus account at BoE RTGS), participants Lloyds, Santander, UBS; BoE settlement finality designation Dec 2024; connected to CHAPS; BoE-set limits, lifting not confirmed; euro system in progress. DLT stack, crypto, key mgmt, freeze/upgrade/policy holders, PQ, audits: U*.

### Broadridge DLR
- R (broadridge.com press releases + FY2026 10-K excerpts): live, runs on Canton; Broadridge is Super Validator and Validator on Global Synchronizer; reported ~$7.5tn Sept 2026 monthly volume (~$359bn/day); expansion to G7 securities; HQLA^X migration to Canton subject to CSSF approval. Other fields: inherit Canton crypto (V above) but DLR-specific controls U*.

### DTCC tokenisation service
- R (dtcc.com excerpts): "DTCC Tokenization Service Goes Live" (2026; excerpt gives 28 Oct 2026); integrated with Canton and DTCC's private Besu network; more chains planned 2027; SEC no-action letter authorises DTC service on pre-approved blockchains for 3 years; live production trades with ~40 firms 15 Jul 2026. Freeze/upgrade/signer policy: U* (DTC as operator presumably; not read).

### R3 Corda
- R (r3.com excerpts): Corda 5.2 end of support 04/2026; Corda Enterprise 4.14 released 03/2026, 4.15 indicative 12/2026; R3 "Corda protocol" on Solana yield vaults (launch date conflicting: H1 2026 vs Q4 2026); Solana notary listed as 2026 milestone. PQ: older docs list SPHINCS-256 as experimental option, default EdDSA (R, old version docs); nothing for current versions -> U.

---------------------------------------------------------------------
## CENTRAL BANK / OFFICIAL SECTOR

### Eurosystem Pontes
- V. ECB press release 21 Sep 2026 "Eurosystem brings central bank money to tokenised finance": https://www.ecb.europa.eu/press/pr/date/2026/html/ecb.pr260921~e754847a7b.en.html (fetched). Pontes launched 21 Sep 2026 with core services; first participants onboarded (e.g. ABANCA, BayernLB, Deutsche Bank, Santander, Societe Generale, EIB, KfW, Bundesbank); DLT operators Axiology, Cashlink, Clearstream, SWIAT; enhanced features/longer hours gradually, full implementation by 2028. (c)(d)(e)(f): release gives no technical or cryptographic detail (V negative). Governance structure not described. (j) U.
- Appia: V (same release): broader ecosystem effort, blueprint targeted 2028. Details U.
- (g)-(i): Eurosystem as settlement operator by definition of central bank money, but no documented freeze/upgrade/policy statement retrieved -> U.

### Digital euro
- R (ECB closing report of preparation phase, Oct 2025, + speeches 2026, excerpts): offline option cash-like privacy (details only to payer/payee); online payer/payee identity hidden from Eurosystem; focus on "cryptographic agility" for quantum. No named algorithms or final cryptographic spec found -> U. Legislative status: U*.

### BIS Project Agora
- V partly. https://www.bis.org/publ/othp110.htm (fetched): report "Project Agora: a shared programmable platform for wholesale cross-border payments"; prototype combining tokenised commercial bank deposits and tokenised reserves; atomic multi-currency settlement; smart contracts embed compliance; convened by BIS + IIF, seven central banks, 40+ firms. Page names no ledger, no privacy, key management, crypto or PQ (V negative; 97-page PDF not read).
- R (bis.org press release p260527, excerpt): 27 May 2026; moves to real-value testing; BIS page reports 28 institutions, ~CHF 800,000, 17 scenarios (July 2026). Status: project report published / real-value testing (not live production).

### mBridge
- R only (secondary: Cointelegraph, Crowdfund Insider, Business Today). BIS exited Oct 2024; Saudi Arabia exit reported by FT 20 Sep 2026 (SAMA reportedly left 13 May 2025); core members PBoC, HKMA, Bank of Thailand, CBUAE; Macao activation June 2026 single source. No BIS/PBoC primary retrieved. Tech, crypto, governance, freeze/upgrade, PQ: U*.

### Bank of England Digital Securities Sandbox
- R (bankofengland.co.uk excerpts): sandbox runs to Jan 2029 (May 2026 speech); 16 firms (May 2026); guidance updated 30 Jun 2026 to widen settlement assets to stablecoins meeting requirements; Gate 2 notices: HSBC (13 Jul 2026), ClearToken CSD (18 Sep 2026), LSEG B3 (23 Oct 2026); DIGIT to be issued on a platform in the DSS. It is a regulatory sandbox, not a ledger; crypto/freeze fields N/A or U.

### MAS Project Guardian
- R (mas.gov.sg excerpts): Guardian tested live use cases in FX, funds, fixed income in six currencies; Oct 2026 speech: next step settle tokenised MAS Bills with SGD wholesale CBDC; frameworks published (fixed income, funds). Initiative, not a ledger; ledger/crypto/freeze/PQ fields U*.

---------------------------------------------------------------------
## COMPARISON TABLE

Legend: PQ roadmap: yes / no / not public. Cell label in brackets. "U*" = not retrieved this run.

| Platform | Freeze power holder | Upgrade power holder | Signer-policy holder | PQ roadmap |
|---|---|---|---|---|
| Ethereum L1 | no protocol freeze documented (U*) | client teams/social consensus (U*) | each key holder (U*) | yes [R] (Lean Ethereum, hash-based; ~2029 target is one researcher's) |
| Base | U* | Coordinator Multisig + Security Council, no delay [R] | U* (sequencer) | U* |
| Arbitrum One | U* | DAO path 17d8h; Security Council 9/12 instant [R] | U* | U* |
| Linea | U* | Linea Security Council, 0s [R] | U* | U* |
| ZKsync Era | U* | 4d3h-8d3h path; EmergencyUpgradeBoard instant [R] | U* | U* |
| ZKsync Prividium | U (asset freeze); admins control access [V] | U | chain operator / permissioning admins [V] | not public (U) |
| Bitcoin | none documented (U*) | node consensus (U*) | key holder (U*) | proposal only: BIP-360 draft [R] |
| Stellar | asset issuer (revoke auth), if AUTH_REVOCABLE [V]; also network config freeze CAP-77 [V] | validator vote (SCP) [R] | issuer/account [V] | yes [R] (ML-DSA; 2026-2027 plan) |
| Hedera | token creator's freeze key, if set [R] | Governing Council [R] | key holders per token [R] | U* |
| XRP Ledger | issuer (freeze/clawback if enabled before issuance) [R] | amendment voting (U*) | U* | U* |
| Solana Token-2022 | mint freeze authority; permanent delegate for claw-back [R] | U* | U* | U* |
| Polygon | validator/PIP fork path [R] | Protocol Council multisig + PIP [R] | U* | not public (none found) |
| Avalanche | none documented (U*) | ACP + validator adoption [R] | U* | no adopted plan (forum idea only) [R] |
| USDC | Circle [V] | not stated in terms (U) | Circle [V, by freeze right] | U* |
| USDT | Tether [V] | U | Tether [V] | U* |
| Canton / Global Sync | U at network level | SV governance vote + validator coordination [V]; software control U | SV BFT vote [V]; detail U | not public (not in crypto-schemes page) [V neg] |
| Kinexys / JPMD | bank-issuer (mechanism U*) | U* | J.P. Morgan (permissioned access) [R] | U* |
| Citi Token Services | U* | U* | U* | U* |
| Swift ledger | U* | U* | U* | U* |
| HSBC Orion / TDS | HSBC (private chain, managed by bank) [R] | HSBC (implied, U*) | HSBC [R] | U* |
| Clearstream D7 DLT | U* | Deutsche Boerse Group (U*) | U* | U* |
| Partior | U* (permissioned, FIs authorised) | U* | U* | U* |
| Fnality £FnPS | U* | U* | U* (BoE-limited) | U* |
| Broadridge DLR | U* (Canton-based) | per Canton | U* | not public |
| DTCC tokenisation | U* | U* | U* | U* |
| R3 Corda | U | U* | U* | experimental SPHINCS-256 in old versions [R]; current: not public |
| Eurosystem Pontes / Appia | U | U | U | not public |
| Digital euro | U | U | U | partial: "cryptographic agility" stated [R]; no algorithm |
| BIS Agora | U | U | U | not public [V neg] |
| mBridge | U* | U* | U* | U* |
| BoE DSS | n/a (sandbox) | n/a | n/a | n/a |
| MAS Guardian | n/a (initiative) | n/a | n/a | n/a |

## SUMMARY: V vs U (10 lines)
1. V (full official pages read): Stellar issuer clawback/auth flags, Circle USDC terms (blocklist/freeze), Tether terms (freeze/blacklist), Canton crypto-schemes and SV overview, ECB Pontes/Appia release, BIS Agora report page, ZKsync Prividium architecture page.
2. Pontes launch on 21 Sep 2026 is confirmed in the ECB release; it states no cryptographic, ledger or governance design (V negative).
3. Swift 9 Jul 2026 "ready for initial use / 17 banks piloting" is seen only as swift.com excerpts (fetch 403); Besu and Consensys-built are NOT confirmed on swift.com (only Sept 2025 Consensys prototype mention; Besu from secondary sources).
4. L2BEAT pages redirect to ethbeat.org (not followed); all L2 stage/upgrade/delay data is R from search excerpts and may be stale; stage and proof system U*.
5. Freeze powers with primary evidence: issuer-controlled on Stellar (V), Circle and Tether (V); XRPL, Solana, Hedera are R only.
6. Upgrade holders: Canton SV governance vote is V but who controls software changes is U; L2 security-council data is R; most institutional platforms U*.
7. Signer/transaction policy holders are almost entirely U or U* for institutional platforms; only ZKsync Prividium (operator/permissioning admins) is V.
8. PQ roadmaps: Ethereum and Stellar have stated plans (R from official-site excerpts), Bitcoin BIP-360 draft only (R via mirror), Avalanche community idea only, Canton/Agora/Pontes state none (V negative), digital euro says only "cryptographic agility" (R).
9. Digital euro, mBridge, Fnality, Partior, Citi, HSBC, D7 DLT, DTCC, Corda: status/volumes are R; ledger, crypto, key management, audits/incidents are U* (not retrieved), not shown to be non-public.
10. Audits/incidents were not retrieved for any platform except incident mentions (Hedera 2022 precompile attack, Polygon blocked-address recovery PIP); treat all (k) fields as U*.
