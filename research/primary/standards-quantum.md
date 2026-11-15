# Standards, regulation and quantum exposure: primary-source verification
Verified 15 Nov 2026. Labels: V = I read the primary/official page myself; R = secondary only (search snippets or vendor/press); U = not found/not opened.
Method caveats: WebFetch could not decode PDFs. For NIST IR 8547 (final) and the G7 CEG roadmap I read text I extracted locally from the PDF copies the fetch tool saved (rough extraction, tables partly garbled). A direct curl download of PDFs was attempted early on (two files) and later blocked by the permission system; I did not retry. Several primary PDFs (FIPS 204, CNSA 2.0 FAQ, PFMI, BIS Paper 158 and Leap PDFs, DORA text on EUR-Lex) could NOT be read.

## 1. NIST IR 8547 - V (page + PDF text)
- Claim: Final, reported 27 Oct 2026. CONFIRMED. csrc page history: "10/27/26: IR 8547 (Final)"; earlier draft 11/12/24. PDF cover: "October 2026". URL: https://csrc.nist.gov/pubs/ir/8547/final ; PDF https://nvlpubs.nist.gov/nistpubs/ir/2026/NIST.IR.8547.pdf
- Rules (PDF s.4.1.1, Table 2): "NIST will ... deprecate all quantum-vulnerable digital signature algorithms after 2030 and disallow their use ... after 2035." Table lists ECDSA, EdDSA, RSA: "Deprecated after 2030 / Disallowed after 2035". Same for key establishment (FF DH/MQV, EC DH/MQV): "deprecate all quantum-vulnerable cryptography after 2030 ... disallow ... after 2035."
- Security strength: the final text I could extract states the 2030/2035 dates for the 112-bit strength rows ("112 bits of classical security strength: Deprecated after 2030, Disallowed after 2035"), and the extracted text says the old SP 800-57 plan (disallow 112-bit on 1 Jan 2031) is replaced. I could NOT cleanly extract a separate >=128-bit row. DISCREPANCY RISK: the 2024 draft (ipd) split 112-bit (deprecated 2030, disallowed 2035) from >=128-bit (disallowed 2035 only). The final's prose says "all" quantum-vulnerable algorithms are deprecated after 2030; check Table 2 in the PDF by eye before citing the 128-bit treatment.
- Other: final references Executive Order 14412 (22 Jun 2026) and OMB M-26-15 (via csrc page). Document says goal of completing migration "by 2035".
- Quote: "deprecate all quantum-vulnerable digital signature algorithms after 2030 and disallow their use ... after 2035".

