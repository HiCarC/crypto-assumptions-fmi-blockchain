# Author brief — Chapter 2, version 2 (layer by layer)

15 November 2026. Rewritten per `docs/rewrite-instruction.md`. Article: `article/final.md` (1,650 words including TL;DR, caption and lists; 0 displayed equations; first person singular). Review: `article/review-log.md`. The previous version (the "powers" framing) is preserved as `article/final-v1-powers.md`, with `review-log-v1.md` and `draft-v1-powers.md`; its author brief is in git history (commit `f7dccbf`).

## 1. Thesis in three sentences

On current knowledge, a much faster algorithm for 3-SAT would not weaken the consensus, signatures or zero-knowledge proofs blockchains rely on: none of them rests on the hardness the October results address, and my own solver tests show today's SAT methods stalling well short of full SHA-256. The genuine exceptions are narrow. They are research constructions built on local functions, which OpenAI's paper itself touches but which are not in production use, and smart-contract verification, whose tools are built on SAT-family solvers, so any practical advance would help defenders and attackers alike. Blockchains do make a weakened assumption a different problem in its consequence and remedy: the record is permanent, and replacing a primitive is a governance decision that, for most institutional ledgers I examined, is not documented in public material.

**How the work changed the thesis.** Version 1 put the powers around the cryptography at the centre and treated 3-SAT as a side section. The rewrite returns to the promise and keeps the powers as the answer to "a different security problem?". Three findings from the new reading sharpened it:

- OpenAI's paper does make a cryptographic remark, about Goldreich's local one-way functions. It also says explicitly that polynomial-time one-wayness is not ruled out.
- A faster SAT algorithm is *in principle* a route to every NP problem, including discrete logarithms. The honest point is size, not impossibility.
- The verification tools used in this project (Certora, Halmos) sit on SMT solvers, which gave the "twist".

## 2. Step-size audit

One row per paragraph of `article/final.md` (headings and the image excluded; the bullet list and the question list count as one row each). Persona: Head of FMI Oversight at a euro-area NCB.

