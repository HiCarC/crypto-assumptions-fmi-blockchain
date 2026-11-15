# Author brief — Chapter 2, version 2 (layer by layer)

15 November 2026. Rewritten per `docs/rewrite-instruction.md`, then corrected per the author's final fixes. Article: `article/final.md` (1,676 words including TL;DR, caption and lists; 0 displayed equations; first person singular). Review: `article/review-log.md`. The previous version (the "powers" framing) is preserved as `article/final-v1-powers.md`, with `review-log-v1.md` and `draft-v1-powers.md`; its author brief is in git history (commit `f7dccbf`).

## 1. Thesis in three sentences

On current knowledge, a much faster algorithm for 3-SAT would not weaken the consensus, signatures or zero-knowledge proofs blockchains rely on: none of them rests on the hardness the October results address, and my own solver tests found today's SAT solvers slower than plain search on the full SHA-256. The genuine exceptions are narrow. They are research constructions built on local functions, which OpenAI's paper itself touches but which are not in production use, and smart-contract verification, whose tools are built on SAT-family solvers, so any practical advance would help defenders and attackers alike. Blockchains do make a weakened assumption a different problem in its consequence and remedy: the record is permanent, and replacing a primitive is a governance decision that, for most institutional ledgers I examined, is not documented in public material.

**How the work changed the thesis.** Version 1 put the powers around the cryptography at the centre and treated 3-SAT as a side section. The rewrite returns to the promise and keeps the powers as the answer to "a different security problem?". Three findings from the new reading sharpened it:

- OpenAI's paper does make a cryptographic remark, about Goldreich's local one-way functions. It also says explicitly that polynomial-time one-wayness is not ruled out.
- A faster SAT algorithm is *in principle* a route to every NP problem, including discrete logarithms. The honest point is size, not impossibility.
- The verification tools used in this project (Certora, Halmos) sit on SMT solvers, which gave the "twist".

## 2. Step-size audit (after the final fixes)

Paragraph numbers refer to the current `article/final.md`. Rows marked **changed** were re-audited after the final fixes. Rows 15–37 are unchanged in content; their numbering moved down by one because a paragraph was removed and another moved.

| # | Single claim | Prior knowledge assumed | Step | Action taken | Evidence |
|---|---|---|---|---|---|
| 1 | TL;DR | none | medium (summary) | — | — |
| 2 | **changed.** I gave three SAT solvers almost all of a SHA-256 input and hid a dozen bits | knows a hash fingerprints data | small | "SAT solver" defined in one clause | C13 |
| 3 | **changed.** Up to a minute against milliseconds for plain search; 1 in 9 at 16 bits | 2 | small | 18-round claim removed (author's fix 1) | C13 |
| 4 | **changed.** One SHA-256 computation is about 72,000 SAT variables, not 256; the AES lesson of Chapter 1 | Chapter 1 | medium | Size point moved here from Consensus | F13 |
| 5 | **changed.** Single-panel figure caption | 2–4 | small | Full function only; no title | C13 |
| 6–9 | Chapter 1, the promise, the question, the method | Chapter 1 | small | — | — |
| 10 | Consensus: PoW hashes; PoS/BFT signatures | none | small | — | F9–F11, D13 |
| 11 | Not ETH-type hardness (author's reading) | 10 | medium | "As I read" | A5 (I) |
| 12 | **changed.** My tests (back-reference); best attack read in full: 45 of 64 steps at almost brute-force cost; a 2026 claim of 47 not read | 2–4, 11 | small | Corrected per author's fix 2 | F4, F5a |
| 13 | Residual: only a practical method would matter; none offered | 12 | small | — | A1, A3 |
| 14 | **changed (moved).** Refuting ETH refutes SETH; fine-grained "useful" proof-of-work proofs lost; none in production | 13 | medium | Moved from the ZK section (author's fix 3) | F12, A7 |
| 15–16 | Signatures: discrete log; SAT route far larger (author's reading) | 2–4 | medium | References the hook's size point | F14 (I) |
| 17 | Quantum: Chapter 3 | — | small | — | — |
| 18–21 | ZK: definition, assumptions, Goldreich nuance (paper's own caveat), Jain–Lin–Sahai | 18 | medium | — | F1–F3, A7 |
| 22 | ZK failures were implementation bugs | 19 | small | — | E1, E2 |
| 23–29 | Smart-contract execution: the verification twist; Certora and Halmos results (signatures taken as given); dual use; asymptotic caveat | 2 | small | — | F7, F8, C10, C11 |
| 30–34 | A different security problem: consequence, remedy, three powers, 47 of 56 answers not found in public material, Binance as evidence | all layers | small–medium | — | C5, C15, B1, B2, B4 |
| 35–37 | Questions, closing test, Chapter 3 teaser | — | small | — | D22 |

No paragraph is rated "large".

## 3. Promise checklist

| Promised in Chapter 1 | Section in the article |
|---|---|
| Public consensus | "Consensus" ✔ |
| Digital signatures | "Digital signatures" ✔ |
| Zero-knowledge proofs | "Zero-knowledge proofs" ✔ |
| Smart-contract execution | "Smart-contract execution" ✔ |
| Whether the October results create a different security problem for blockchain-based financial infrastructure | "A different security problem?" ✔ |

## 4. Points to check personally before publishing

1. **SAT comparability: resolved by removal.**
   - The 18-round result is no longer in the article.
   - Annex §9 now gives my exact definitions (compression function, feed-forward included, no padding, random-image targets, round counting) and a table comparing them with Zaikin (2026), Homsirikamol et al. (2012) and the meet-in-the-middle literature.
   - It explains why the numbers are not comparable. Zaikin's headline targets are the constant all-ones output, and the 19-round result needed a weakened instance and a probabilistic lift. My random-image targets are likely easier, which is my reading, not a measurement.
   **Correction to the brief's list of attacks:**
   - 41 steps is Sasaki–Wang–Aoki (ePrint 2009/479).
   - ePrint 2009/477 is Guo–Matusiewicz (42 steps).
   - The merged Asiacrypt 2009 paper (Aoki et al.) reaches 43.
   - Guo–Ling–Rechberger–Wang (Asiacrypt 2010) cut the 42-step cost to 2^248.4 without adding steps.
   - Khovratovich–Rechberger–Savelieva (FSE 2012), read in full, is a 45-step preimage attack at about 2^255.5. The article cites it.
   - A 2026 paper (ePrint 2026/353) claims 46 and 47 steps; I could not read it, and the article says so.
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
| Publish the annex, and choose where to host it | Awaiting approval. The annex introduction and executive summary are now layer by layer; §3 is relabelled as the answer to "a different security problem?"; §9 has the definitions and literature comparison (21 pages) |
| Make the repository public or share it | Awaiting approval; it is private |
| Certora CI | Done (secret set; passing) |
