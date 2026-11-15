# Chapter 2 — draft (layer-by-layer)

## Headline options

1. Would a Faster 3-SAT Algorithm Break the Blockchain? Layer by Layer, No — With One Twist
2. From 3-SAT to the Ledger: Consensus, Signatures and Proofs Stand; Verification Shifts
3. The October 3-SAT Results Meet Blockchain Finance: Sound Mathematics, a Dual-Use Twist

## Subtitle options

1. Chapter 1 promised to test consensus, signatures, zero-knowledge proofs and smart contracts against the October results. The mathematics holds; what changes is the remedy. Next: post-quantum migration of payment systems.
2. I pointed today's best SAT solvers at the hash behind Bitcoin, then asked the same question of every layer of a ledger. Next chapter: post-quantum migration in payments.
3. Why the AI-generated 3-SAT results leave blockchain cryptography standing, why the tools that verify smart contracts are the exception, and what authorities should ask. Next: post-quantum payments.

---

*TL;DR: A much faster algorithm for 3-SAT would not, on current knowledge, weaken the consensus, signatures or zero-knowledge proofs that blockchains rely on, because none of them rests on the hardness the October results address. The one place where SAT solving matters directly is smart-contract verification, where any practical advance would help defenders and attackers alike. What blockchains do change is the consequence and the remedy when an assumption weakens: the record is permanent and replacing a primitive is a governance decision. That is where authorities' questions should go.*

---

I wanted to see what today's tools can do before asking what a better algorithm might do. So I pointed three of the best SAT solvers available at SHA-256, the hash function behind Bitcoin, and asked them to find inputs that produce a given output.

On versions of the function cut down to 18 of its 64 rounds, they succeeded. At 19 rounds, none succeeded within two minutes.

On the full function, I hid only a dozen bits of the input and gave the solvers the rest. They took up to a minute to find what a plain search through every possibility finds in milliseconds.

![Two scatter charts on a logarithmic time scale. Left: time for three SAT solvers to find an input for reduced versions of SHA-256 with the whole input unknown; under a tenth of a second up to 16 rounds, under one second at 17, between about 40 and 120 seconds or no answer at 18, and no answer at 19. Right: the full 64-round function with 4 to 20 input bits hidden; times rise from under a second at 4 bits to tens of seconds at 12 bits, one answer at 16 bits and none at 20.](../results/fig_sat_article.png)

*Figure: Time for three current SAT solvers (Kissat, CaDiCaL, CryptoMiniSat) to find an input for SHA-256, three random instances per point, 120-second limit; x marks no answer. Left: rounds increasing, whole input unknown. Right: full function, a few input bits hidden. One straightforward encoding on one machine; it describes today's tools, not future algorithms.*

## The promise from Chapter 1

