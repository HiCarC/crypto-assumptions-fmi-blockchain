# Technical annex: primary-source verification (checked 15 November 2026)

Labels: V = primary page read (note: WebFetch returns a small-model digest of the page, so figures were taken from that digest); R = secondary source or search excerpt; U = not found.

## 1. Fine-grained lattice lower bounds, and what NIST relies on

### 1a. Bennett, Golovnev, Stephens-Davidowitz, "On the Quantitative Hardness of CVP" (FOCS 2017) - V (arXiv abstract page)
- URL: https://arxiv.org/abs/1704.03928 (v1 12 Apr 2017, v2 5 Oct 2017)
- Finding: under SETH there is no 2^((1-eps)n)-time algorithm for CVP in the l_p norm, for any constant eps > 0. This holds for odd integers p and p = infinity, and then for almost all p >= 1 that are not even integers. It also covers p(n) != 2 that tends to 2. Also a SETH-hardness result for SVP in l_infinity, and constant-factor approximate CVP_p hardness under Gap-ETH.
- The Euclidean case p = 2 is not covered. The abstract says the results are "tantalizingly close to settling" CVP_2, which has a 2^(n+o(n)) algorithm. (Quote as given in the page digest; re-check the exact wording before citing.)

### 1b. Aggarwal, Stephens-Davidowitz, "(Gap/S)ETH Hardness of SVP" (STOC 2018) - V (arXiv abstract page)
- URL: https://arxiv.org/abs/1712.00942 (submitted 4 Dec 2017)
- Finding, SVP in l_p:
  - Almost all p > 2.1397: no 2^(n/C_p)-time algorithm under randomized SETH.
  - p > 2: no 2^(o(n))-time algorithm under randomized Gap-ETH, also for some constant approximation factor.
  - 1 <= p <= 2, which includes l2: no 2^(o(n))-time algorithm unless non-uniform Gap-ETH fails OR there is no family of lattices with exponential kissing number in l2.
- Relevance to ML-DSA/ML-KEM: these are worst-case, exact (or constant-factor) SVP/CVP lower bounds on 2^{Theta(n)} running time at growing dimension n. For l2 the SVP result is conditional on an extra kissing-number hypothesis. They say nothing about the approximation factors, module structure, dimensions (a few hundred) or average-case LWE/SIS distributions used in the schemes. My assessment: they do not apply to the concrete parameters. They are asymptotic evidence only.
- Note: my first fetch of arXiv 1611.05979 returned an unrelated paper (Regev and Stephens-Davidowitz, "A Reverse Minkowski Theorem"). It is not used here.