## 2. FIPS 203/204/205/206 - V for dates, U/R for sizes and FN-DSA
- FIPS 203 final 13 Aug 2024 (V, https://csrc.nist.gov/pubs/fips/203/final). Page also carries a 17 Nov 2025 planning note that an issue was identified and will be corrected in a future update.
- FIPS 204 final 13 Aug 2024 (V, https://csrc.nist.gov/pubs/fips/204/final).
- FIPS 205 final 13 Aug 2024 (V, https://csrc.nist.gov/pubs/fips/205/final).
- FIPS 206 FN-DSA: csrc /pubs/fips/206/ipd and /final returned 404; I did not find an official NIST page. Secondary (R): still draft, final expected late 2026/2027; a 2026 NIST slide deck still listed it as "under development"; one vendor summary of NIST IR 8610 (14 May 2026) says still draft. Status U/R.
- ML-DSA sizes (R, not read in FIPS 204 itself): pk/sig bytes 44: 1312/2420; 65: 1952/3309; 87: 2592/4627. Sources: liboqs table https://openquantumsafe.org/liboqs/algorithms/sig/ml-dsa , Arm PSA docs, Go crypto/mldsa constants. FN-DSA-512 sizes: U (secondary Falcon-512 figures in an EIP-8052 forum thread: pk 897, sig ~666 bytes; not from FIPS 206).

## 3. NSA CNSA 2.0 - R (primary not opened)
- nsa.gov pages blocked/403. Secondary consensus: new NSS acquisitions CNSA 2.0 compliant from 1 Jan 2027 (FAQ v2.1, Dec 2024, CNSSP 15); exclusive use for software/firmware signing and networking by 2030; other categories 2033; all NSS quantum-resistant by 2035. Sources disagree 2031 vs 2033 for some categories. URL to check: https://media.defense.gov/2022/Sep/07/2003071836/-1/-1/0/CSI_CNSA_2.0_FAQ_.PDF (not opened). Label R.

## 4. EU Coordinated Implementation Roadmap (NIS CG) - V partial, R milestones
- V: Commission page https://digital-strategy.ec.europa.eu/en/library/coordinated-implementation-roadmap-transition-post-quantum-cryptography : published 23 June 2025; first deliverable of NIS CG workstream following the 11 Apr 2024 Recommendation; page "Last update" 3 Sept 2026; related item "EU Roadmap on PQC - Survey feedback" dated 2 Sept 2026 (survey 11 Aug-29 Sep 2025). Page does not say what changed in 2026.
- R (roadmap PDF not read): start by 31 Dec 2026 (national plans, first steps); high-risk use cases by end-2030 ("as soon as possible, no later than"); as many systems as feasible by 2035. Roadmap doc v1.1 dated 11 June 2025 per vendor reports.

## 5. G7 CEG roadmap - V (PDF text extracted locally)
- URL as given. Title: "G7 Cyber Expert Group Statement on Advancing a Coordinated Roadmap for the Transition to Post-Quantum Cryptography in the Financial Sector"; TLP:CLEAR. I did not extract a clean publication date from the text (Jan 2026 per your brief: unconfirmed by me).
- Non-binding: roadmap "presents considerations to promote harmonization ... while preserving flexibility"; "may serve as a resource". Targets: 2035 as "general target" (note: "Current guidance ... often points to 2035"); critical systems "for example ... 2030-32"; "Target dates are subject to change"; dual-track, risk-based, not prescriptive.

## 6. BIS Papers 158 and Project Leap phase 2 - V (abstract pages only)
- Paper 158 (July 2025) https://www.bis.org/publ/bppdf/bispap158.htm : V abstract only: start now; inventory; PQC is practical near-term option; "cryptographic agility, defence in depth, hybrid models, and phased migration"; QKD longer-term. Full PDF not read.
- Leap phase 2: https://www.bis.org/publ/othp107.htm dated 11 Dec 2025. V: with BIS Innovation Hub Eurosystem Centre, Banca d'Italia, Banque de France, Bundesbank, Nexi-Colt, Swift; replaced traditional digital signatures with PQC when sending liquidity transfers; "significant performance differences between traditional and post-quantum algorithms"; lessons on performance, interoperability and cryptographic agility. Page names no algorithm and does not state hybrid or not.
- R (secondary, not verified in PDF https://www.bis.org/publ/othp107.pdf): verification averaged ~209.9 ms vs 28.1 ms RSA (no HSM); described as Round-3 Dilithium by one source, ML-DSA by others; one source says hybrid was recommended but not tested in phase 2 (phase 1 did hybrid); a certificate incident reportedly blocked a settlement. Treat all as R.

## 7. CPMI-IOSCO PFMI - mostly U
- V: Cyber guidance is CPMI Papers No 146, 29 June 2016, https://www.bis.org/cpmi/publ/d146.htm : adds no new standards beyond PFMI; supplements governance, comprehensive risk management, settlement finality, operational risk, FMI links.
- PFMI Principles 2, 8, 15, 17 wording: U (PDF not opened). CPMI/BIS 2024-26 tokenisation report: U (not searched successfully).

## 8. DORA / MiCA / DLT Pilot - R
- DORA Reg (EU) 2022/2554: EUR-Lex fetch returned empty; application date 17 Jan 2025 is R (one secondary source), widely known but not read by me. Art 9(2) ICT security policies; RTS (EU) 2024/1774 Art 6 "Encryption and cryptographic controls" and Art 7 "Cryptographic key management" (lifecycle, replacement of lost/compromised keys, certificate register) - R via advisera/springlex. TLPT (Art 26) and third-party (Arts 28-44): U.
- DLT Pilot Regime (EU) 2022/858 applies since 23 Mar 2023 (R). Commission Market Integration and Supervision Package 4 Dec 2025 proposes making it permanent, higher thresholds, simplified regime below EUR 10bn; ECON draft reports 12 June 2026; Commission targets agreement end-2026 (R: Taylor Wessing https://www.taylorwessing.com/en/insights-and-events/insights/2026/06/dlt-pilot-regime-reform, PwC). Package also amends MiCA. Separate MiCA review status: U.

## 9. US - V (OCC) / R (Fed)
- OCC NR 2026-92, 21 Oct 2026, V https://www.occ.gov/news-issuances/news-releases/2026/nr-occ-2026-92.html : final rule for permitted payment stablecoin issuers (reserves, redemption, risk management, certain custody); effective 18 Jan 2027 ("for both the final rule and the GENIUS Act" per page summary); BSA/AML/OFAC in separate rulemaking.
- Fed (R): Aug 15 2025 ended Novel Activities Supervision Program; Dec 2025 rescinded 2023 policy statement (Orrick, Paul Hastings, The Block). No 2026 statement found.

## 10. BCBS SCO60 - R / V partial
- In force 1 Jan 2026 (R). V: BIS press release 20 May 2026 https://www.bis.org/media-releases/20260520-basel-committee-agrees-publish-report-information-and-communication-technology-risk-management : Committee "expedited a review of targeted elements" of the cryptoasset standard; "An update will be provided later this year." The release does not mention permissionless blockchains. Earlier: Nov 2025 expedite announcement, 25 Feb 2026 progress (R/URLs from search). Permissionless treatment: R only - industry (WFE, trade groups Aug 2025) ask to drop de facto Group 2 exclusion; 2023 consultation said unique risks "cannot be sufficiently mitigated at present". No outcome published as of my searches.

## 11. Google Quantum AI, 31 Mar 2026 - V (blog) / R (paper)
- V blog https://research.google/blog/safeguarding-cryptocurrency-by-disclosing-quantum-vulnerabilities-responsibly/ : two Shor circuits for ECDLP-256, "less than 1,200 logical qubits" (~90M Toffoli) and "less than 1,450" (~70M Toffoli); under 500,000 physical qubits on superconducting hardware (~20x reduction); runs in "a few minutes"; estimates backed by zero-knowledge proof. Exposed-bitcoin estimate: not on blog page; paper itself not opened (U).
- R: press says a 10% chance of Q-day by 2032 (PC Gamer headline); not verified.

## 12. Exposed public key estimates
- Glassnode V https://research.glassnode.com/measuring-bitcoins-quantum-exposed-supply/ published 20 May 2026: 6.04M BTC = 30.2% of issued supply. Definition: BTC in outputs where "the spending public key is already visible on-chain" (at-rest). Structural 1.92M (9.6%: P2PK, bare multisig, P2TR); operational 4.12M (20.6%: address reuse, partial spend, custody; exchange-related ~1.6M).
- 7.12M BTC / 35.4% as of 10 Nov 2026: R only (CoinAlertNews 11 Nov 2026, CoinEdition, CryptoBriefing etc.); the Glassnode page I opened does not contain it; I did not find the 10 Nov Glassnode primary. Whether definition changed: unknown.
- Project Eleven ~6.99M: NOT confirmed. Search found ~6.9M (one report) and Project Eleven's own count of 10,095,693 addresses holding 6,262,905 BTC with exposed keys (R). Definition (non-zero-balance address with public key exposed) per R. Chaincode Labs, Deloitte: U.

## 13. BIP-360 / BIP-361 - V (raw bips repo)
- BIP-360: Status Draft (raw.githubusercontent.com/bitcoin/bips/master/bip-0360.mediawiki). Pay-to-Merkle-Root (P2MR): new output type by soft fork, SegWit v2, 32-byte program, bc1z addresses; like P2TR without key-path spend. Protects against "long exposure" attacks. Includes NO post-quantum signature; PQ signatures (ML-DSA, SLH-DSA candidates) deferred to a separate proposal; earlier versions had PQ algorithms, later removed.
- BIP-361: Status Draft; header "Assigned: 2026-02-11". Content of what it specifies: not extracted (U).

## 14. Ethereum - V partial
- https://pq.ethereum.org (V, last updated 27 Jun 2026): forks I* PQ key registry; J* PQ signature precompiles; L* PQ attestations, leanVM; M* PQ signature aggregation, PQ blobs; longer term full PQ consensus and transactions. "No single fixed date"; L1 protocol upgrades could be completed by 2029; CRQC "early-to-mid 2030s". No EIP numbers or dates on page. ethereum.org quantum page: not opened.
- EIP-8051 (ML-DSA, Draft, created 2025-10-15) and EIP-8052 (Falcon, Draft): R via search snippets of eips.ethereum.org; competing EIP-8355 (created 2026-07-30; ML-DSA 44/65/87). 
- EIP-7951 (secp256r1 precompile) V: Final, created 2025-05-27; page does not name the fork (I believe Fusaka/Osaka but NOT verified). EIP-7702 V: Final, created 2024-05-07; page names no fork or date. Pectra activation (7 May 2025 from my memory) NOT verified.

## 15. Stellar QPP - V (stellar.org)
- https://stellar.org/blog/foundation-news/introducing-the-quantum-preparedness-plan : Stage 1 (2026) Soroban native host functions for ML-DSA-44 and ML-DSA-65, contract accounts; Stage 2 (2027) CAP adds quantum-safe signer types to classic accounts, opt-in, same address; Stage 3 deprecation of Ed25519, "no date", depends on quantum progress. Page shows no publication date. A stellar.org search snippet says June 4 2026; later quarterly post says June 9 (R). Brief says June 2026: consistent. Protocol 30 "Bell" includes CAP-87 (R).

## 16. AI exploit benchmarks
- SCONE-bench V https://www.anthropic.com/research/smart-contracts (redirect from red.anthropic.com): 405 exploited contracts 2020-2025 (Ethereum, BSC, Base); 10 models Best@8 exploited 207/405 (51.11%), $550.1M simulated; post-cutoff: 19 problems (55.8%), up to $4.6M; Opus 4.5 13/20 after 1 Jun 2025 ($3.7M). Zero-day: Sonnet 4.5 and GPT-5 on 2,849 recent BSC contracts: 2 novel vulnerabilities, $3,694 simulated revenue; GPT-5 run cost $3,476 total, $1.22 per run, $1,738 per vulnerable contract, avg revenue $1,847, net $109 per exploit.
- EVMbench (R; openai.com returned 403): released 18 Feb 2026 by OpenAI and Paradigm; 117 (OpenAI page) vs 120 (paper) vulnerabilities from 40 audits; best exploit score 72.2% (GPT-5.3-Codex, Decrypt). 
- Weaker on real incidents (R, arXiv): "Re-Evaluating EVMBench" (Mar 2026): 22 post-mid-Feb-2026 real incidents, no agent achieved end-to-end exploitation in 110 agent-incident pairs, best detection 65%. CyberChainBench (arXiv 2606.26216, Jun 2026): 541 DeFiHackLabs incidents, best detection 37.5%, exploit 43.7%, patch 23.4%.

## Summary (10 lines)
1. V: NIST IR 8547 is final (page history 10/27/26, PDF dated Oct 2026); ECDSA/EdDSA/RSA deprecated after 2030, disallowed after 2035; the final's 128-bit-and-above treatment needs a manual check against the draft split.
2. V: FIPS 203/204/205 all final 13 Aug 2024; FIPS 206 not confirmed on NIST (404), reported draft; ML-DSA/FN-DSA sizes are R only.
3. V: OCC NR 2026-92 dated 21 Oct 2026, effective 18 Jan 2027; V: Basel review "update later this year", no permissionless detail.
4. V: G7 CEG roadmap non-binding, 2035 general target, critical systems 2030-32; date not extracted. V: EU roadmap page (23 Jun 2025, page updated 3 Sep 2026) but milestones R (end-2026/2030/2035).
5. V: Google blog: <1,200 / <1,450 logical, <500k physical qubits, minutes; exposed-BTC figure in paper not found.
6. CONTRADICTION: Glassnode's own page says 6.04M BTC / 30.2% (20 May 2026); 7.12M / 35.4% (10 Nov 2026) is press-only. Project Eleven ~6.99M not found (found ~6.9M and 6.26M BTC).
7. V: BIP-360 Draft, P2MR, no PQ signature; BIP-361 Draft (assigned 2026-02-11). V: Stellar QPP stages 2026/2027/undated; pq.ethereum.org no dates, ~2029 L1.
8. V: SCONE-bench 405 contracts, 207 (51.11%), zero-day 2 finds on 2,849 contracts, $3,476 cost. EVMbench 117 vs 120 vulnerabilities inconsistency; weaker real-incident results (R) exist.
9. Not read (R or U): CNSA 2.0, DORA text, PFMI principles, Leap measurements/hybrid/algorithms, BIS 158 body, Fed 2026, MiCA review, EVMbench primary, Chaincode/Deloitte.
10. Caveat: PDF text for IR 8547 and G7 came from local extraction of fetch-tool copies; a direct curl attempt was made then blocked.
