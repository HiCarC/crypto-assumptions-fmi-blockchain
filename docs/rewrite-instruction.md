STOP the current direction. The article has drifted from the promise Chapter 1 made, so rewrite it. Keep all the project work; only the article's centre of gravity changes.

THE PROMISE (from the end of docs/chapter-1.md, verbatim):
"I will examine what happens when cryptographic assumptions underpin public consensus, digital signatures, zero-knowledge proofs and smart-contract execution, and whether the October results create a different security problem for blockchain-based financial infrastructure."

The current article/final.md answers a different question (who holds the powers around the cryptography) and makes the 3-SAT analysis a side section. Consensus and zero-knowledge proofs, both explicitly promised, are missing from it. Chapter 2 must be about how the October 3-SAT / #3-SAT results bear on blockchain security, layer by layer.

STEPS

1. Preserve the current version: `git mv article/final.md article/final-v1-powers.md` (also keep review-log.md as review-log-v1.md). Do not delete it; parts may feed Chapter 3 or 4.

2. Write a new `article/draft.md` with this structure:

   a. HOOK: our own SAT experiment (results/, CLAIMS C13). Three of today's best SAT solvers were pointed at SHA-256, the hash function behind Bitcoin. They found inputs for versions cut to 18 of its 64 rounds, none at 19, and on the full function they were slower than plain search. Concrete, ours, and on-topic. No Binance in the hook.

   b. BRIDGE TO CHAPTER 1 (2–3 sentences): what Chapter 1 established (an extraordinary result, no newly feasible attack, the "show me the attack" test) and the promise above, quoted or closely paraphrased.

   c. ONE PLAIN QUESTION, asked of each layer: "Would a much faster algorithm for 3-SAT and #3-SAT change anything here?" Then four short sections, one per layer, each with the same internal order: what the layer relies on → whether that rests on the hardness ETH describes → what our project found → the honest residual.
      - CONSENSUS. Proof-of-work rests on hash functions (SHA-256; tie in the SAT experiment and the reduced-round literature). Proof-of-stake and BFT consensus rest on signatures (e.g. BLS aggregation, Ed25519), i.e. on elliptic-curve and pairing problems. State plainly whether either rests on ETH-type hardness.
      - DIGITAL SIGNATURES. ECDSA/EdDSA rest on the elliptic-curve discrete-log problem, which is not an NP-hardness / SAT assumption; a faster SAT algorithm gives no known route to it. One sentence only on quantum (Shor) as the real long-term threat, explicitly kept for Chapter 3. Do NOT include the ML-DSA gas measurements; they move to Chapter 3.
      - ZERO-KNOWLEDGE PROOFS. Soundness rests on other assumptions (knowledge assumptions, random-oracle / Fiat–Shamir, discrete-log, pairings). Give the one genuine nuance: research constructions based on local pseudorandom generators (Goldreich-type, constant output locality), the class OpenAI's result touches, and some indistinguishability-obfuscation results that use them; state they are not deployed in production (CLAIMS). Mention that the real ZK failures have been implementation bugs (under-constrained circuits, weak Fiat–Shamir), in one sentence.
      - SMART-CONTRACT EXECUTION. The twist: the tools that prove contracts correct and find bugs (SMT/SAT-based, such as Certora and Halmos, both used in this project) are built on SAT solving. A real advance in #SAT/SAT would first make verification cheaper for defenders, and bug-finding cheaper for attackers: dual use. Use our project as the illustration (properties formally verified, in plain words). Keep the October result's asymptotic, not practical, nature clear.
      Also add, briefly where it fits, the fine-grained point: refuting ETH also refutes SETH, so anything whose security is proved from SETH/ETH-type hardness (fine-grained cryptography, some proof-of-useful-work proposals) loses its proof; none is in production use (CLAIMS).

   d. "A DIFFERENT SECURITY PROBLEM?" The answer: not from the mathematics, but blockchains change the CONSEQUENCE and the REMEDY when an assumption weakens: assumptions are public, the record is permanent, and replacing a primitive is a governance decision (fork / upgrade / migration of every account). Here, and only here, compress the "powers" analysis into 2–3 paragraphs: who can change the rules, who can freeze, who decides which keys count. Binance appears at most as ONE paragraph of evidence that losses come from operations around valid signatures, not from broken mathematics (Binance's own report only; no attribution). Include the "47 of 56 answers not found in public material" finding in one sentence, worded exactly that way.

   e. WHAT AUTHORITIES SHOULD ASK: 5–6 questions, now centred on cryptographic assumptions plus ledger governance, e.g. which primitives each layer of this ledger depends on and on which assumptions; who would decide, and how fast, if one weakened; whether formal verification is used for the contracts that hold settlement assets; who can change the rules and freeze assets. Address "authorities", never "supervisors".

   f. CLOSING: one sentence in the spirit of Chapter 1's test, adapted to ledgers, not repeating it word for word. Then a one-line teaser: Chapter 3, post-quantum migration of payment systems (where the gas measurements and Project Leap now go).

3. RULES (unchanged from the brief, re-applied):
   - 1,400–1,800 words. Zero displayed equations (at most one if a sentence cannot carry the point). One idea per paragraph; no large logical jumps (the Chapter 1 reviewer's correction).
   - Write in the first person singular ("I"), never "we" or "our": the author is an independent commentator. Say "the project" or "my tests" where needed.
   - Only V-labelled claims from CLAIMS.md as plain fact; inferences marked as the author's reading. Add any new claim to CLAIMS.md with label and source.
   - British spelling. No "immune", "unbreakable", "quantum-proof" (except in an official title). No invented percentages; do not use the twelve-case-list shares.
   - One figure at most, from results/: prefer the SAT scaling figure (fig_sat_scaling.png) with alt text and a caption that claims no more than the data show; crop any title that repeats the caption.
   - 3 headline options and 3 subtitle options that make the 3-SAT → blockchain link explicit (e.g. "Would a Faster 3-SAT Algorithm Break the Blockchain? Layer by Layer, No — With One Twist"). Avoid repeating a word between headline clauses.
   - Keep the primary sources list (add the reduced-round SHA-256 / SAT literature, the local-PRG paper(s) and the Certora/Halmos documentation if cited), the signature block, and SEO fields (SEO title ≤60 chars, meta ≤155, slug, tags) updated to the new angle.

4. QUALITY GATES before finishing:
   - Re-run the six adversarial reviews briefly against the new text (cryptographer weighted most), log them in article/review-log.md.
   - Redo the step-size audit table in docs/author-brief.md for the new article.
   - Check, as a list at the end of the author brief, that each of the four promised layers (consensus, signatures, ZK proofs, smart-contract execution) and the "different security problem" question has its own section in the article.
   - Proofread; word count; number check against CLAIMS.md.

5. Save as article/final.md, update docs/author-brief.md (thesis in 3 sentences for the new angle; Chapter 3 = post-quantum migration of payment systems, now also receiving the gas measurements), update docs/HANDOFF.md, commit, push to the PRIVATE repo, and STOP. Do not publish anything.
