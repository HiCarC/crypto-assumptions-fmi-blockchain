# Article draft — Chapter 2

## Headline options

1. The Mathematics Held. Who Holds the Powers That Matter?
2. Valid Signatures, Wrong Instructions: Where Blockchain Cryptography Fails
3. The Ledger's Cryptography Is Sound. Can Anyone Change Its Locks?

## Subtitle options

1. The October 3-SAT results do not reach blockchain cryptography. The risks sit with those who instruct, change and freeze the ledger. Chapter 2 of a series; next, post-quantum migration of payment systems.
2. From Chapter 1's question to blockchain-based financial infrastructure: four powers, one price tag, and the questions authorities should ask. Next: quantum-proofing payment systems.
3. A sound primitive is not a secure system. What tokenised finance can learn from a US$6.3 billion theft without broken cryptography. Next chapter: post-quantum migration in payments.

---

*TL;DR: The AI-generated 3-SAT results of October do not weaken the cryptography that blockchains rely on. The losses that matter come from four powers around that cryptography: who can instruct a signing system, who can change a ledger's rules, who can freeze an asset, and who decides which keys count. Public documentation rarely says who holds these powers on institutional ledgers. And moving to post-quantum signatures on a ledger has a real cost that only its governance can lower.*

---

On 29 October, an attack affected about US$6.3 billion in digital assets held by Binance, more than four times the amount stolen from Bybit in February 2025.

Binance's own account is notable for what did not happen. The day after the attack, it said it had found no evidence that any wallet's private key had leaked.

What did happen, according to Binance's report of 3 November, is that the attacker gained unauthorised use of an internal signing service. That service then signed a type of authorisation that Ethereum had introduced in a protocol upgrade in May 2025, handing control of a hot wallet to code chosen by the attacker.

Every signature was valid. The mathematics held. The instructions were wrong.

## The question from Chapter 1

