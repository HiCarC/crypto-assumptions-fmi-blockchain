# Chapter 2 — final text for Substack

## Headline options

1. The Mathematics Held. Who Holds the Powers That Matter?
2. Valid Signatures, Wrong Instructions: Where Blockchain Cryptography Fails
3. The Ledger's Cryptography Is Sound. Who Can Change Its Locks?

## Subtitle options

1. The October 3-SAT results leave blockchain cryptography intact. The risks sit with those who instruct, change and freeze the ledger. Next: post-quantum migration of payment systems.
2. From Chapter 1's question to tokenised finance: four powers, one price tag, and the questions authorities should ask. Next chapter: post-quantum migration in payments.
3. A sound primitive is not a secure system. Lessons from a US$6.3 billion attack that broke no cryptography. Next chapter: post-quantum migration in payments.

---

*TL;DR: The AI-generated 3-SAT results of October do not weaken the cryptography that blockchains rely on. The losses that matter come from four powers around that cryptography: who can instruct a signing system, who can change a ledger's rules, who can freeze an asset, and who decides which keys count. Public documentation rarely says who holds these powers on institutional ledgers. And moving a ledger to post-quantum signatures has a real cost that only its governance can lower.*

---

On 29 October, an attack affected about US$6.3 billion in digital assets held by Binance. That is more than four times the US$1.5 billion taken from Bybit in February 2025.

Binance's own account is notable for what did not happen. The day after the attack, it said it had found no evidence that any wallet's private key had leaked.

What did happen, according to Binance's report of 3 November, is that the attacker gained unauthorised use of an internal signing service. The attacker used it to obtain a type of authorisation that Ethereum had introduced in a protocol upgrade in May 2025, giving code of the attacker's choosing the right to act on a hot wallet, an online account used for day-to-day withdrawals.

The signatures were valid. The mathematics held. The instructions were wrong.

## The question from Chapter 1

