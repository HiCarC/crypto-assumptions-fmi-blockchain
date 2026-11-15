# Adversarial review log — Chapter 2, version 2 (layer by layer)

Text reviewed: `article/draft.md` (v2), revised into `article/final.md`. Version 1 (powers framing) and its review are kept in `final-v1-powers.md` and `review-log-v1.md`. Objections were written down before any revision. The cryptographer's review was weighted most, as the rewrite instruction asks.

## 1. Applied cryptographer (weighted most)

| # | Objection | Resolution |
|---|---|---|
| 1.1 | **Any NP problem reduces to SAT, so a faster SAT algorithm *is* a route to the discrete-logarithm problem.** The draft's "offers no known route" is wrong as stated. | Rewritten. The route exists in principle, but the formula is far larger than the SHA-256 one (about 72,000 variables in my encoding), so the claimed speed-up leaves it far slower than known attacks. Marked as the author's reading (CLAIMS F13, F14). |
| 1.2 | "Not known to be one of the hard problems 3-SAT represents" is loose. The discrete-logarithm problem is not believed to be NP-complete. | Now "not believed to be among the hardest problems that 3-SAT stands for". |
| 1.3 | The local-PRG nuance in the draft claimed OpenAI's result "concerns" pseudorandom generators. The paper speaks only of Goldreich's candidate one-way functions, and adds that polynomial-time one-wayness is not ruled out. | Rewritten to the paper's own claim and caveat (F1). The link to generators and obfuscation is stated separately, as Jain–Lin–Sahai's assumption (F3), with "I found no published analysis" of whether the result matters there. |
| 1.4 | Reduced-round SHA-256: the draft left the literature unverified. | Now cites the verified 42-step attack at almost brute-force cost (F4). The 43- and 45-step results are reported only (F5) and are not used. |
| 1.5 | **My 18-round SAT result appears to exceed the SAT literature (16 rounds in 2012, 19 only in 2026 with a specialised solver).** | Every solution was checked against the hash, so the result holds for my definition. But definitions were not reconciled, so the article makes no comparison with the SAT literature; the caption says "one straightforward encoding of my own". Recorded in LIMITATIONS, and item 1 of the author's checks. |
| 1.6 | Ethereum's validators use BLS signatures, but the attestation use was not read at source. Ed25519 is a signature scheme, not a curve, and "usually elsewhere" generalises. | Now "BLS signatures on the BLS12-381 curve in Ethereum's case, Ed25519 in several permissioned ledgers". Supported by the BLS12-381 type in the consensus specification (F10), Canton's default (D13) and CometBFT's documented configuration (F11). |
| 1.7 | "Because the strong form implies the ordinary one" is standard but sourced only to a survey. | Kept as a standard implication; labelled R/I (F12). |
| 1.8 | ZK soundness list: STARKs rest mainly on hashing and the random-oracle model; SNARKs on curve and knowledge assumptions. | The list covers both; no change. |

## 2. Head of FMI oversight (primary persona)

| # | Objection | Resolution |
|---|---|---|
| 2.1 | "SAT solver" and "round" are not defined. | Both defined in one clause in the hook. |
| 2.2 | "Pairing-based mathematics" is jargon. | Now "related curve problems". |
| 2.3 | The smart-contract paragraph listing five proved properties is dense. | Turned into a short bullet list; the Halmos result is a separate paragraph. |
| 2.4 | Can I act on Monday? | Six questions, each answerable by an operator. Question 2 ties to an existing DORA duty. |

## 3. G-SIB CISO

| # | Objection | Resolution |
|---|---|---|
| 3.1 | The questions should connect to obligations institutions already have. | Question 2 cites DORA's technical standard: update cryptography on developments in cryptanalysis (CLAIMS D22). |
| 3.2 | Binance is now one paragraph of evidence. Is "the operations around them failed" fair? | It follows from Binance's own description: unauthorised use of the signing service, no evidence of key leakage (B2, B4). Kept. |

## 4. Smart-contract auditor

| # | Objection | Resolution |
|---|---|---|
| 4.1 | "Proved for every possible state" hides the abstraction: signature validity is assumed. | Added "taking the signature checks themselves as given". |
| 4.2 | Halmos's solver names are only reported. | Not named in the article (F8). |
| 4.3 | "SMT, a richer descendant of SAT solving" is a simplification. | Acceptable for the persona; SMT solvers are built around a SAT core. Kept as plain description. |

## 5. Sceptical journalist or economist

| # | Objection | Resolution |
|---|---|---|
| 5.1 | Strongest counter-argument: nobody serious thought ETH threatened ECDSA, so the article knocks down a straw man. | The article's added value is concrete: my own solver measurements, the one genuine nuance (local functions) and the dual-use twist in verification. The TL;DR states the conclusion up front rather than building suspense. |
| 5.2 | The dual-use twist is speculative, given that the result is asymptotic. | The text says so: "a direction to watch, not a change today". |
| 5.3 | "47 of 56" could read as an indictment. | Worded as "not found in public material". The fuller context is in the annex and v1. |

## 6. The senior expert who reviewed Chapter 1

| # | Objection | Resolution |
|---|---|---|
| 6.1 | Formula count. | Zero displayed equations; no inline symbols. |
| 6.2 | Uniform step size across the four layers. | Each layer follows the same four-step order (relies on → rests on ETH? → what I found → residual). See the step-size audit in `docs/author-brief.md`. |
| 6.3 | The jump from signatures to quantum. | One sentence, pointing to Chapter 3. |

## Number check

| Number | Source |
|---|---|
| 18 / 19 of 64 rounds; a dozen bits; up to a minute; two minutes | C13, `results/sat_summary.csv` (120 s limit) |
| 42 of 64 steps | F4 |
| about 72,000 variables | F13 (71,925) |
| 14 platforms; 47 of 56 answers | C15 |
| US$6.3 billion | B1 |
| 2020 (Jain–Lin–Sahai) | F3 |
| five properties (Certora) | C11 |
