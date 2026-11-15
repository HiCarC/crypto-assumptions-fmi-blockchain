# Author brief — Chapter 2 (Checkpoint 3)

15 November 2026. Article: `article/final.md` (1,782 words including TL;DR, figure caption and lists; 0 displayed equations). Draft and review: `article/draft.md`, `article/review-log.md`. Annex: `report/annex.pdf` (18 pages). Repository: private on GitHub.

## 1. Thesis in three sentences

The AI-generated 3-SAT results of October 2026 do not weaken the cryptography blockchains rely on, and in the largest incidents the mathematics held while valid signatures carried the wrong instructions. What decides whether a ledger's cryptography protects an asset is who holds four powers: signer policy, upgrade, freeze, and the registrar that decides which keys count. For most institutional ledgers those holders are not found in public material, and moving to post-quantum signatures carries a measurable cost that only a ledger's governance can lower.

**How the evidence changed the thesis.** The brief expected to show that blockchains change the *consequence and remedy* of a cryptographic failure through immutability and exposed keys. Three findings moved it:

- *Immutability is not a property of the ledger.* About US$2.85 billion of the Binance proceeds was frozen or intercepted. Whether a loss is final depends on who holds a freeze power over each asset. That turned "immutability" into one of the four powers.
- *The Binance mechanism.* A protocol upgrade added a new message type, and a signing service was used to sign it. This put signer policy and upgrade at the centre, ahead of exposed keys.
- *The cost measurement.* Application-level agility stops at the ledger's own transaction signature, and holders who do not migrate are stranded. This made post-quantum migration a governance question as much as a technical one, and the second pillar.

## 2. Step-size audit

One row per paragraph of `article/final.md` (headings and the figure excluded; the two numbered lists are counted as one row each). *Prior knowledge* is what the reader persona (Head of FMI Oversight, euro-area NCB) must already have. *Evidence* points to `CLAIMS.md`.