In [Chapter 1](https://thekarlc.substack.com/p/ai-3sat-eth-refutation-banking-cryptography) I asked whether the October results from OpenAI and Anthropic on 3-SAT put the cryptography of banks and financial market infrastructures at risk. I found no newly feasible attack, and I promised to ask the same question of blockchain networks.

The short answer is that the mathematics is not where the problem lies. The longer answer is about who holds the powers around it.

## Does the October result change blockchain cryptography?

Not on the evidence available. Both papers remain preprints, and both concern how quickly the hardest instances of a logic puzzle grow as they become arbitrarily large.

As I read the published security analyses, the signatures, hash functions and zero-knowledge proofs that blockchains use do not rest on that hardness. Each is assessed against the best known attacks on its own mathematical problem, and those attacks are unaffected.

To test the practical side, we pointed three of today's best SAT solvers at SHA-256, the hash function behind Bitcoin. They found inputs for versions cut down to 18 of its 64 rounds, but none at 19. On the full function, with only a dozen input bits hidden, they took up to a minute to find what a simple search finds in milliseconds.

That describes today's tools and one way of writing the problem, not every possible future algorithm. But it confirms that the risk has to be looked for elsewhere.

## Four powers decide what the cryptography is worth

Blockchains are often described as immutable. For tokenised money and securities, that is not a property of the ledger. It is a property of each asset, set by whoever holds four powers.

**Who can instruct the signer.** A key does what its signing system is told to do. In our reconstruction of the pattern, a signing service that checks who is asking, but not what it is being asked to sign, hands over an account without the key ever leaving the service.

**Who can change the rules.** An upgrade to a ledger or to a contract can change what a valid signature does. Ethereum's May 2025 upgrade added a new kind of authorisation, and that is the kind the attacker used.

**Who can freeze or reverse.** According to Binance's report, about US$2.85 billion of the affected assets was frozen or intercepted. Freezes of this kind are possible only where some party, usually an asset's issuer, holds the power to make them.

**Who decides which keys count.** When a key is lost, or a signature scheme must be retired, someone has to be able to replace keys. That power is the remedy, and it is also a single point of control.

Each of these powers decides whether a valid signature turns into a valid transfer. They are cryptographic powers and governance powers at the same time.

An exchange is not a financial market infrastructure. But tokenised deposits and settlement systems on distributed ledgers are built from the same parts: signing services in front of hardware key stores, policy engines, and ledgers that change through upgrades. Each has a signer policy, an upgrade path, a freeze power and a registrar.

A well-run infrastructure will have stronger controls than an exchange. The point is not that the same failure will occur. It is that the same four questions apply, and on a shared ledger some of the answers sit outside the institution.

## Where losses actually happen

The Binance case is not an outlier. TRM Labs counted 207 hacks in the first half of 2026, with about US$972 million stolen. What it classes as infrastructure compromises were about 15% of incidents but about 76% of the losses.

In the major incidents we examined since 2021, we found none that came from a broken cryptographic primitive. The few rooted in cryptography came from faulty code or badly generated keys, not from the mathematics, and they were far smaller.

## The capability that did change

Chapter 1 proposed a test: show the newly feasible attack, the system it affects and the resources required. The October results did not pass it. AI-assisted attacks on smart contracts come much closer, at least in benchmarks.

In a benchmark published by Anthropic, AI agents produced working exploits, in simulation, for 207 of 405 smart contracts that had been attacked in the past. Run against 2,849 recently deployed contracts, they found two previously unknown flaws, at a cost of about US$3,476 in model usage.

Binance's report also says an internal AI tool was used during the intrusion, without explaining how. The new capability is aimed at contract logic and operations, which is where the losses are.

## What institutional ledgers disclose

We built a comparative inventory of the cryptography and the four powers across 27 public, institutional and central-bank platforms, using only public material.

For the 14 institutional and central-bank platforms, 47 of the 56 answers on who can freeze, who can upgrade, who sets signer policy, and whether there is a post-quantum plan were not found in public material.

That is not evidence of weakness. Operators may document these matters to their authorities. It means the answers have to be requested, because they cannot be read.

## The price of changing the locks

A sufficiently large, error-corrected quantum computer would break the elliptic-curve signatures that ledgers use today. NIST now deprecates such schemes after 2030 and disallows them after 2035. The EU's coordinated roadmap sets the end of 2030 for high-risk use cases.

On a ledger, migration has a measurable cost. Ledgers built on Ethereum's design charge for computation in units called gas. In our reference contracts, checking one signature under ML-DSA, one of NIST's new post-quantum standards, cost about a thousand times as much gas as checking today's signature. The signature itself is 37 times larger.

![Bar chart on a logarithmic scale showing the gas needed to verify one signature on an Ethereum-style ledger. Today's ECDSA signature: about 8,000. P-256 using a verifier built into the ledger: about 12,700. A hybrid of two classical schemes: about 26,000. P-256 in contract code: about 237,000. ML-DSA-44, alone or in a hybrid: about 8.1 million.](../results/fig_gas.png)

*Figure: Gas needed to verify one signature on an Ethereum-style ledger, by scheme (logarithmic scale). Measured in the repository's research contracts. The post-quantum verifier is experimental third-party code; other ledgers and implementations will differ.*

The cost is not fixed. The verifier's authors report an experimental version about seven times cheaper. And in the same tests, a verifier built into the ledger made a classical scheme almost twenty times cheaper than contract code. But only a ledger's governance can build one in.

Central banks have met the same pattern. In Project Leap, the BIS Innovation Hub and three Eurosystem central banks put post-quantum signatures into a test of the Eurosystem's T2 payment system. The signatures worked, but verification was at least ten times slower, and the planned test of hybrid signatures was not carried out.

The tests showed a further limit. Changing the scheme inside the contracts did not reach the ledger's own transaction signature, which only the ledger itself can change.

They also showed what happens to holders who never migrate. They keep their balances but can no longer sign. Only the registrar can bring them back.

## What authorities should ask

1. Which kinds of message will each signing system sign, and who reviewed that list after the last upgrade of every ledger the institution relies on?
2. Who can change the code of the ledger and of the contracts that hold the assets, with what delay, and whose consent is required?
3. For each settlement asset, who can freeze, claw back or reverse a transfer, and how does that power sit with the legal point of finality?
4. If a signature scheme had to be retired, who could replace participants' keys, under what controls, and what happens to holders who do not act?
5. What does it cost today to verify a post-quantum signature on this ledger, and whose decision would make it affordable?
6. Which of these answers are written down, and who outside the operator can read them?

## What to do now

1. **Extend cryptographic inventories to ledger powers.** The EU roadmap asks Member States to take first steps, including inventories of cryptographic assets, by the end of 2026. For any ledger an institution relies on, the inventory should record the four powers, not only the algorithms.
2. **Link ledger upgrades to signer policy.** DORA requires documented change management, and the PFMI expect controls to be tested after significant changes. A protocol upgrade of a ledger the institution relies on is such a change. Signing systems should accept only the request types they understand, within limits.
3. **Ask for disclosure of upgrade and freeze powers.** The PFMI require clear lines of responsibility and a clearly defined point of settlement finality. On a shared ledger, both depend on parties outside the institution.
4. **Plan migration at ledger level, starting with the governance decision.** NIST's 2030 deprecation and the EU's 2030 milestone leave about four years. The plan must cover verification cost, the native support that only the ledger can provide, and holders who do not act.

The four PFMI principles closest to these questions do not mention cryptography. DORA's technical standard requires institutions to update their cryptography as cryptanalysis develops, without naming quantum computing.

So the frameworks reach these powers through general duties. What they do not yet do is ask the questions about the ledger as well as about the institution.

Chapter 1 asked for the newly feasible attack before discussing a change in risk. For blockchain-based finance the test runs the other way: show me who can sign, who can change the rules and who can freeze the asset, and then we can discuss the mathematics.

---

**Technical annex:** [link to annex PDF, pending author approval]
**Repository:** [link pending author approval; currently private]

**Primary sources**

- Binance, *29 October 2026 Binance Security Incident: Initial Findings and Response Update*, 3 November 2026: https://www.binance.com/en/blog/community/3229153443759566763
- OpenAI, *The Exponential Time Hypothesis is False*, preprint, 25 October 2026: https://github.com/openai/math/tree/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026
- Anthropic, *A 2^{o(n)} Time Algorithm for 3-SAT*, preprint, 27 October 2026: https://hexagonmath.org/2610.00577v1
- TRM Labs, H1 2026 crypto hacks report, 1 July 2026: https://www.trmlabs.com/resources/blog/h1-2026-crypto-hacks-reach-record-high-as-losses-fall-below-usd-1-billion
- Anthropic Frontier Red Team, smart-contract exploitation benchmark (SCONE-bench), 1 December 2025: https://red.anthropic.com/2025/smart-contracts/
- NIST IR 8547, *Transition to Post-Quantum Cryptography Standards* (final), October 2026: https://csrc.nist.gov/pubs/ir/8547/final
- NIS Cooperation Group, *A Coordinated Implementation Roadmap for the Transition to Post-Quantum Cryptography*, v1.1, June 2025: https://digital-strategy.ec.europa.eu/en/library/coordinated-implementation-roadmap-transition-post-quantum-cryptography
- Commission Delegated Regulation (EU) 2024/1774, DORA technical standard on ICT risk management: https://eur-lex.europa.eu/eli/reg_del/2024/1774/oj
- CPMI-IOSCO, *Principles for Financial Market Infrastructures*, 2012: https://www.bis.org/cpmi/publ/d101.htm
- BIS Innovation Hub, *Project Leap phase 2: quantum-proofing payment systems*, December 2025: https://www.bis.org/publ/othp107.htm
- EIP-7702, *Set Code for EOAs*: https://eips.ethereum.org/EIPS/eip-7702
- FBI, PSA I-022625-PSA on the Bybit theft, 26 February 2025: https://www.ic3.gov/PSA/2025/PSA250226

---

*Carles Cerqueda*

*Independent commentary on financial stability, market infrastructures and emerging technologies. Views are personal and do not represent any current or former institution.*

---

## SEO

- **SEO title (≤60):** Blockchain Cryptography: Who Holds the Powers That Matter
- **Meta description (≤155):** The October 3-SAT results leave blockchain cryptography intact. The risks sit with signer policy, upgrades, freeze keys and post-quantum migration costs.
- **Slug:** blockchain-cryptography-powers-tokenised-finance
- **Tags:** blockchain, cryptography, financial market infrastructure, tokenisation, post-quantum, DORA, operational resilience, settlement finality