In [Chapter 1](https://thekarlc.substack.com/p/ai-3sat-eth-refutation-banking-cryptography) I looked at the AI-generated results from OpenAI and Anthropic that, if correct, overturn the Exponential Time Hypothesis for 3-SAT. I found an extraordinary result but no newly feasible attack, and I proposed a test: show me the attack, the system and the resources.

I also promised to examine what happens when cryptographic assumptions underpin public consensus, digital signatures, zero-knowledge proofs and smart-contract execution, and whether the October results create a different security problem for blockchain-based financial infrastructure. This chapter keeps that promise, one layer at a time.

## One question, four layers

The question is the same for each layer: would a much faster algorithm for 3-SAT and #3-SAT change anything here?

For each, I ask what the layer relies on, whether that rests on the hardness the hypothesis describes, what my tests found, and what remains uncertain.

## Consensus

Consensus is how a ledger's participants agree on one history. Bitcoin uses proof of work: miners repeatedly hash candidate blocks with SHA-256 until one meets a target. Ethereum, and the permissioned ledgers used in finance, rely instead on validators signing their votes.

Neither rests on the hardness the October results address. As I read the published analyses, the security of a hash function is a judgement about the best known attacks on that specific function, and signatures rest on problems from elliptic-curve and pairing-based mathematics.

My solver tests show where SAT methods stand against the hash. The best published attacks on reduced versions of SHA-256 also stop well short of the full function, and remain close to the cost of trying every input. [[V pending: steps and complexity]]

The residual is narrow. A faster method for finding hash inputs would matter for proof of work, but it would have to be a practical one, and neither paper offers that.

## Digital signatures

Every transfer on a ledger is authorised by a digital signature, almost always based on elliptic curves. Their security rests on the difficulty of the elliptic-curve discrete-logarithm problem.

That problem is not known to be one of the hard problems that 3-SAT represents, and its security estimates are not derived from the hypothesis. As far as I can see, a faster SAT algorithm offers no known route to it.

The real long-term threat to these signatures is a large quantum computer, which is a different question with a different timetable. It is the subject of Chapter 3.

## Zero-knowledge proofs

Zero-knowledge proofs let one party convince another that a statement is true without revealing why. Ledgers use them for privacy and to compress the checking of many transactions into one proof.

Their soundness rests on other assumptions: discrete-logarithm and pairing problems, collision-resistant hashing, assumptions about what a prover must know, and the treatment of a hash function as a source of randomness. None of these is the hardness the October results address.

There is one genuine nuance. OpenAI's result also concerns inverting functions in which each output bit depends on only a few input bits. [[V pending: exact wording]] Some experimental pseudorandom generators of this kind, first proposed by Oded Goldreich, underpin research constructions, including recent results on program obfuscation. [[V pending]] I found none of them in production use.

The zero-knowledge failures that have actually occurred were implementation bugs: circuits that failed to constrain what they should, and flawed implementations of the step that turns an interactive proof into a single message.

The same is true of a related family. Because the strong form of the hypothesis implies the ordinary one, refuting the ordinary form refutes both. Constructions whose security is proved from either, including some proposals for "useful" proof of work, lose their proofs. I found none in production use.

## Smart-contract execution

Here is the twist. The mathematics of contract execution is not at stake, but the tools that check contracts are built on SAT solving.

Formal verification tools translate a contract and the property it must satisfy into logical formulas, and hand them to solvers that decide whether any input breaks the property. [[V pending: Certora/Halmos docs]] Bug-finding tools work the same way, looking for an input that does break it.

In this project I used two such tools on a reference settlement system. One proved, for every possible state of the token, that no transfer happens without a valid signature, that each authorisation works only once, that supply changes only through issuance and redemption, that nothing moves while the system is paused, and that privileged functions refuse unauthorised callers. The other proved that a delivery-versus-payment settlement moves both legs or neither, whatever the amounts.

A genuinely faster solver would make this kind of assurance cheaper. It would also make it cheaper to search other people's contracts for flaws. That is a dual-use shift, and it would favour whoever adopts it first.

The October results are about how running time grows as problems become arbitrarily large. As published, they do not come with a faster solver for problems of the size these tools handle. The twist is a direction to watch, not a change today.

## A different security problem?

Not from the mathematics. But blockchains do change two things when a cryptographic assumption weakens: the consequence and the remedy.

The consequence is larger because the assumptions are public and the record is permanent. Every signature, and every public key revealed by spending, stays on the ledger for anyone to attack later.

The remedy is harder because replacing a primitive is a governance decision. It needs a protocol upgrade, or a migration of every account, decided by whoever can change the ledger's rules. In my tests, holders who never migrated kept their balances but could no longer sign, and only a privileged registrar could bring them back.

So three powers matter alongside the mathematics: who can change the rules, who can freeze an asset, and who decides which keys count. For 14 institutional and central-bank platforms I examined, 47 of 56 answers on those powers and on post-quantum plans were not found in public material.

The losses so far confirm where the risk sits. According to Binance's own report, the US$6.3 billion attack on it in October went through unauthorised use of an internal signing service. Binance said it found no evidence that any wallet's private key had leaked. The signatures were valid; the operations around them failed.

## What authorities should ask

1. Which cryptographic primitives does each layer of this ledger depend on (consensus, account signatures, any proof system, contract code), and on which assumptions?
2. If one of those assumptions weakened, who would decide on a replacement, how quickly could it be deployed, and what would happen to holders who do not act?
3. Are the contracts that hold settlement assets formally verified, against which properties and with which tools?
4. Who can change the ledger's rules and the contracts' code, and with what delay?
5. Who can freeze or reverse a transfer of each settlement asset, and how does that sit with the legal point of finality?
6. Which of these answers are written down, and who outside the operator can read them?

Chapter 1 asked for the newly feasible attack before discussing a change in risk. For a ledger, ask for the assumption under each layer and the party who could replace it in time; only then discuss the mathematics.

*Next, Chapter 3: the threat that does reach these signatures. Post-quantum migration of payment systems, what it costs on a ledger, and what the central banks' own tests found.*
