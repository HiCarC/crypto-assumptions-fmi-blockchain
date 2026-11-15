# Claims ledger

Every factual claim intended for the article or the annex, with its evidence and a confidence label. State as of 15 November 2026 (Checkpoint 2).

- **V** verified: primary source read for this project, or reproduced by code in this repository
- **R** reported: credible secondary source or official excerpt only
- **I** inferred: reasoning, written down
- **U** unknown: not found in public material retrieved

Rule for the article: only **V** claims, and **I** claims marked as the author's reasoning, may be stated as fact. **R** claims must be worded as reported or left to the annex. Source detail (URL, date, quotation) for V and R claims is in `research/primary/*.md`.

## A. The October 2026 results

| ID | Claim | Label | Evidence |
|---|---|---|---|
| A1 | OpenAI's preprint "The Exponential Time Hypothesis is False" is dated 25 October 2026 and has not been revised since it was posted on 26 October | V | Repository commit history, `research/01-chapter1-reverification.md` |
| A2 | Its Lean formalisation proves a slightly weaker bound than the manuscript states (an extra log log n factor in the exponent); both are subexponential | V | `lean/docs/378.md` in OpenAI's repository |
| A3 | Anthropic's paper claims a deterministic subexponential algorithm for 3-SAT and #3-SAT, in one version dated 27 October 2026 | V | Paper page |
| A4 | Independent experts are examining the result; neither confirmation nor refutation has been published | R | Scientific American, 27 October 2026 |
| A5 | No deployed blockchain signature scheme, hash function or proof system has a security argument that rests on ETH or SETH | I | `research/02-findings-rq1-rq6.md` §RQ1; to be written out with citations in annex §2 |
| A6 | Published fine-grained lower bounds for lattice problems (Bennett–Golovnev–Stephens-Davidowitz 2017; Aggarwal–Stephens-Davidowitz 2018) are conditional on SETH or Gap-ETH; they do not cover CVP in the Euclidean norm, and ML-DSA's parameters come from concrete Core-SVP cost models, not from these bounds. If ETH is false these supporting arguments lose their premise; no attack follows | V (papers' abstracts, Dilithium specification) / I (the consequence) | `research/primary/technical.md` §1 |
| A7 | No production blockchain or financial system was found that relies on fine-grained (ETH/SETH-based) cryptography | R/U | Search on 15 November 2026; absence of evidence |

## B. Incidents

| ID | Claim | Label | Evidence |
|---|---|---|---|
| B1 | Binance: about US$6.34 billion in digital assets was affected on 29 October 2026 | V | Binance, "Initial Findings and Response Update", 3 November 2026 |
| B2 | Binance: the attacker made unauthorised use of an internal wallet signing service and exploited the EIP-7702 authorisation mechanism to give an attacker-controlled contract execution rights over a hot wallet | V | Same report |
| B3 | Binance: the hot wallet used multi-party computation, so no single private key existed with which to revoke the authorisations at once | V | Same report |
| B4 | Binance (30 October): no evidence that wallet private keys were leaked | V | Binance Security Incident Update #2 |
| B5 | Binance: about US$2.85 billion was frozen or intercepted | V | 3 November report (earlier updates said about 3 billion) |
| B6 | Binance: an internal AI tool was used to gain control of an engineer's access; the report does not say how | V | 3 November report. Use with care: one sentence, no elaboration |
| B7 | The FBI attributed the Binance theft to North Korea's TraderTraitor on 31 October 2026 | R | fbi.gov alert refused automated access; reported by BleepingComputer and others |
| B8 | Which issuers froze the funds (Tether, Circle and others) | R | Third-party analysis; Binance does not name them |
| B9 | It is the largest theft of digital assets on record | R | Chainalysis blog wording; consistent with B1 exceeding B10 |
| B10 | Bybit: about US$1.5 billion stolen on or about 21 February 2025, attributed by the FBI to TraderTraitor | V | FBI PSA I-022625-PSA, 26 February 2025 |
| B11 | Bybit: signers approved a disguised transaction after a wallet provider's developer machine was compromised | R | Safe statement and forensic findings via BleepingComputer |
| B12 | Over US$3.4 billion was stolen from January to early December 2025 | V | Chainalysis, 18 December 2025 |
| B13 | H1 2026: 207 hacks, about US$972 million; infrastructure compromises were about 15% of incidents and about 76% of losses | V | TRM Labs, 1 July 2026 |
| B14 | THORChain (May 2026, about US$10 million): a threshold-signature library never verified a Paillier modulus, letting a malicious node reconstruct a key | V | THORChain exploit report 2, 3 July 2026 |
| B15 | Wintermute (2022, about US$160 million): the firm said the cause was most likely a weakly generated vanity-address key | V | CEO statement via The Block, 20 September 2022 |
| B16 | Ronin, Wormhole, Nomad, Poly Network, Kelp DAO, Drift: amounts and root causes as in `data/incidents.csv` | R | Operators' post-mortems not retrievable; secondary analyses |
| B17 | In the twelve-case list, no loss came from a broken cryptographic primitive; operational compromise of keys or signing accounts for about 79% of listed losses | V (of the list) | `scripts/incidents_chart.py` → `results/incidents_summary.md`. The list is a selection, not a census |