### 1c. Basis of ML-DSA security estimates - V for the Dilithium spec; U for the FIPS 204 text
- CRYSTALS-Dilithium specification, round 3: https://pq-crystals.org/dilithium/data/dilithium-specification-round3-20210208.pdf (dated 8 Feb 2021 by filename).
- I recovered the text with a hand-written PDF stream decoder (partial extraction). It reports the BKZ block size b, "Classical Core-SVP" and "Quantum Core-SVP" for each parameter set (NIST levels 2, 3, 5), plus a gate-count estimate (App. C.5). For example, level 2 is listed as classical Core-SVP 123 and quantum 112. The spec also describes extra, deliberately weak parameter sets by "bits of Core-SVP security". So the estimates come from concrete BKZ/core-SVP cost models of LWE/SIS attacks, not from ETH/SETH lower bounds. The extracted text contains no mention of ETH/SETH. This is only partial extraction, so I describe it as "none found", not "none exist".
- FIPS 204 (published 13 Aug 2024, per https://csrc.nist.gov/pubs/fips/204/final) - V for the date only. The PDF at https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf could not be text-extracted in this environment, so I did not read its security-strength wording. Status for FIPS 204's own text on core-SVP: U (not read).

## 2. Daml / Canton smart-contract upgrades - V (Canton docs, via the redirect from docs.digitalasset.com)
- URL: https://docs.canton.network/appdev/deep-dives/smart-contract-upgrade.md (docs.digitalasset.com/build/3.x pages now return a 307 redirect to docs.canton.network; the redirect target page for the 3.3 reference was only a notice). Fetched 15 Nov 2026.
- Finding (one paragraph): there is no separate authorisation ceremony for a new version. A new package version must pass upgrade-compatibility checks at two points: at compile time, where the `upgrades:` field in `daml.yaml` points to the previous DAR and `dpm build` compares against it, and at DAR upload, where the participant checks the new packages against those it already holds. The participant's result is final. Operators can run the same check beforehand (`validateDar`, console `dars.validate`, `dpm upgrade-check`). Each package ID must map to one (name, version) pair. Vetting is by participants: a package must be vetted by every participant informed about a transaction, both for the creating package and the target package. Vetting is on by default at upload. Which version runs is then decided by package preference (default: a version all involved participants know), which a client can override via `package_id_selection_preference`. A transaction is rejected if a confirming or observing participant has not vetted the preferred version. Package versions cannot be deleted, only unvetted (digest paraphrase of the page; check the exact wording before quoting).
- Search excerpt (R) also notes the older docs.digitalasset.com 3.3 page was marked work in progress: https://docs.digitalasset.com/build/3.3/reference/smart-contract-upgrades.html (not read directly; redirected).

## 3. Daml authorisation model - V (Canton docs page m3-authorization; digest), plus R (search excerpts of older Daml docs)
- URL: https://docs.canton.network/appdev/modules/m3-authorization.md (fetched 15 Nov 2026). The docs.digitalasset.com glossary https://docs.digitalasset.com/build/3.4/reference/glossary.html redirected and was not read directly (R only).
- Finding (one paragraph): signatories are the parties with the power to create and archive a contract, and creating a contract needs authority from all its signatories. A choice can be exercised only with the authority of its controllers (all of them, if several). Archive is an implicit choice whose controllers are the signatories, so archiving requires every signatory's authority. Inside a choice body the executing party holds the signatories' authority, but authority is not inherited implicitly across steps: each action's required authorisers must be a subset of its parent transaction's authorisers.
- Quote (as given in the digest): "The signatories are the parties with the power to create and archive contracts."
- Older confirmation (R): https://docs.daml.com/1.4.0/daml/intro/6_Parties.html

## 4. Trail of Bits "Frozen Heart" (2022) - V
- URL: https://blog.trailofbits.com/2022/04/13/part-1-coordinated-disclosure-of-vulnerabilities-affecting-girault-bulletproofs-and-plonk/ (published 13 Apr 2022; disclosed to affected parties 18 Mar 2022).
- Finding: Frozen Heart is a class of vulnerabilities from insecure implementations of the Fiat-Shamir transformation, letting attackers forge zero-knowledge proofs for statements they cannot prove. Proof systems affected: Girault's proof of knowledge, Bulletproofs, PlonK. Implementations named: ZenGo zk-paillier, ING zkrp, SECBIT ckb-zkp, Adjoint bulletproofs, Dusk Network plonk, Iden3 SnarkJS, ConsenSys gnark. Quote: "The word frozen is an acronym for FoRging Of ZEro kNowledge proofs."
- Caveat: the digest I read did not state in so many words that the cause is public values left out of the transcript hash. I know this from the series' wider content, but it was not confirmed in the text I read. Mark as unconfirmed here; re-read the post (or Part 2/3) before asserting it.

## 5. Chaliasos et al., SoK on SNARK vulnerabilities (USENIX Security 2024) - V
- URLs: https://arxiv.org/html/2402.15293v1 (arXiv 2402.15293, v1 Feb 2024; read in full via the HTML and checked by text search on a local copy); venue page https://www.usenix.org/conference/usenixsecurity24/presentation/chaliasos (August 2024, Philadelphia).
- Finding: 141 vulnerability reports, spanning about six years (2018-2024). Table 4 (circuit layer): 99 circuit vulnerabilities, 95 of them under-constrained (the table's total row reads 95 / 1 / 3 / 99 for UC / OC / computational-error / total). That is about 96% of the circuit layer and about 67% of all 141 (my arithmetic: 95/141). The paper calls it the most frequent circuit vulnerability: "The most frequent vulnerability in ZK circuits arises from insufficient constraints." Under-constrained is rank 1.
- Caveat: this is the arXiv v1 numbers. The published USENIX version (later arXiv versions) may differ slightly; I did not compare.

## 6. EIP-7702 and Pectra - V
- EIP: https://eips.ethereum.org/EIPS/eip-7702 (read 15 Nov 2026).
- Finding: set-code transaction type 0x04 carrying an `authorization_list`. Each authorization tuple is `[chain_id, address, nonce, y_parity, r, s]`. chain_id is 0 (valid on any chain) or the current chain. address is the 20-byte code target. nonce must match the authority's nonce, which is incremented on processing. The signature is secp256k1 over `keccak(0x05 || rlp([chain_id, address, nonce]))`. The result is stored in the account's code as the delegation indicator `0xef0100 || address`. It persists until replaced by a new authorization or cleared by authorizing the zero address (which resets the code hash to empty). It is not temporary.
- Activation: Pectra went live on mainnet on 7 May 2025 at 10:05:11 UTC, epoch 364032 (block 22,431,084 per the history page), and includes EIP-7702.
  - https://ethereum.org/en/history/ - V (states activation date, time, block and epoch).
  - https://blog.ethereum.org/2025/04/23/pectra-mainnet - V (pre-announcement; "scheduled" wording, same date/epoch).

## 7. Ronin (2022) and Nomad (2022)

### Ronin - R (primary not readable)
- Intended primary: Sky Mavis post-mortem, "Back to Building: Ronin Security Breach Postmortem" https://roninchain.com/blog/posts/back-to-building-ronin-security-breach-6513cc78a5edc1001b03c364 returned HTTP 404; the substack/blog.roninchain.com variants gave a 301 then 404. Not read. Status for the primary: U (not read).
- Finding from search excerpts (R): 173,600 ETH and 25.5M USDC drained from the Ronin bridge. Cause: attacker controlled five of nine validator keys (four Sky Mavis validators plus the Axie DAO validator, whose allowlist access from Nov 2021 had not been revoked). Attack dated 23 Mar 2022 in the post-mortem; publicly discovered/announced 29 Mar 2022. Secondary values: about $600-625 million.
- Secondary URLs: https://www.theblock.co/post/143821/sky-mavis-plans-to-become-a-zero-trust-organization-after-600-million-ronin-hack ; https://slowmist.medium.com/ronin-exploit-largest-crypto-hack-to-date-8b7c581e38fd (search excerpts only).

### Nomad - R (primary blocked)
- Intended primary: https://medium.com/nomad-xyz-blog/nomad-bridge-hack-root-cause-analysis-875ad2e5aacd returned HTTP 403 (Medium). The variant ...875ad2e5aac6 that I first tried was a mistyped ID, also 403. I did not attempt to work around the block. Status for the primary: U (not read).
- Finding from search excerpts (R): Nomad's own post (opening only): "An implementation bug caused the Replica contract to fail to authenticate messages properly", so fraudulent messages reached BridgeRouter. Secondary sources (Immunefi, CertiK, PeckShield via The Block) tie it to a 21 Jun 2022 upgrade that initialized the zero value as a trusted/confirmed root, so unproven messages (root 0x00) passed the check; attackers copied and re-addressed transactions. Loss about $186-200 million (CertiK: about $190M), 1 Aug 2022. About $8.2M was taken by white-hat addresses.
- Secondary URLs: https://immunefi.com/blog/bug-fix-reviews/hack-analysis-nomad-bridge-august-2022/ ; https://www.certik.com/blog/nomad-bridge-exploit-incident-analysis ; https://www.coinbase.com/blog/nomad-bridge-incident-analysis (search excerpts only).

## Summary of labels
1. Lattice ETH/SETH bounds: V (both arXiv abstracts); Dilithium spec core-SVP basis V (partial text extraction); FIPS 204 body text U (date only V).
2. Daml/Canton upgrades: V (docs.canton.network, the redirect target of docs.digitalasset.com); older digitalasset page not read directly.
3. Daml authorisation: V (docs.canton.network module page); older glossary R.
4. Frozen Heart: V (Trail of Bits post); "public values omitted" wording not confirmed in the text read.
5. SoK SNARKs: V (arXiv HTML, 141 total, 95 of 99 circuit bugs under-constrained, about 67% overall).
6. EIP-7702 and Pectra: V (EIP page, ethereum.org history, EF blog).
7. Ronin and Nomad: R for both (primaries returned 404 and 403); amounts and root causes are from secondary excerpts only.
