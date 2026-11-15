# Chapter 2 — final text for Substack

## Headline options

1. Would a Faster 3-SAT Algorithm Break the Blockchain? Layer by Layer, No — With One Twist
2. From 3-SAT to the Ledger: Consensus, Signatures and Proofs Stand; Verification Shifts
3. The October 3-SAT Results Meet Blockchain Finance: Sound Mathematics, a Dual-Use Twist

## Subtitle options

1. Chapter 1 promised to test consensus, signatures, zero-knowledge proofs and smart contracts against the October results. The mathematics holds; what changes is the remedy. Next: post-quantum migration of payment systems.
2. I pointed today's best SAT solvers at the hash behind Bitcoin, then asked the same question of every layer of a ledger. Next chapter: post-quantum migration in payments.
3. Why the AI-generated 3-SAT results leave blockchain cryptography standing, why contract-verification tools are the exception, and what authorities should ask. Next: post-quantum payments.

---

*TL;DR: On current knowledge, a much faster algorithm for 3-SAT would not weaken the consensus, signatures or zero-knowledge proofs that blockchains rely on, because none of them rests on the hardness the October results address. The one place where SAT solving matters directly is smart-contract verification, where any practical advance would help defenders and attackers alike. What blockchains do change is the consequence and the remedy when an assumption weakens: the record is permanent, and replacing a primitive is a governance decision. That is where authorities' questions should go.*

---

I wanted to see what today's tools can do before asking what a better algorithm might do. So I pointed three of the best SAT solvers available, programs that search for values satisfying a set of logical constraints, at SHA-256, the hash function behind Bitcoin. I asked them to find inputs that produce a given output.

SHA-256 scrambles its input in 64 successive rounds. On versions cut down to 18 rounds, the solvers succeeded. At 19 rounds, none succeeded within two minutes.

On the full function, I hid only a dozen bits of the input and gave the solvers the rest. They took up to a minute to find what a plain search through every possibility finds in milliseconds.

![Two scatter charts on a logarithmic time scale. Left: time for three SAT solvers to find an input for reduced versions of SHA-256 with the whole input unknown; under a tenth of a second up to 16 rounds, under one second at 17, between about 40 and 120 seconds or no answer at 18, and no answer at 19. Right: the full 64-round function with 4 to 20 input bits hidden; times rise from under a second at 4 bits to tens of seconds at 12 bits, one answer at 16 bits and none at 20.](../results/fig_sat_article.png)

*Figure: Time for three current SAT solvers (Kissat, CaDiCaL, CryptoMiniSat) to find an input for SHA-256; three random instances per point, 120-second limit, x = no answer. Left: rounds increasing, whole input unknown. Right: full function, a few input bits hidden. One straightforward encoding of my own, on one machine. It describes today's tools, not future algorithms.*

## The promise from Chapter 1

