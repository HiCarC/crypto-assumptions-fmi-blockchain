# Phase 1 research notes: RQ1–RQ6, ledgers, regulation

State as of 15 November 2026. Labels: **V** verified (primary source read), **R** reported (credible secondary; primary still to be read), **I** inferred (reasoning given), **U** unknown / not publicly documented. Claim IDs refer to `claims-ledger.md`. Most items here are **R**: Phase 1 located the sources; promotion to **V** happens when the primary is read for the annex. Nothing labelled R may appear in the article as a bare fact without that step or an explicit "reported".

## RQ1 — Does a refutation of ETH touch blockchain cryptography?

**Working answer: no deployed blockchain primitive has its security argument resting on ETH or SETH.** Reasoning (I), to be written out in the annex:

- **ECDLP and pairings.** Security estimates come from the best known algorithms for the specific algebraic problem (Pollard rho, about the square root of the group size; number-field-sieve variants for pairing target groups). These are not reductions from 3-SAT, and ECDLP is not known or believed to be NP-hard. A faster worst-case 3-SAT algorithm gives no generic route to it. One could encode a discrete-log instance as a circuit and then as SAT, but the claimed running time is 2^{n·o(1)} in the number of *encoded* variables, which for a 256-bit scalar multiplication circuit is far larger than 128, the exponent of the generic attack. Same argument as Chapter 1 made for AES.
- **Hash functions (SHA-256, Keccak-256, Poseidon).** Concrete security is a cryptanalytic judgement about a fixed function, not a consequence of ETH. SAT solvers are a real tool here, but published results stay at reduced rounds: Morawiecki–Srebrny (2013) reached 3-round Keccak preimages with 40 unknown bits by SAT; the strongest recent reduced-round Keccak preimage results use linear-structure and algebraic methods, not pure SAT (c22, R). Component E measures this scaling directly.
- **Lattice and hash-based PQC.** Lattice parameter selection uses concrete cost models for lattice reduction, not ETH. Some *hardness-of-approximation* results for lattice problems are proved under ETH/SETH-type hypotheses (fine-grained lower bounds for SVP/CVP); if ETH is false those conditional lower bounds lose their premise, which removes a piece of supporting theory but supplies no attack. This is the one place where the honest statement is "a supporting argument weakens" rather than "nothing changes"; the annex must say so precisely and cite the papers.
- **Fine-grained cryptography, proofs of useful work, local PRGs.** Ball–Rosen–Sabin–Vasudevan proofs of work rest on Orthogonal Vectors/3SUM/APSP conjectures; the OV conjecture is implied by SETH, so a SETH refutation removes the standard evidence for OV without directly refuting it. No deployment in any production blockchain or financial system was found (c21, R/U). Goldreich-type local PRGs matter for some indistinguishability-obfuscation constructions; these are research constructions, and they are under independent attack pressure from 2026 Eurocrypt papers unrelated to the October results (c23, R). No production deployment found.
- **ZK proof systems.** Soundness of deployed SNARKs/STARKs rests on: algebraic assumptions in pairing groups or collision resistance of hashes; knowledge-type assumptions or the generic/algebraic group model; and the random-oracle heuristic for Fiat–Shamir. None is an ETH-type assumption. Where ZK has failed in practice, it failed in implementation: under-constrained circuits are the most common class in the SoK of 141 SNARK vulnerabilities (Chaliasos et al., USENIX Security 2024), and "Frozen Heart" was a Fiat–Shamir implementation flaw (c24, R).

**Evidence still needed for V:** read the OpenAI PDF section on constant-output-locality inversion and state exactly which parameter regime of local functions it covers; cite specific ETH-based lattice lower-bound papers.

## RQ2 — Is blockchain a different problem even if the mathematics holds?

The hypothesis ("blockchains change consequence and remedy more than probability") is **mostly supported, with one important correction**:

- **Correction: "cannot be rolled back" is too strong for tokenised money.** In the 29 October 2026 Binance theft, stablecoin issuers froze a large part of the proceeds within about an hour (Tether, Circle, then others); reported totals range from about $2.24bn to $2.85bn (c10, R). The remedy exists where an issuer holds a freeze key. So permanence is a property of the *asset's governance*, not of "the blockchain". For an institutional ledger this cuts both ways: the freeze key is a control and also a concentrated cryptographic authority that must itself be inventoried.
- **Protocol change can widen what a signature means.** The Binance attacker reportedly submitted EIP-7702 authorisations, a transaction type introduced by Ethereum's Pectra upgrade in May 2025, which made a hot wallet execute attacker code; third-party analysis says the signing policy had not been updated for the new type (c9, R). This is cryptographic agility in reverse: the ledger changed its rules and an institution's controls did not follow. It belongs in the article as the intermediate link between "agility is governance" and "what to ask".
- **Exposed long-lived keys.** Reported estimates of bitcoin held under exposed public keys: Glassnode 7.12M BTC, 35.4% of supply, as of 10 Nov 2026 (of which address reuse 25.8% of supply); Project Eleven about 6.99M BTC; a Google-led March 2026 paper about 7M exposed in some form, 2.3M dormant (c15–c17, R). Definitions differ; the annex must tabulate definitions, not average the numbers.
- **Quantum resource estimates moved in 2026.** A Google Quantum AI whitepaper (31 March 2026, with Ethereum Foundation and Stanford co-authors) reportedly estimates under 500,000 physical qubits for secp256k1 under stated hardware assumptions, about 1,200 logical qubits in its low-qubit variant (c18, R). Separate from the SAT results; must not be conflated.
- **Agility is governance.** Bitcoin: BIP-360 (P2MR) merged into the BIPs repository as a draft on 11 Feb 2026, not activated, and its current text contains no post-quantum signature algorithm; BIP-361 (phased restriction of legacy signatures) reportedly merged April 2026 (c19, R). Ethereum: Foundation post-quantum team formed January 2026; hash-based consensus signatures (leanXMSS/leanSig) on devnets; execution-layer precompile proposals EIP-8051 (ML-DSA) and EIP-8052 (Falcon); core milestones targeted around 2029 (c20, R). Stellar: Quantum Preparedness Plan announced 9 June 2026, ML-DSA verification as Soroban host functions in stage 1 (c25, R).

## RQ3 — Where losses happen

Preliminary classification; every amount is R until the primary post-mortem or official attribution is read.

| Incident | Date | Reported loss | Root cause class | Mathematics broken? |
|---|---|---|---|---|
| Binance | 29 Oct 2026 | about $6.3–6.4bn (Binance $6.34bn; TRM $6.36bn; Elliptic $6.43bn; Chainalysis about $6.4bn) | (c) operational compromise of signing infrastructure; valid signatures issued | No |
| Bybit | 21 Feb 2025 | about $1.5bn | (c)/(f) compromised signing interface (Safe{Wallet} front end) | No |
| Ronin | Mar 2022 | about $625m | (c) five of nine validator keys compromised by social engineering | No |
| Poly Network | Aug 2021 | about $611m (largely returned) | (d)/(e) cross-chain contract permission flaw | No |
| Bitget | 2026 (date to confirm) | $387m per Chainalysis blog title | to be classified | to be checked |
| Wormhole | Feb 2022 | about $325m | (e) signature-verification bypass in contract code | No (verification was skipped, not defeated) |
| Kelp DAO | 18 Apr 2026 | $292m | (e) bridge compromise | to be checked |
| Drift | 1 Apr 2026 | $285m | (f) social engineering | No |
| Nomad | Aug 2022 | about $190m | (e) faulty upgrade trusted a zero root | No |
| Wintermute | Sep 2022 | about $160m | (b) weak key generation (Profanity) is the commonly cited cause; **not confirmed by this phase's sources** | No (search space reduced by a bad generator) |
| THORChain | 15 May 2026 | about $10.8–11m | **(b) implementation error in cryptographic code**: threshold-signature library reportedly missing Paillier-modulus proof checks, allowing key reconstruction by a malicious node | No primitive broken; protocol implementation incomplete |

Aggregate context (R): Chainalysis put 2025 thefts at over $3.4bn (January to early December), with Bybit about $1.5bn of it; TRM counted about $972m in H1 2026 with infrastructure compromises about 15% of incidents and about 76% of losses (c11–c13).

**Reading:** the expected pattern holds so far. No incident found in which a standard primitive was broken. THORChain is the instructive exception class: a loss rooted in cryptographic *code*, small in value. The article's chart should weight by value and show count alongside, because the two tell different stories (many contract bugs, few very large operational compromises).

## RQ4 — The capability shift