In [Chapter 1](https://thekarlc.substack.com/p/ai-3sat-eth-refutation-banking-cryptography) I asked whether the October results from OpenAI and Anthropic on 3-SAT put the cryptography of banks and financial market infrastructures at risk. I found no newly feasible attack, and I promised to ask the same question of blockchain networks.

This chapter answers that promise. The short answer is that the mathematics is not where the problem lies. The longer answer is about who holds the powers around it.

## Does the October result change blockchain cryptography?

Not on the evidence available. Both papers remain preprints, and both concern how quickly the hardest instances of a logic puzzle grow as they become arbitrarily large.

The signatures, hash functions and zero-knowledge proofs that blockchains use do not rest on that hardness. Their security is assessed against the best known attacks on each specific mathematical problem, and those attacks are unaffected.

To test the practical side, we pointed three of today's best SAT solvers at SHA-256, the hash function behind Bitcoin. They found inputs for versions cut down to 18 of its 64 rounds, but none at 19. On the full function with only a dozen hidden input bits, they took up to a minute to find what a simple search finds in milliseconds.

That is a statement about today's tools, not about every possible future algorithm. But it confirms that the risk has to be looked for elsewhere.

## Four powers decide what the cryptography is worth

Blockchains are often described as immutable. For tokenised money and securities, that is not a property of the ledger. It is a property of each asset, set by whoever holds four powers.

**Who can instruct the signer.** A key does what its signing system is told. At Binance, the system checked who was asking, not what it was being asked to sign.

**Who can change the rules.** A protocol or contract upgrade can change what a valid signature does. Ethereum's May 2025 upgrade added a new kind of authorisation, and Binance's signing policy, on its own account, was not ready for it.

**Who can freeze or reverse.** About US$2.85 billion of the Binance proceeds was frozen or intercepted, according to its report. That was possible only because some of the assets have issuers with the power to freeze them.

**Who decides which keys count.** When a key is lost, or a signature scheme has to be retired, someone must be able to replace keys. That power is the remedy, and it is also a single point of control.

Each of these powers decides whether a valid signature turns into a valid transfer. They are cryptographic powers, and they are also governance powers.

An exchange is not a financial market infrastructure. But tokenised deposits and DLT settlement systems are built from the same parts: signing services in front of hardware or multi-party key stores, policy engines, and ledgers that change through upgrades. Each of them has a signer policy, an upgrade path, a freeze power and a registrar.

## Where losses actually happen

The Binance case is not an outlier. TRM Labs counted 207 hacks in the first half of 2026, with about US$972 million stolen. Compromises of infrastructure, meaning keys, signing systems and the machines around them, were about 15% of incidents but about 76% of the losses.

In the major incidents we examined, back to 2021, none came from a broken cryptographic primitive. The few rooted in cryptography came from faulty code or badly generated keys, not from the mathematics, and they were small.

## The capability that did change

Chapter 1 proposed a test: show the newly feasible attack, the system it affects and the resources required. The October results did not pass it. AI-assisted attacks on smart contracts now do.

In a benchmark published by Anthropic, AI agents produced working exploits for 207 of 405 smart contracts that had been attacked in the past. Run against 2,849 recently deployed contracts, they found two previously unknown flaws, at a cost of about US$3,476 in model usage. Binance's report also mentions an internal AI tool used during the intrusion, without saying how.

The capability is aimed at contract logic and operations, which is where the losses are.

## What institutional ledgers disclose

We built a comparative inventory of the cryptography and the four powers across 27 public, institutional and central-bank platforms, using only public material.

For the 14 institutional and central-bank platforms, 47 of the 56 answers on who can freeze, who can upgrade, who sets signer policy, and whether there is a post-quantum plan were not found in public material.

That is not evidence of weakness. Operators may document these matters to their authorities. It means the answers have to be requested, because they cannot be read.

## The price of changing the locks

Large quantum computers would break the signature schemes that ledgers use today. NIST now deprecates them after 2030 and disallows them after 2035, and the EU roadmap expects high-risk systems to have migrated by the end of 2030.

On a ledger, migration has a measurable cost. In our reference contracts, verifying one post-quantum signature (ML-DSA, the new NIST standard) in contract code cost about a thousand times as much as verifying today's signature, and the signature itself is 37 times larger.

![Bar chart, logarithmic scale: gas needed to verify one signature on an EVM ledger. ECDSA secp256k1 about 8,000; P-256 with a native precompile about 12,700; hybrid of two classical schemes about 26,000; P-256 in contract code about 237,000; ML-DSA-44 and the hybrid with ML-DSA about 8.1 million.](../results/fig_gas.png)

*Figure: Gas to verify one signature on an EVM ledger, by scheme (log scale). Measured in the repository's reference contracts; the post-quantum verifier is experimental third-party code. Other ledgers and implementations will differ.*

The cost is not fixed. A native verifier built into the ledger made a classical scheme almost twenty times cheaper in the same tests. But only the ledger's governance can add one. The Bank for International Settlements and the Eurosystem central banks found a similar pattern in Project Leap: post-quantum signatures worked in a test of the Eurosystem's T2 payment system, but verification was at least ten times slower, and the planned hybrid test was not carried out.

Two further limits appeared in the tests. Changing the scheme inside the contracts did not reach the ledger's own transaction signature, which only the ledger can change. And holders who never migrate keep their balances but can no longer sign. Only the registrar can bring them back.

## What authorities should ask

1. Which kinds of message will each signing system sign, and who reviewed that list after the last upgrade of every ledger the institution relies on?
2. Who can change the code of the ledger and of the contracts that hold the assets, with what delay, and whose consent is required?
3. For each settlement asset, who can freeze, claw back or reverse a transfer, and how does that power sit with the legal point of finality?
4. If a signature scheme had to be retired, who could replace participants' keys, under what controls, and what happens to holders who do not act?
5. What does it cost today to verify a post-quantum signature on this ledger, and whose decision would make it affordable?
6. Which of these answers are written down, and who outside the operator can read them?

## What to do now

1. **Extend cryptographic inventories to ledger powers.** The EU roadmap asks for first steps, including cryptographic inventories, by the end of 2026. For any ledger relied upon, the inventory should record the four powers, not only the algorithms.
2. **Link ledger upgrades to signer policy.** DORA requires documented change management, and the PFMI expect controls to be tested after significant changes. A protocol upgrade of a ledger the institution relies on is such a change.
3. **Ask for disclosure of upgrade and freeze powers.** The PFMI require clear lines of responsibility and a clearly defined point of settlement finality. On a shared ledger, both depend on parties outside the institution.
4. **Plan migration at ledger level, and start with the governance decision.** NIST's 2030 deprecation and the EU's 2030 milestone leave about five years. The plan must cover verification cost, the native support only the ledger can provide, and holders who do not act.

The four PFMI principles closest to these questions do not mention cryptography. DORA's technical standard requires institutions to update their cryptography as cryptanalysis develops, without naming quantum computing. The frameworks reach these powers through general duties. What they do not yet do is ask about the ledger as well as the institution.

Chapter 1 asked for the newly feasible attack before discussing a change in risk. For blockchain-based finance the test runs the other way: show me who can sign, who can change the rules and who can freeze the asset, and then we can discuss the mathematics.

---

**Technical annex:** [link to annex PDF, pending author approval]
**Repository:** [link pending author approval; currently private]

**Primary sources**

- Binance, *29 October 2026 Binance Security Incident: Initial Findings and Response Update*, 3 November 2026: https://www.binance.com/en/blog/community/3229153443759566763
- OpenAI, *The Exponential Time Hypothesis is False*, preprint, 25 October 2026: https://github.com/openai/math/tree/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026
- Anthropic, *A 2^{o(n)} Time Algorithm for 3-SAT*, preprint, 27 October 2026: https://hexagonmath.org/2610.00577v1
- TRM Labs, *H1 2026 crypto hacks*, 1 July 2026: https://www.trmlabs.com/resources/blog/h1-2026-crypto-hacks-reach-record-high-as-losses-fall-below-usd-1-billion
- Anthropic Frontier Red Team, *AI agents and smart contracts* (SCONE-bench), 1 December 2025: https://red.anthropic.com/2025/smart-contracts/
- NIST IR 8547, *Transition to Post-Quantum Cryptography Standards* (final), October 2026: https://csrc.nist.gov/pubs/ir/8547/final
- NIS Cooperation Group, *A Coordinated Implementation Roadmap for the Transition to Post-Quantum Cryptography*, v1.1, June 2025: https://digital-strategy.ec.europa.eu/en/library/coordinated-implementation-roadmap-transition-post-quantum-cryptography
- Commission Delegated Regulation (EU) 2024/1774 (DORA RTS on ICT risk management): https://eur-lex.europa.eu/eli/reg_del/2024/1774/oj
- CPMI-IOSCO, *Principles for Financial Market Infrastructures*, 2012: https://www.bis.org/cpmi/publ/d101.htm
- BIS Innovation Hub, *Project Leap phase 2: quantum-proofing payment systems*, December 2025: https://www.bis.org/publ/othp107.htm
- EIP-7702, *Set Code for EOAs*: https://eips.ethereum.org/EIPS/eip-7702
- FBI PSA I-022625-PSA on the Bybit theft, 26 February 2025: https://www.ic3.gov/PSA/2025/PSA250226

---

*Carles Cerqueda*

*Independent commentary on financial stability, market infrastructures and emerging technologies. Views are personal and do not represent any current or former institution.*

---

## SEO

- **SEO title (≤60):** Blockchain Cryptography: Who Holds the Powers That Matter
- **Meta description (≤155):** The October 3-SAT results leave blockchain cryptography intact. The risks sit with signer policy, upgrades, freeze keys and post-quantum migration costs.
- **Slug:** blockchain-cryptography-powers-tokenised-finance
- **Tags:** blockchain, cryptography, financial market infrastructure, tokenisation, post-quantum, DORA, operational resilience, settlement finality
