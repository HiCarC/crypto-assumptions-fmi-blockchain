# Chapter 2 — viral edition (Substack)

Written to the reach advice of a viral-content colleague: open a question the reader needs answered, keep the verdict for the end, show the expertise in the reveal, and make it part of a series. Technical substance is unchanged from `article/final.md` (the analytical edition); every number traces to `CLAIMS.md`.

## Headline options

1. Did AI Just Break the Blockchain? I Tested It, Layer by Layer
2. I Pointed the Best Puzzle Solvers at the Ledger. Here's What Survived
3. AI Rewrote a 25-Year-Old Rule of Computing. I Tested What It Means for Blockchains

## Subtitle

Part 2 of my series on AI, cryptography and financial stability. Four layers tested in public code. Three held. The fourth surprised me.

---

**The short version:** I tested the hash functions every ledger runs on, the signatures that validators and transfers depend on, zero-knowledge proofs and smart contracts against October's AI breakthrough in computer science. Three layers held. The fourth is where it gets interesting, and it is not where you would expect.

---

In October, AI systems at OpenAI and Anthropic claimed something computer scientists had assumed for 25 years could not exist: a fundamentally faster way to solve 3-SAT, the logic puzzle that sits underneath much of computing.

That sounds abstract. It is not. Digital security is built on hardness. Banks, payment systems and every blockchain rely on problems that are assumed to be too hard to solve. So when a "too hard" problem gets easier, the obvious question is: what breaks?