## E. Technical facts read in primary sources (round 2)

| ID | Claim | Label | Evidence |
|---|---|---|---|
| E1 | Of 141 SNARK vulnerabilities studied (2018–2024), 99 were in circuits and 95 of those were under-constrained | V | Chaliasos et al., USENIX Security 2024 (arXiv v1) |
| E2 | Trail of Bits' Frozen Heart (April 2022): insecure Fiat–Shamir implementations allowed forged proofs in implementations of Girault's proof, Bulletproofs and PlonK | V | Trail of Bits blog, 13 April 2022 |
| E3 | EIP-7702 has been active on Ethereum mainnet since 7 May 2025 (Pectra); the designated code persists until replaced | V | eips.ethereum.org, ethereum.org history |
| E4 | In Daml, signatories create and archive contracts and archiving needs every signatory's authority | V | docs.canton.network |
| E5 | A new Daml package version must pass compatibility checks at build and at each participant's upload; there is no separate authorisation ceremony | V | docs.canton.network |
| E6 | Ronin and Nomad root causes and amounts | R | Primaries returned 404/403 |

## C. Measurements made in this repository (all V, reproducible)

| ID | Claim | Evidence |
|---|---|---|
| C1 | Verifying one signature on an EVM ledger costs about 8,000 gas for ECDSA secp256k1, about 12,700 for P-256 through the native precompile, about 237,000 for P-256 in contract code, and about 8.1 million for ML-DSA-44 in contract code (roughly a thousand times ECDSA) | `results/gas.json`, `results/gas_table.md`; test `PostQuantumTest.test_writeGasTable` |
| C2 | An ML-DSA-44 signature is 2,420 bytes against 65 for ECDSA; the public key is 1,312 bytes against 33 | Fixture generation; FIPS 204 parameter set |
| C3 | Registering one ML-DSA-44 key on chain cost about 5.3 million gas in this implementation | `results/gas.json` |
| C4 | A participant's signature scheme can be replaced without moving any balance | Tests `test_rotateFromSecp256k1ToP256WithoutTouchingBalances`, `test_migrateClassicalAccountToHybrid`; Soroban `scheme_changes_address_does_not` |
| C5 | When a scheme is disallowed, holders who did not migrate keep their balances but can no longer sign; recovery needs a privileged registrar | Test `test_disallowedSchemeStrandsSignaturesNotBalances` |
| C6 | Scheme replacement at application level does not reach the ledger's own transaction signature | Audit finding M-1 |
| C7 | A signing service that signs any digest for an authenticated caller can be made to sign an EIP-7702 authorisation that hands an account to attacker code; a service that accepts only typed requests cannot | Tests in `Demo3b_SignerPolicyNeverAnticipatedDelegation` |
| C8 | 57 Foundry tests pass; coverage of core contracts is 95.0% of lines and 100% of branches | `audit/reports/coverage.txt` |
| C9 | Echidna: three properties held over 50,160 calls (seed 2026) | `audit/reports/echidna.txt` |
| C10 | Halmos: four properties hold symbolically; two vacuity controls fail as required | `audit/reports/halmos.txt`, `halmos-vacuity.txt` |
| C11 | Certora Prover: five rules verified on the token, with no vacuous rule | `audit/reports/certora.txt` |
| C12 | Mutation testing: 83 of 89 compilable mutants killed (93.3%); after triage every non-equivalent mutant is killed | `audit/reports/mutation.txt` |
| C13 | On a plain encoding, three current SAT solvers found SHA-256 preimages with a free message up to 18 rounds of 64 and none at 19; at full rounds they were slower than trying every value of the unknown bits, and failed beyond 16 unknown bits within 120 s | `results/sat_scaling.csv`, `results/fig_sat_scaling.png`, `sat/`. No extrapolation |
| C14 | Under the stated planning assumptions, a migration started in January 2027 disallows classical-only keys in January 2031 | `scripts/migration_timeline.py`. An illustration of sequencing, not a forecast |
| C16 | Daml model: neither issuer nor owner can archive a jointly signed holding alone; the issuer can freeze or claw back only because the holding's text grants it | `daml/` (6 tests) |
| C15 | For the institutional and central-bank platforms examined, 47 of 56 cells on who can freeze, upgrade, set signer policy, and on post-quantum plans were not found in the public material retrieved | `cbom/build.py` → `results/cbom_summary.json`. Time-boxed search; see LIMITATIONS |