In [Chapter 1](https://thekarlc.substack.com/p/ai-3sat-eth-refutation-banking-cryptography) I looked at the AI-generated results from OpenAI and Anthropic that, if correct, overturn the Exponential Time Hypothesis for 3-SAT. I found an extraordinary result but no newly feasible attack, and I proposed a test: show me the attack, the system and the resources.

I also promised to examine what happens when cryptographic assumptions underpin public consensus, digital signatures, zero-knowledge proofs and smart-contract execution, and whether the October results create a different security problem for blockchain-based financial infrastructure. This chapter keeps that promise, one layer at a time.

## One question, four layers

The question is the same for each layer: would a much faster algorithm for 3-SAT and #3-SAT change anything here?

For each layer I ask what it relies on, whether that rests on the hardness the hypothesis describes, what my tests found, and what remains uncertain.

## Consensus

Consensus is how a ledger's participants agree on one history. Bitcoin uses proof of work: miners hash candidate blocks with SHA-256, applied twice, until one meets a target. Ethereum's proof of stake and the permissioned ledgers used in finance rely instead on validators' signatures: BLS signatures on the BLS12-381 curve in Ethereum's case, Ed25519 in several permissioned ledgers.

Neither rests on the hardness the October results address. As I read the published analyses, a hash function's security is a judgement about the best known attacks on that specific function, and signatures rest on problems in elliptic-curve mathematics.

My tests show where SAT methods stand against the hash. The best published attack on reduced SHA-256 that I could verify reaches 42 of its 64 steps, and still costs almost as much as trying every input.

Size matters here too, as it did for AES in Chapter 1. Written as a SAT problem, a single full SHA-256 computation took about 72,000 variables in my encoding, not 256. Any speed-up applies to that larger number.

The residual is narrow. A practical method for finding hash inputs faster than plain search would matter for proof of work. Neither paper offers one.

## Digital signatures

Every transfer on a ledger is authorised by a digital signature, almost always based on elliptic curves. Their security rests on the difficulty of the elliptic-curve discrete-logarithm problem.

That problem is not believed to be among the hardest problems that 3-SAT stands for, and its security estimates do not come from the hypothesis. In principle it can be rewritten as a SAT formula, but the formula would be far larger than my SHA-256 one. As far as I can see, the claimed speed-up leaves that route far slower than the attacks already known.

The real long-term threat to these signatures is a large quantum computer, which is a different question with a different timetable. It is the subject of Chapter 3.

## Zero-knowledge proofs

Zero-knowledge proofs let one party convince another that a statement is true without revealing why. Ledgers use them for privacy, and to compress the checking of many transactions into one proof.

Their soundness rests on other assumptions: discrete-logarithm and related curve problems, collision-resistant hashing, assumptions about what a prover must know, and treating a hash function as a source of randomness. None of these is the hardness the October results address.

There is one genuine nuance. OpenAI's paper also gives a faster way to invert functions in which each output bit depends on only a few input bits. It notes that this applies to such versions of Oded Goldreich's candidate one-way functions, and adds that it does not rule out their being hard for efficient attackers.

Generators of that local kind are one of the assumptions behind a 2020 research construction of program obfuscation, by Jain, Lin and Sahai. Whether the October result matters there depends on how much hardness the construction assumes, and I found no published analysis. I found none of these constructions in production use.

The zero-knowledge failures that have actually occurred were implementation bugs: circuits that failed to constrain what they should, and flawed implementations of the step that turns an interactive proof into a single message.

A related family is in a similar position. Because the strong form of the hypothesis implies the ordinary one, refuting the ordinary form refutes both. Constructions whose security is proved from either, including some proposals for "useful" proof of work, lose their proofs. I found none in production use.

## Smart-contract execution

Here is the twist. The mathematics of contract execution is not at stake, but the tools that check contracts are built on solvers of the same family.

Certora's prover, for example, compiles a contract and the rules it must obey into a logical formula, "which is then proved or disproved by an SMT solver", a richer descendant of SAT solving. Bug-finding tools work in a similar way, looking for an input that breaks a rule.

In this project I used Certora and a second tool, Halmos, on a reference settlement system. Taking the signature checks themselves as given, Certora proved, for every possible state of the token, five things:

- no transfer happens without a valid signature;
- each authorisation works only once;
- supply changes only through issuance and redemption;
- nothing moves while the system is paused;
- privileged functions refuse unauthorised callers.

Halmos proved that a delivery-versus-payment settlement moves both legs or neither, whatever the amounts.

A genuinely faster solver would make this kind of assurance cheaper. It would also make it cheaper to search other people's contracts for flaws. That is a dual-use shift, and it would favour whoever adopts it first.

The October results are about how running time grows as problems become arbitrarily large. As I read them, they do not come with a faster solver for problems of the size these tools handle. The twist is a direction to watch, not a change today.

## A different security problem?

Not from the mathematics. But blockchains do change two things when a cryptographic assumption weakens: the consequence and the remedy.

The consequence is larger because the assumptions are public and the record is permanent. Every signature, and every public key revealed by spending, stays on the ledger for anyone to attack later.

The remedy is harder because replacing a primitive is a governance decision. It needs a protocol upgrade, or a migration of every account, decided by whoever can change the ledger's rules. In my tests, holders who never migrated kept their balances but could no longer sign, and only a privileged registrar could bring them back.

So three powers matter alongside the mathematics: who can change the rules, who can freeze an asset, and who decides which keys count. For 14 institutional and central-bank platforms I examined, I recorded 47 of 56 answers on those powers and on post-quantum plans as not found in public material.

Losses so far confirm where the risk sits. According to Binance's own report, the attack that affected about US$6.3 billion of its assets in October went through unauthorised use of an internal signing service, and Binance said it found no evidence that any wallet's private key had leaked. The signatures were valid; the operations around them failed.

## What authorities should ask

1. Which cryptographic primitives does each layer of this ledger depend on (consensus, account signatures, any proof system, contract code), and on which assumptions?
2. Who tracks developments in cryptanalysis for each of them, as DORA's technical standard already requires of financial entities, and who would decide on a replacement if one weakened?
3. How quickly could a replacement be deployed, and what would happen to holders who do not act?
4. Are the contracts that hold settlement assets formally verified, against which properties, and with which tools?
5. Who can change the ledger's rules and the contracts' code, with what delay, and who can freeze or reverse a transfer of each settlement asset?
6. Which of these answers are written down, and who outside the operator can read them?

Chapter 1 asked for the newly feasible attack before discussing a change in risk. For a ledger, first ask which assumption each layer rests on and who could replace it in time; only then discuss the mathematics.

*Next, Chapter 3: the threat that does reach these signatures. Post-quantum migration of payment systems, what it costs on a ledger, and what central banks' own tests found.*

---

**Technical annex:** [link to annex PDF, pending author approval]
**Repository:** [link pending author approval; currently private]

**Primary sources**

- OpenAI, *The Exponential Time Hypothesis is False*, preprint, 25 October 2026 (Appendix C on constant-locality maps): https://github.com/openai/math/tree/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026
- Anthropic, *A 2^{o(n)} Time Algorithm for 3-SAT*, preprint, 27 October 2026: https://hexagonmath.org/2610.00577v1
- J. Guo and K. Matusiewicz, *Preimages for Step-Reduced SHA-2*, IACR ePrint 2009/477: https://eprint.iacr.org/2009/477
- O. Zaikin, *Preimage attacks on round-reduced MD5, SHA-1, and SHA-256 using parameterized SAT solver*, preprint, 2026: https://olegzaikin.github.io/publications/2026-z-constraints-preprint.pdf
- O. Goldreich, *Candidate One-Way Functions Based on Expander Graphs*, ECCC TR00-090, 2000: https://eccc.weizmann.ac.il/report/2000/090/
- A. Jain, H. Lin, A. Sahai, *Indistinguishability Obfuscation from Well-Founded Assumptions*, IACR ePrint 2020/1003: https://eprint.iacr.org/2020/1003
- S. Chaliasos et al., *SoK: What Don't We Know? Understanding Security Vulnerabilities in SNARKs*, USENIX Security 2024: https://arxiv.org/abs/2402.15293
- Trail of Bits, *Coordinated disclosure of vulnerabilities affecting Girault, Bulletproofs, and PlonK* ("Frozen Heart"), April 2022: https://blog.trailofbits.com/2022/04/13/part-1-coordinated-disclosure-of-vulnerabilities-affecting-girault-bulletproofs-and-plonk/
- Certora Prover documentation: https://docs.certora.com/en/latest/docs/user-guide/
- Halmos, symbolic testing for EVM smart contracts: https://github.com/a16z/halmos
- Binance, *29 October 2026 Binance Security Incident: Initial Findings and Response Update*, 3 November 2026: https://www.binance.com/en/blog/community/3229153443759566763
- Commission Delegated Regulation (EU) 2024/1774, DORA technical standard on ICT risk management: https://eur-lex.europa.eu/eli/reg_del/2024/1774/oj

---

*Carles Cerqueda*

*Independent commentary on financial stability, market infrastructures and emerging technologies. Views are personal and do not represent any current or former institution.*

---

## SEO

- **SEO title (≤60):** Would Faster 3-SAT Break the Blockchain? Layer by Layer
- **Meta description (≤155):** Consensus, signatures and zero-knowledge proofs survive the October 3-SAT results; contract verification is the twist. What authorities should ask.
- **Slug:** faster-3sat-blockchain-security-layer-by-layer
- **Tags:** blockchain, cryptography, 3-SAT, exponential time hypothesis, zero-knowledge proofs, formal verification, financial market infrastructure, tokenisation