| # | Single claim | Prior knowledge assumed | Step | Action taken | Evidence |
|---|---|---|---|---|---|
| 1 | TL;DR: October results don't weaken ledger cryptography; four powers; disclosure gap; PQ cost | none | medium (summary) | Kept as summary; each point developed below | A3, B1–B5, C1, C15 |
| 2 | An attack affected about US$6.3bn at Binance, more than four times Bybit | none | small | "Taken" used for Bybit to avoid mixing measures | B1, B10 |
| 3 | Binance found no evidence a key leaked | knows a key signs | small | — | B4 |
| 4 | A signing service was misused to obtain an authorisation type added in May 2025, letting attacker code act on a hot wallet | none | medium | "Hot wallet" defined; "handing control" softened to Binance's wording | B2, E3 |
| 5 | Signatures valid, mathematics held, instructions wrong | 2–4 | small | — | B2 (Chainalysis: valid signed authorisations) |
| 6 | Chapter 1 found no newly feasible attack and promised this question | Chapter 1 | small | — | Chapter 1 |
| 7 | The problem is not the mathematics; it is the powers | 6 | small | Bridge sentence kept (review 6.3) | — |
| 8 | Both papers are preprints about growth of hard instances | knows what an algorithm is | small | Plain-language explanation, no symbols | A1, A3 |
| 9 | Ledger cryptography does not rest on that hardness (author's reading) | 8 | medium | Marked as the author's reading (review 1.1) | A5 (I), A6 (V) |
| 10 | Today's solvers stop at 18–19 of 64 rounds; at full rounds they are slower than a simple search | knows what a hash is | medium | Kept concrete; no extrapolation | C13 |
| 11 | That is about today's tools; look elsewhere for the risk | 10 | small | "One way of writing the problem" added (review 1.4) | C13 |
| 12 | Immutability is a property of each asset, set by four powers | 7 | medium | Introduces the spine; the four powers follow one per paragraph | I (author's framing) |
| 13 | Signer power: a service that checks the caller, not the request, hands over an account | knows a signing system exists | small | Now our reconstruction, not a claim about Binance (review 3.1) | C7 |
| 14 | Upgrade power: an upgrade changed what a signature does; the attacker used it | 4 | small | "Policy not ready" removed (review 3.2) | E3, B2 |
| 15 | Freeze power: US$2.85bn frozen or intercepted; freezes need someone with the power | none | small | Generalised (review 5.5) | B5 |
| 16 | Registrar power: key replacement is remedy and single point of control | 15 | small | — | C5 |
| 17 | These are cryptographic and governance powers at once | 13–16 | small | — | I |
| 18 | An exchange is not an FMI, but tokenised settlement uses the same parts | knows FMIs well | small | Required bridge paragraph | I |
| 19 | Well-run FMIs have stronger controls; the same questions still apply; some answers lie outside | 18 | small | Added for the strongest counter-argument (review 5.1) | I |
| 20 | TRM Labs H1 2026: 207 hacks, US$972m; infrastructure 15% of incidents, 76% of losses | none | small | Industry figures with source, as instructed | B13 |
| 21 | In the incidents we examined, none came from a broken primitive | 20 | small | Qualitative; no shares from the twelve-case list | B14, B15, B16 (partly R; see §4) |
| 22 | Chapter 1's test; AI attacks come closer, at least in benchmarks | Chapter 1 | small | Softened (review 5.4) | D19, D20 |
| 23 | Benchmark: 207 of 405 exploited in simulation; 2 new flaws in 2,849 contracts for about US$3,476 | knows what a smart contract is | small | — | D19 |
| 24 | Binance report mentions an AI tool; the capability targets where losses are | 22–23 | small | — | B6 |
| 25 | We inventoried 27 platforms from public material | none | small | — | C15 |
| 26 | 47 of 56 answers for 14 institutional and central-bank platforms not found | 25 | small | Wording "not found in public material" | C15 |
| 27 | Not evidence of weakness; answers must be requested | 26 | small | — | I |
| 28 | A quantum computer would break today's signatures; NIST and EU dates | conceptual quantum threat | small | Precision added (review 1.2) | D1, D5 |
| 29 | ML-DSA verification costs about 1,000 times as much gas; signature 37 times larger | 28 | medium | "Gas" defined in one clause | C1, C2 |
| 30 | Figure caption | 29 | small | Caption claims only what the data show | C1 |
| 31 | The cost can fall: optimised variant, native verifier; only governance can build one in | 29 | medium | Kept as one step ("the cost is not fixed, but…"); split from Leap | C1; ETHDILITHIUM README (authors' report) |
| 32 | Project Leap: PQ worked on a T2 test, at least ten times slower; hybrid not done | knows T2 | small | Split out (review 2.2) | D23 |
| 33 | Changing the scheme in contracts does not reach the ledger's own signature | 29 | medium | Split (review 2.3) | C6 |
| 34 | Holders who do not migrate keep balances but cannot sign; registrar restores them | 16 | small | Split (review 2.3) | C5 |
| 35 | Six questions for authorities | 13–34 | small | Each maps to one power, the PQ cost, or disclosure | — |
| 36 | Four sequenced actions tied to the EU roadmap, DORA, PFMI and NIST | DORA, PFMI | small | Action 2 names the control (review 2.6) | D5, D22, D21, D1 |
| 37 | PFMI's four closest principles don't mention cryptography; DORA's standard covers updates without naming quantum | DORA, PFMI | small | Split (review 2.4) | D21, D22 |
| 38 | Frameworks reach these powers generally but don't ask about the ledger | 37 | small | Marked as the author's assessment | I |
| 39 | Closing test: who can sign, change the rules, freeze; then the mathematics | Chapter 1 | small | Echoes Chapter 1 without repeating it | — |

No paragraph is rated "large". Medium steps are each preceded by the paragraph that supplies the needed knowledge, or define their term in one clause.

## 3. Adversarial review

Six reviews were done: cryptographer, FMI overseer, G-SIB CISO, smart-contract auditor, sceptical journalist or economist, and the Chapter 1 reviewer. Twenty-five objections were raised; all are resolved or deliberately kept with a reason. Full log: `article/review-log.md`. The most important changes:

- Two statements about Binance that went beyond Binance's own report were removed: that the signing service checked only the caller, and that its policy "was not ready". The signer-policy point is now made through our own reconstruction.
- The claim that ledger cryptography does not rest on the hardness ETH describes is presented as the author's reading of the security analyses.
- The strongest counter-argument (regulated FMIs are not exchanges) is answered in the text.
- Three over-dense paragraphs were split.

## 4. Points to check personally before publishing

1. **"In the major incidents we examined, we found none that came from a broken cryptographic primitive"** (paragraph 21). This is true of the repository's list, but some root causes in it (Bybit, Ronin, Wormhole, Nomad, Poly Network) are only reported, because the operators' post-mortems could not be opened. It is consistent with all published analyses we saw. If you prefer only fully verified support, cut the sentence and keep the TRM figures.
2. **The Binance figures** come from Binance's own blog post of 3 November. Its numbers changed between updates (frozen: about 3 billion, then 2.85 billion). Please open the page yourself; the fetch tool summarised it.
3. **The North Korea attribution** is absent from the article, as you decided. It appears in the annex only as "according to press reports".
4. **"The hash function behind Bitcoin"** for SHA-256 is common knowledge; no source is cited.
5. **The seven-times-cheaper ML-DSA variant** is the verifier authors' own figure, from their README. We did not measure it.
6. **The Chapter 1 link** is the published URL. The annex and repository links are placeholders until you decide.
7. **Figure 1** (`results/fig_gas.png`) has a white background, and its title duplicates the caption. Consider cropping the title for Substack.

## 5. Proposed Chapter 3

**Post-quantum migration of payment systems.** It follows directly from three results of this chapter: the measured cost of post-quantum verification on a ledger, Project Leap's finding that hybrid signatures were not yet achievable in a T2 test, and the stranded-holder problem. It would ask what a 2030 deadline means for RTGS systems, messaging networks and tokenised settlement, and who must decide what, by when. The annex already holds the migration model and the policy dates.

Alternative: **AI as an attacker of financial infrastructure.** This is the capability that passed Chapter 1's test. It would build on the benchmark evidence and the Binance report's mention of an internal AI tool. It is better saved for Chapter 4, when more incident evidence is public.

## 6. External actions awaiting your approval

| Action | Status |
|---|---|
| Publish the article on Substack | Awaiting your approval |
| Publish the annex PDF (and where to host it) | Awaiting your approval |
| Make the GitHub repository public, or share it with named reviewers | Awaiting your approval; it is private today |
| Add the `CERTORAKEY` secret to enable the Certora CI job | Your action, if wanted |

## 7. Definition of done (brief §13)

| Item | Status |
|---|---|
| Chapter 1 promise answered (consensus, signatures, ZK, smart-contract execution, "a different security problem") | Done. Consensus and ZK are covered in annex §2; the article covers signatures, contracts and the "different problem" through the four powers |
| October results re-verified as of today | Done (annex §2) |
| Every factual claim in the ledger with a label and source | Done (`CLAIMS.md`); the article uses V claims plus marked inferences |
| 0–1 displayed equations; every paragraph passed the step-size audit | Done (0; table above) |
| Tests, fuzzing, static analysis and formal checks run, with reports committed; failures disclosed | Done (Medusa failure disclosed) |
| Every number and figure reproducible with one command | Done (`make all`; Certora and mutation have their own targets) |
| Six adversarial reviews done and logged | Done |
| No invented probabilities, no "immunity", no fabricated sources | Checked |
| Nothing published or pushed publicly without approval | Confirmed: the repository is private |
