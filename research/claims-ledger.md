# Claims ledger (Phase 1 state)

Labels: **V** verified (primary read), **R** reported (secondary; primary to be read), **I** inferred, **U** unknown. All sources accessed 15 November 2026. This file becomes `CLAIMS.md` at the repository root once the article and annex exist; no R-labelled claim may be stated as plain fact in the article.

| ID | Claim | Label | Source |
|---|---|---|---|
| c1 | OpenAI preprint "The Exponential Time Hypothesis is False", dated 25 Oct 2026, posted 26 Oct 2026, unrevised since | V | github.com/openai/math/tree/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026 (commit history) |
| c2 | Lean proves exact k-SAT counting in time (L+1)^{O_k(1)}·2^{O_k(n(log log n)²/√log n)} with polynomial space; manuscript claims 2^{O_k(n log log n/√log n)} | V | github.com/openai/math/blob/main/lean/docs/378.md |
| c3 | Anthropic paper "A 2^{o(n)} Time Algorithm for 3-SAT", v1 27 Oct 2026, single version, covers #3-SAT, states Lean 4 formalisation | V | hexagonmath.org/2610.00577v1 |
| c4 | Impagliazzo, Paturi and Williams are examining OpenAI's result; no confirmation or refutation published | R | scientificamerican.com/article/dueling-proofs-from-openai-and-anthropic-astound-scientists/ |
| c5 | Anthropic states its method would not beat brute force below about 10^10,000 variables at clause density 5 | R | secondary coverage; confirm in paper PDF |
| c6 | Binance theft, 29 Oct 2026, about $6.3–6.4bn, largest crypto theft on record | R | chainalysis.com/blog/binance-exploit-latest-findings-and-response/ ; figures vary by firm |
| c7 | Binance: no evidence a private key leaked; entry via compromised engineer device reaching a withdrawal-capable service; more than one point of breach | R | Binance Security Incident Update #2 (30 Oct 2026) as cited by metrika.co/blog/binance-post-mortem-10-29-p1 ; Binance initial report 3 Nov 2026 not yet read |
| c8 | FBI attributed the Binance theft to North Korea's TraderTraitor on 31 Oct 2026 and listed 628 addresses | R | bleepingcomputer.com, securityweek.com, thehackernews.com coverage; ic3.gov alert not yet read |
| c9 | Attacker used EIP-7702 authorisations to install code on a Binance hot wallet; signer policy reportedly not updated for the transaction type introduced in May 2025 | R (mechanism from on-chain data via Chainalysis; policy gap is third-party analysis) | chainalysis.com blog; metrika.co |
| c10 | Stablecoin issuers froze roughly $2.2–2.85bn of the proceeds, starting within about an hour | R | metrika.co ($2.24bn itemised); Chainalysis ($2.8bn as of 3 Nov); Binance report as cited ($2.85bn) |
| c11 | Chainalysis: over $3.4bn stolen in 2025 (Jan–early Dec); Bybit about $1.5bn of it | R | theblock.co/post/382477 ; Chainalysis report not read directly |
| c12 | FBI attributed Bybit (on or about 21 Feb 2025, about $1.5bn) to TraderTraitor | R (alert located) | ic3.gov/PSA/2025/PSA250226 |
| c13 | TRM Labs H1 2026: 207 hacks, about $972m; infrastructure compromises about 15% of incidents and 76% of losses | R | news.dextools.io tracker citing TRM |
| c14 | THORChain, 15 May 2026, about $10.8–11m: key reconstructed by a malicious node via flaws in its GG20 threshold-signature implementation (missing Paillier proof checks per third-party analysis) | R | quillaudits.com/blog/hack-analysis/thorchain-gg20-hack ; blog.thorchain.org/thorchain-exploit-report-2 not yet read |
| c15 | Glassnode: 7.12M BTC (35.4% of supply) with exposed public keys as of 10 Nov 2026 | R | cryptobriefing.com/glassnode-bitcoin-public-key-exposure-quantum/ |
| c16 | Project Eleven: about 6.99M BTC in addresses with exposed public keys | R | secondary |
| c17 | Google-led paper: up to 2.3M dormant quantum-vulnerable BTC; about 7M with some exposure | R | secondary |
| c18 | Google Quantum AI whitepaper (31 Mar 2026): under 500,000 physical qubits for secp256k1 under stated assumptions | R | postquantum.com/security-pqc/google-quantum-bitcoin-ecdlp/ ; primary not read |
| c19 | BIP-360 (P2MR) merged as draft 11 Feb 2026, not activated, contains no PQ signature scheme; BIP-361 merged April 2026 | R | cointelegraph.com feature; BIPs repository not yet read |
| c20 | Ethereum Foundation PQ team formed Jan 2026; leanXMSS/leanSig; EIP-8051 (ML-DSA), EIP-8052 (Falcon); milestones around 2029 | R | pq.ethereum.org/llms.txt located; ethereum.org/roadmap/security/quantum-resistance/ |
| c21 | No production blockchain or financial system found that relies on fine-grained (ETH/SETH/OV/k-SUM) hardness | R/U (absence of evidence after search) | eprint.iacr.org/2017/203, 2018/559 (research status) |
| c22 | Published SAT-based hash preimage results remain at reduced rounds (e.g. 3-round Keccak with 40 unknown bits, 2013) | R | Morawiecki & Srebrny, Information Processing Letters 2013 |
| c23 | Goldreich-type local PRGs faced new attacks at Eurocrypt 2026 independent of the October results | R | eprint.iacr.org/2026/2757 |
| c24 | SoK of 141 SNARK vulnerabilities: under-constrained circuits the most common class | R | usenix.org/system/files/usenixsecurity24-chaliasos.pdf (located, not read) |
| c25 | Stellar Quantum Preparedness Plan (9 Jun 2026): ML-DSA verification host functions in 2026; quantum-safe signers on accounts in 2027 | R | cryptotimes.io/2026/06/10/… ; SDF primary not read |
| c26 | SCONE-bench: 405 historically exploited contracts; two novel vulnerabilities found in 2,849 recent contracts, $3,694 simulated value at $3,476 API cost | R | red.anthropic.com/2025/smart-contracts/ (located) |
| c27 | EVMbench: best exploit-mode score 72.2% vs 31.9% for prior generation | R | the-decoder.com coverage; arxiv.org/pdf/2603.10795 re-evaluation |
| c28 | A 2026 study found no agent completed an end-to-end exploit on 22 real incidents | R | yajin.org/blog/2026-03-18-ai-smart-contract-audit-reevmbench/ |
| c29 | Binance's initial report says an internal AI tool was abused for lateral movement from 20 Oct 2026 | R (weak: secondary summaries only) | airdropalert.com, hackernoon.com summaries |
| c30 | Chainalysis disclosed on 30 Oct 2026 an intrusion using "offensive agentic techniques" | R | theblock.co/news/business/2026-10-31-… |
| c31 | Canton supports Ed25519 and ECDSA P-256/P-384 signing; no official PQ roadmap found | R | docs.canton.network/global-synchronizer/reference/crypto-schemes |
| c32 | Swift shared ledger live in pilot 9 Jul 2026, 17 banks, permissioned Besu | R | finance.yahoo.com coverage; swift.com not read |
| c33 | ECB: Pontes to launch Q3 2026; Appia roadmap published 11 Mar 2026 | V | ecb.europa.eu/press/pr/date/2026/html/ecb.pr260311~14ddf51a77.en.html (located via search result; text to be read) |
| c34 | Pontes launched 21 Sep 2026 | R | securities.io |
| c35 | DTCC tokenised DTC-held assets on private Besu and on Canton, July 2026 | R | finadium.com |
| c36 | JPMD live on Base; Canton issuance announced Jan 2026 | R | pymnts.com, secondary |
| c37 | BIS Leap phase 2 (Dec 2025): PQ signatures functional in payment-system test; slower verification; hybrid untested | R | bancaditalia.it notice; BIS report not read |
| c38 | NIST IR 8547 final published 27 Oct 2026; deprecate after 2030, disallow after 2035 | R | postquantum.com/security-pqc/nist-ir-8547-final/ ; csrc.nist.gov not read |
| c39 | EU roadmap: national plans end 2026; high-risk by end 2030; as feasible by end 2035 | R | secondary summaries of the June 2025 NIS Cooperation Group document |
| c40 | G7 CEG PQC roadmap published 13 Jan 2026, non-binding | R | home.treasury.gov/system/files/136/G7-CEG-Quantum-Roadmap.pdf (located) |
| c41 | OCC final rule implementing GENIUS Act issued 21 Oct 2026 | R | occ.treas.gov/news-issuances/news-releases/2026/nr-occ-2026-92.html (located) |
| c42 | BCBS cryptoasset standard in force 1 Jan 2026; targeted review ongoing | R | bis.org/press/p260520.htm |
| c43 | The brief's §2 states the OpenAI exponent with "log n" where source and Chapter 1 have "√log n" | V | c2; docs/chapter-1.md |