| # | Single claim | Prior knowledge assumed | Step | Action taken | Evidence |
|---|---|---|---|---|---|
| 1 | TL;DR: layers survive; verification is the twist; consequence and remedy differ | none | medium (summary) | Each point developed below | — |
| 2 | I pointed three SAT solvers at SHA-256 | knows a hash fingerprints data | small | "SAT solver" defined in one clause | C13 |
| 3 | 18 of 64 rounds solved, none at 19 | 2 | small | "Round" defined | C13 |
| 4 | Full function, 12 hidden bits: slower than plain search | 3 | small | — | C13 |
| 5 | Figure caption: what was measured, and its limits | 2–4 | small | "Encoding of my own" (review 1.5) | C13 |
| 6 | Chapter 1: extraordinary result, no feasible attack, the test | Chapter 1 | small | — | Chapter 1 |
| 7 | The promise, quoted closely | 6 | small | — | Chapter 1 |
| 8 | The single question for each layer | 7 | small | — | — |
| 9 | The same four-step order per layer | 8 | small | Signposts the structure | — |
| 10 | Consensus: PoW hashes; PoS/BFT signatures | knows consensus conceptually | small | Scheme names corrected (review 1.6) | F9, F10, F11, D13 |
| 11 | Neither rests on ETH-type hardness (author's reading) | 10 | medium | Marked "as I read" | A5 (I) |
| 12 | Best verified reduced-round attack: 42 of 64 steps, near brute-force cost | 11 | small | Only the verified result is used | F4 |
| 13 | The encoded size (about 72,000 variables) is what counts, as in Chapter 1 | Chapter 1's AES point | medium | Ties back to Chapter 1 | F13 |
| 14 | Residual: only a practical method would matter; none offered | 13 | small | — | A1, A3 |
| 15 | Signatures rest on the elliptic-curve discrete-log problem | knows a key signs | small | — | — |
| 16 | Not among the hardest problems; a SAT route exists but is far slower (author's reading) | 13, 15 | medium | Corrected after review 1.1 | F14 (I) |
| 17 | Quantum is the real long-term threat: Chapter 3 | knows quantum threatens some PKC | small | One sentence only, as instructed | — |
| 18 | What ZK proofs are and why ledgers use them | none | small | Defined plainly | — |
| 19 | Their soundness rests on other assumptions | 18 | medium | Listed in plain words | E1, E2 (context); annex §2 |
| 20 | Nuance: OpenAI inverts local functions, applies it to Goldreich's candidates, polynomial-time hardness not ruled out | 19 | medium | The paper's own claim and caveat (review 1.3) | F1, F2 |
| 21 | Such generators underpin one obfuscation construction; no analysis found; not in production | 20 | medium | "I found" wording | F3, A7 |
| 22 | Real ZK failures were implementation bugs | 19 | small | One sentence, as instructed | E1, E2 |
| 23 | Refuting ETH refutes SETH; fine-grained constructions lose their proofs; none in production | 8 | medium | Placed after ZK as "a related family" | F12, A7 |
| 24 | The twist: verification tools rest on SAT-family solvers | 2 | small | — | F7, F8 |
| 25 | Certora compiles rules to a formula proved by an SMT solver | 24 | small | Quoted from the documentation | F7 |
| 26–27 | Certora proved five properties, taking the signature checks as given | 25 | small | Abstraction stated (review 4.1); list format | C11 |
| 28 | Halmos proved DvP atomicity | 26 | small | — | C10 |
| 29 | A faster solver is dual-use | 26–28 | small | — | I |
| 30 | The October results are asymptotic: watch, no change today (author's reading) | 8 | small | — | A2, A3 (I) |
| 31 | A different problem? Not mathematically; consequence and remedy | all layers | small | — | — |
| 32 | Consequence: public assumptions, permanent record | 31 | small | — | I |
| 33 | Remedy: governance decision; stranded holders in my tests | 32 | medium | — | C5 |
| 34 | Three powers; 47 of 56 answers not found in public material | 33 | small | Wording as instructed | C15 |
| 35 | Binance: losses come from operations around valid signatures | 34 | small | One paragraph; Binance's report only; no attribution | B1, B2, B4 |
| 36 | Six questions for authorities | 10–35 | small | Centred on assumptions and governance; Q2 tied to DORA | D22 |
| 37 | Closing test adapted to ledgers | Chapter 1 | small | Not a verbatim repeat | — |
| 38 | Teaser: Chapter 3 | — | small | — | — |

No paragraph is rated "large". Every "medium" step follows a paragraph that supplies its premise.

## 3. Promise checklist

| Promised in Chapter 1 | Section in the article |
|---|---|
| Public consensus | "Consensus" ✔ |
| Digital signatures | "Digital signatures" ✔ |
| Zero-knowledge proofs | "Zero-knowledge proofs" ✔ |
| Smart-contract execution | "Smart-contract execution" ✔ |
| Whether the October results create a different security problem for blockchain-based financial infrastructure | "A different security problem?" ✔ |

## 4. Points to check personally before publishing

1. **SAT comparability (most important).** My plain encoding solved 18-round SHA-256 with the whole input free. A 2026 preprint (Zaikin) says SAT methods inverted 16 rounds in 2012 and reached 19 only with a specialised solver. My solutions are all verified against the hash, so the result is correct for my definition. The definitions (padding, targets, round counting) have not been reconciled, however. The article makes no comparison with the literature, but a reader may. If you want the hook to rest on fully reconciled numbers, an expert should compare the two set-ups first; the encoder is `sat/sha256_cnf.py`. Alternatively, lead the hook with the full-function result (slower than plain search), which carries no such ambiguity.
2. **OpenAI's paper is quoted on Goldreich's functions** from text extracted from the PDF. Please confirm the wording in Appendix C yourself.
3. **"Not believed to be among the hardest problems"** for the discrete-log problem is standard in the field. It is not sourced in the article.
4. **Binance** appears once, from its own report; no attribution.
5. **The ML-DSA gas measurements and Project Leap** are out of the article, as instructed. They move to Chapter 3.

## 5. Chapter 3

**Post-quantum migration of payment systems.** It now also receives:

- the gas measurements from this project: verifying ML-DSA-44 costs about 1,000 times as much as ECDSA, and a native verifier was about 20 times cheaper than contract code for P-256;
- the stranded-holder and registrar results;
- Project Leap's T2 findings;
- the migration timeline against NIST IR 8547 and the EU roadmap.

The v1 article's "powers" material can feed its governance section.

## 6. External actions awaiting your approval

| Action | Status |
|---|---|
| Publish the article | Awaiting approval |
| Publish the annex, and choose where to host it | Awaiting approval. Note: the annex still reflects the v1 emphasis in its summary; its sections 2, 6, 9 and 11 support v2 |
| Make the repository public or share it | Awaiting approval; it is private |
| Certora CI | Done (secret set; passing) |