- Anthropic Frontier Red Team, SCONE-bench (1 Dec 2025): 405 contracts exploited in 2020–2025; agents also found two previously unknown vulnerabilities in 2,849 recently deployed contracts, worth $3,694 in simulation at an API cost of $3,476 for one model (c26, R; primary located at red.anthropic.com/2025/smart-contracts, not yet read in full).
- OpenAI/Paradigm EVMbench (Feb 2026): 120 vulnerabilities from 40 audits; best exploit-mode score reported 72.2%, up from 31.9% for the previous model generation; a re-evaluation paper questions stability and scaffolding effects (c27, R).
- Counter-evidence: one 2026 study reports no agent completed an end-to-end exploit on any of 22 real incidents (c28, R). Must be presented alongside.
- In the Binance case, secondary accounts of the 3 November initial report say an internal AI tool was abused for lateral movement from 20 October (c29, R, **to be confirmed in Binance's own text before any use**). Chainalysis disclosed on 30 Oct 2026 an intrusion it described as using "offensive agentic techniques" (c30, R).

**Reading against the Chapter 1 test:** for AI-assisted exploitation there *is* a demonstrated attack class, a named system type and a stated resource cost. For ETH there is none. On the author's own test, RQ4 is the larger change in risk. Confidence: medium, because benchmark performance and real-world performance diverge (c28).

## RQ5 — Institutional ledgers (first pass)

| Platform | Publicly documented so far | Label |
|---|---|---|
| Canton / Global Synchronizer | Signing: Ed25519 default; ECDSA P-256 (default with cloud KMS), P-384 supported. Post-quantum: no official roadmap found; a community funding proposal targets post-quantum certificates in Q3 2027 | R (official docs page located: docs.canton.network/global-synchronizer/reference/crypto-schemes) |
| Kinexys (J.P. Morgan) | JPMD deposit token live for institutional clients on Base (public Ethereum L2); native issuance on Canton announced January 2026 | R |
| Citi Token Services | Private permissioned ledger; stack not publicly documented in sources found | R / U |
| Swift shared ledger | Live in pilot since 9 July 2026 with 17 banks; reported as permissioned Hyperledger Besu built by Consensys, not public Linea | R |
| HSBC Orion / Tokenised Deposit Service | TDS launched May 2025; reported to use Canton technology; simulated pilot on public Canton Network April 2026 | R |
| Deutsche Börse / Clearstream D7 DLT | Leading European DLT issuance platform by 2026 volume per AFME; underlying cryptography not found | R / U |
| Broadridge DLR | Canton-based repo platform | R |
| DTCC | Tokenised DTC-held assets on a private Besu network and on Canton (July 2026) | R |
| Fnality, Partior | Not yet researched to source | U |
| Eurosystem Pontes | Announced for Q3 2026 (ECB, 11 March 2026); reported live 21 September 2026 (launch release not yet read). Appia roadmap to 2028 | V for the plan / R for the launch |
| BIS Project Leap | Phase 2 report December 2025: post-quantum signatures on TARGET2-type liquidity transfers worked functionally; verification reported slower (209.9 ms vs 28.1 ms in one reading of the annex) ; hybrid not tested | R |
| BIS Project Agorá | Findings 27 May 2026; moving to real-value testing | V (BIS press release located) / details R |
| mBridge | BIS handed over October 2024; project continues under partner central banks | R |

**Pattern (I):** institutional tokenisation is converging on two stacks, Canton and permissioned or public EVM (Besu, Base). Both use classical elliptic-curve signatures throughout. The comparative CBOM will therefore have few distinct rows of cryptography and many rows of governance, which is itself the finding.

## RQ6 / §5 — Framework status

| Item | Status found | Label |
|---|---|---|
| NIST IR 8547 | Reported final 27 October 2026; RSA/ECC deprecated after 2030 at all approved strengths, disallowed after 2035 (the all-strengths deprecation is single-sourced) | R — read csrc.nist.gov/pubs/ir/8547/final |
| FIPS 206 (FN-DSA) | No final publication found | R |
| EU PQC roadmap (June 2025) | National plans by end 2026; high-risk use cases by end 2030; as much as feasible by end 2035 | R |
| G7 Cyber Expert Group | Roadmap published 13 January 2026; non-binding; references 2035 | R (Treasury PDF located) |
| BIS Papers No 158 | Quantum-readiness roadmap, 7 July 2025 | V (publication located) |
| GENIUS Act | OCC final rule 21 October 2026; expected effective date 18 January 2027; AML/sanctions rulemaking separate | R (OCC release NR 2026-92 located) |
| BCBS cryptoasset standard | In force 1 January 2026; targeted review in progress, update expected by end 2026 | V for the press releases / R for timing |
| PFMI, DORA, MiCA, DLT Pilot Regime, CNSA 2.0, CPMI tokenisation work, digital euro design | Not yet re-verified in this phase | U |

## Not done in Phase 1 (carried into Phase 4 with the annex)

Primary read-through of: Binance initial report; FBI alerts for Bybit (I-022625-PSA located) and Binance; Chainalysis and TRM reports; SCONE-bench and EVMbench papers; BIS Leap phase 2 report; NIST IR 8547 final; EU roadmap; Google quantum whitepaper; Glassnode methodology; L2BEAT pages for Base, Arbitrum, Linea, ZKsync; Fnality, Partior, Citi, D7 technical documentation; Hedera, XRP Ledger, Solana, Polygon, Avalanche; Bank of England, MAS, Federal Reserve; digital euro; DORA/MiCA/DLT Pilot Regime current texts.