In [Part 1](https://thekarlc.substack.com/p/ai-3sat-eth-refutation-banking-cryptography) I asked that question of banks. The answer was: nothing yet. Now I am asking it of blockchains, the technology central banks and major banks are exploring for settling money and securities.

I did not want to guess, so I built a test bench on three platforms, an Ethereum-style (EVM) ledger, Stellar and Canton: a reference settlement system, mathematical proofs of its safety, and SAT experiments against SHA-256, one of the most widely used hash functions on ledgers. **The code, the tests and the results are public on [GitHub](https://github.com/HiCarC/crypto-assumptions-fmi-blockchain)**, so anyone can check every number below. You can also [try the contracts in the web playground](https://ledger-lab-gamma.vercel.app/) I built.

A blockchain has four layers that rely on hard mathematics. I tested each one. Here is what happened.

## Layer 1: Hash functions, the fingerprint of every ledger

Whatever a ledger uses to agree on its history, proof of stake, proof of authority or the Byzantine-fault-tolerant networks banks run, it links every record with a hash function. A hash is a digital fingerprint: it scrambles data so thoroughly that no one can work backwards from the fingerprint to the data. If that failed, records could be swapped without anyone noticing.

Think of a SAT solver as a super-powered Sudoku solver. You give it a set of rules, and it searches for an answer that satisfies all of them. So I took SHA-256, one of the most widely used hash functions, and gave three of the world's best SAT solvers almost the whole input and hid just 12 bits. Their job: work out the missing bits.

They took up to a minute.

A plain search, trying all 4,096 possibilities one by one, takes milliseconds.

![Scatter chart on a logarithmic time scale. Time for three SAT solvers to recover hidden input bits of the full SHA-256 function when the rest of the input is given: under a second with 4 bits hidden, up to about 6 seconds with 8, between about 3 and 55 seconds with 12, one success and several failures at the 120-second limit with 16, and no success with 20.](../results/fig_sat_full.png)

*Figure: Time for three current SAT solvers (Kissat, CaDiCaL, CryptoMiniSat) to recover hidden input bits of the full SHA-256 function, the rest of the input being given. Three random instances per point; 120-second limit; x = not found. One encoding of my own, on one machine; it describes today's tools, not future algorithms.*

Why so slow? Because to a SAT solver, one SHA-256 calculation is not a puzzle with 256 pieces. It is a puzzle with about 72,000. Any speed-up from the October results applies to that huge number, not the small one. Even the best specialist attack ever published ([Khovratovich, Rechberger and Savelieva, 2012](https://eprint.iacr.org/2011/286)) covers only 45 of SHA-256's 64 rounds, at almost the cost of trying everything.

**Verdict: holds.**

## Layer 2: Signatures, how validators agree and transfers are approved

In proof of stake, proof of authority and Byzantine-fault-tolerant networks, consensus is a vote: validators sign each block, and a block is final once enough of them have signed. Every transfer is approved the same way, with a digital signature, usually built on elliptic curves.

Forging one means solving a different kind of problem, called the elliptic-curve discrete logarithm. It is not the kind of problem 3-SAT stands for, and its security estimates never relied on the conjecture the AI systems overturned.

**Verdict: holds.**

## Layer 3: Zero-knowledge proofs

Zero-knowledge proofs let you prove that something is true without revealing why. Ledgers use them for privacy, and to compress thousands of transactions into a single proof. They rest on other assumptions, none of them the hardness of 3-SAT.

One asterisk. [OpenAI's paper](https://github.com/openai/math/tree/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026) notes that its method also applies to a family of very simple experimental functions used in academic research. I found none in real systems. And the zero-knowledge failures that have actually happened were ordinary coding bugs, not broken mathematics ([Chaliasos et al., 2024](https://arxiv.org/abs/2402.15293)).

**Verdict: holds, with an asterisk for research.**

## Layer 4: Smart contracts, the twist

This is the one I did not expect.

The mathematics of running a smart contract is not at risk. But the tools used to *prove* that contracts are safe run on the same kind of solver as the puzzles in this story.

In my test system I used two of them, Certora and Halmos. Checking every possible state, they proved that:

- no money moves without a valid signature;
- every authorisation works only once;
- money cannot be created out of thin air;
- nothing moves while the system is paused;
- in a trade, both sides settle or neither does.

A genuinely faster solver would make proofs like these cheaper. Good news for defenders. But it would make it just as cheap to search *other people's* contracts for flaws. Whoever adopts it first gains the edge.

**Verdict: the mathematics holds, but the balance between attackers and defenders could shift.** For now, the October results are about very large problems in theory. They do not come with a faster solver for real contracts. This is the layer to watch.

## So, did AI break the blockchain?

No. Three layers held, one with an asterisk, and the fourth showed a twist rather than a break.

![Scorecard of four ledger layers tested against the October 3-SAT results. Hash functions: holds. Signatures: holds. Zero-knowledge proofs: holds, with an asterisk for research-only constructions. Smart contracts: twist, because the tools that prove contracts safe run on SAT-type solvers.](../results/fig_scorecard.png)

*Figure: The four layers at a glance. Tested on an Ethereum-style (EVM) ledger, Stellar and Canton.*

But my tests exposed a problem blockchains have that banks do not. If a mathematical assumption ever does weaken, the damage is public and permanent, and the fix is a governance decision. Changing a ledger's cryptography needs an upgrade agreed by whoever controls the rules. In my test system, users who did not migrate kept their money but could no longer move it. Only an administrator could rescue them.

Who holds those powers? For 14 institutional and central-bank platforms, I could not find public answers to 47 of 56 basic questions: who can change the rules, who can freeze assets, who decides which keys count, and whether there is a quantum plan.

![Heat map of 27 ledger platforms against four questions: who can freeze, who can upgrade, who sets signer policy, and whether there is a post-quantum roadmap. Most cells for bank-led and central-bank platforms are grey, meaning not found in public material; Canton and Stellar have the most cells stated in official sources.](../results/fig_powers_heatmap.png)

*Figure: Who holds the powers, by platform. Green: stated in an official source I read. Amber: reported in a secondary source. Grey: not found in public material, which is not evidence of weakness. Colour shows evidence, not quality.*

Recent losses show where the real risk sits. In October, an attack affected about US$6.3 billion of assets at Binance. According to Binance's own report, no private key leaked: the attacker misused an internal signing service. The mathematics was fine. The operations around it were not.

![Bar chart of twelve major thefts from 2021 to 2026 by reported loss, coloured by root cause. Binance 2026 is the largest at about US$6.3 billion, followed by Bybit 2025 at US$1.5 billion. Root causes are operational compromise of keys or signing, bridge or message-verification flaws, errors in cryptographic code or key generation, a smart-contract logic flaw and social engineering. Zero cases came from a broken cryptographic primitive.](../results/fig_incidents.png)

*Figure: Twelve major thefts, 2021–2026, by root cause as reported. A selection of large cases, not a census. Not one came from broken cryptographic mathematics.*

## Five questions every authority should ask

1. Which cryptography does each layer of this ledger rely on, and on what assumptions?
2. Who tracks new attacks on it, and who would decide on a replacement?
3. How fast could a replacement be deployed, and what happens to users who do not act?
4. Are the contracts holding settlement assets formally proven safe, and against what?
5. Who can change the rules, freeze an asset or reverse a transfer, and is that written down where outsiders can read it?

For a ledger, the test is simple: first ask which assumption each layer rests on, and who could replace it in time. Only then discuss the mathematics.

*If this was useful, subscribe: the series on AI, cryptography and financial stability continues.*

---

**Everything behind this article:** [code, tests and data on GitHub](https://github.com/HiCarC/crypto-assumptions-fmi-blockchain) · [technical annex, PDF](https://github.com/HiCarC/crypto-assumptions-fmi-blockchain/releases/download/chapter-2-v1.0/chapter-2-technical-annex.pdf) · [analytical edition of this article](https://github.com/HiCarC/crypto-assumptions-fmi-blockchain/blob/main/article/final.md) · [try the contracts in your browser](https://ledger-lab-gamma.vercel.app)

**Primary sources**

- OpenAI, *The Exponential Time Hypothesis is False*, preprint, 25 October 2026: https://github.com/openai/math/tree/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026
- Anthropic, *A 2^{o(n)} Time Algorithm for 3-SAT*, preprint, 27 October 2026: https://hexagonmath.org/2610.00577v1
- D. Khovratovich, C. Rechberger, A. Savelieva, *Bicliques for Preimages: Attacks on Skein-512 and the SHA-2 Family*, FSE 2012: https://eprint.iacr.org/2011/286
- S. Chaliasos et al., *SoK: What Don't We Know? Understanding Security Vulnerabilities in SNARKs*, USENIX Security 2024: https://arxiv.org/abs/2402.15293
- Certora Prover documentation: https://docs.certora.com/en/latest/docs/user-guide/
- Halmos, symbolic testing for EVM smart contracts: https://github.com/a16z/halmos
- Binance, *29 October 2026 Binance Security Incident: Initial Findings and Response Update*, 3 November 2026: https://www.binance.com/en/blog/community/3229153443759566763

---

*Carles Cerqueda*

*Independent commentary on financial stability, market infrastructures and emerging technologies. Views are personal and do not represent any current or former institution.*

---

## SEO

- **SEO title (≤60):** Did AI Just Break the Blockchain? I Tested 4 Layers
- **Meta description (≤155):** October's AI breakthrough on 3-SAT, tested against ledger hashes, validator signatures, zero-knowledge proofs and smart contracts. Three held. One surprised me.
- **Slug:** did-ai-break-the-blockchain-tested-layer-by-layer