## D. Standards, policy and plans

| ID | Claim | Label | Evidence |
|---|---|---|---|
| D1 | NIST IR 8547 is final (27 October 2026): ECDSA, EdDSA and RSA are deprecated after 2030 and disallowed after 2035 | V | csrc.nist.gov. Treatment by security strength in the final's table still to be checked by eye |
| D2 | FIPS 203, 204 and 205 were published on 13 August 2024 | V | csrc.nist.gov |
| D3 | FIPS 206 (FN-DSA) is not final | R | No official page found |
| D4 | The EU coordinated roadmap was published on 23 June 2025 | V | European Commission page |
| D5 | EU roadmap v1.1: first steps and national roadmaps by end 2026; high-risk use cases by end 2030; medium-risk by end 2035, low-risk as far as feasible; a recommendation to Member States | V | EU PQC roadmap PDF, 11 June 2025 |
| D6 | The G7 Cyber Expert Group roadmap is non-binding, with 2035 as a general target and 2030–32 for critical systems | V | US Treasury copy of the roadmap |
| D7 | OCC final rule implementing the GENIUS Act: issued 21 October 2026, effective 18 January 2027 | V | OCC NR 2026-92 |
| D8 | Basel Committee: an update on its cryptoasset-standard review is expected later in 2026 | V | BIS press release, 20 May 2026 |
| D9 | Eurosystem Pontes launched on 21 September 2026; the launch release gives no cryptographic or governance detail | V | ECB press release |
| D10 | Stellar plans ML-DSA verification in contracts in 2026 and quantum-safe account signers in 2027 | V | stellar.org plan |
| D11 | Ethereum's post-quantum site estimates base-layer upgrades by about 2029 and gives no committed dates | V | pq.ethereum.org |
| D12 | Bitcoin's BIP-360 is a draft, hides public keys until spending, and contains no post-quantum signature scheme | V | BIPs repository mirror |
| D13 | Canton's published cryptographic-schemes reference lists Ed25519 and ECDSA (P-256, P-384, secp256k1) and no post-quantum scheme | V | docs.canton.network |
| D14 | Stellar asset issuers can revoke authorisation and claw back if they enabled those flags; Circle and Tether reserve the right to freeze | V | Stellar developer docs; Circle and Tether terms |
| D15 | Rollup upgrade powers (Base, Arbitrum, Linea, ZKsync) as in `cbom/data.py` | R | Search excerpts of L2BEAT; pages not read |
| D16 | Swift's shared ledger is in initial use with 17 banks piloting | R | swift.com excerpt (page refused automated access); "Besu" from secondary sources only |
| D17 | Google Quantum AI (2026) estimates fewer than 500,000 physical qubits to break secp256k1 under its stated assumptions | V | Google blog; the paper itself not read |
| D18 | Glassnode (20 May 2026): about 6.04 million BTC, 30.2% of supply, held under exposed public keys | V | Glassnode page. A later press figure (7.12 million, November) is R only |
| D19 | Anthropic's SCONE-bench: agents exploited 207 of 405 historically exploited contracts in simulation, and found two previously unknown flaws in 2,849 recent contracts at an API cost of about US$3,476 | V | red.anthropic.com post |
| D20 | EVMbench best exploit-mode score of 72.2%; studies showing weaker results on real incidents | R | Secondary coverage; primaries not read |
| D21 | PFMI Principles 2, 8, 15, 17 and the 2016 cyber-resilience guidance do not mention cryptography or key management (encryption appears once as an example) | V | `research/primary/regulation.md` |
| D22 | DORA applies from 17 Jan 2025; Art. 9(4)(d) key protection; RTS 2024/1774 Art. 6 requires updating cryptography on developments in cryptanalysis, Art. 7 a key life cycle; quantum is not named | V | same |
| D23 | BIS Project Leap 2: PQ signatures (Dilithium round 3) on T2 liquidity transfers in a test environment worked; verification at least an order of magnitude slower; hybrid not carried out | V | same |
| D24 | NSA CNSA 2.0 dates; MiCA and DLT Pilot Regime status | R/U | Not read at source: not used |

## Corrections made during the work

- The brief's summary of the OpenAI bound wrote "log n" where the source and Chapter 1 have "√log n".
- The FBI's Binance alert is on fbi.gov, not ic3.gov.
- Binance's "no evidence of a key leak" is from 30 October; the 3 November report describes the signing-service path instead.
- THORChain's second report is dated July 2026 and reports about US$10 million.
- The Glassnode exposure figure verified at source is 6.04 million BTC (May 2026), lower than the press figure first noted.
