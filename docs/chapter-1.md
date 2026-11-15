<!-- Source: https://thekarlc.substack.com/p/ai-3sat-eth-refutation-banking-cryptography — retrieved 2026-11-15. Author: Carles Cerqueda. Reference copy for Chapter 2 work; converted from HTML with pandoc, so images and formula rendering may differ from the original. -->

# AI May Have Overturned a 25-Year-Old Conjecture. Is Financial System Cryptography Actually at Risk?

*What the OpenAI and Anthropic 3-SAT breakthroughs mean for financial stability and the security of financial market infrastructures. Blockchain networks examined in the next chapter.*

***TL;DR:** OpenAI and Anthropic’s October results could overturn the Exponential Time Hypothesis, a cornerstone of theoretical computer science. Yet neither represents a practical attack on the cryptography used by banks and financial infrastructures. For technological teams and authorities, the question is whether the research changes an adversary’s capabilities. So far, that has not been demonstrated. On the contrary, it could enable stronger security testing and formal verifications safeguards.*

------------------------------------------------------------------------

A mathematical breakthrough can be genuine, even extraordinary, without providing a usable attack against a production system. Equally, the absence of such an attack today is no basis for declaring permanent immunity.

The findinds warrant indeed attention. Their practical implications though, require a rather different examination from the headlines they have generated.

## What OpenAI and Anthropic actually found

In late October, [OpenAI](https://github.com/openai/math/tree/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026) and [Anthropic](https://hexagonmath.org/2610.00577v1) published separate AI-generated approaches to Boolean satisfiability, specifically 3-SAT and its counting counterpart, \#3-SAT.

The distinction is straightforward. SAT asks whether a set of logical constraints can all be satisfied. \#SAT counts the assignments that satisfy them.

For approximately 25 years, the Exponential Time Hypothesis (ETH) has postulated that solving 3-SAT requires exponential time in the worst case.

The OpenAI manuscript claims a deterministic exact-counting algorithm with polynomial space requirements. For fixed clause width (k), its running time is bounded by:

\\T(n,m) = (n+m)^{O_k(1)} \cdot 2^{O_k\left(n \log\log n / \sqrt{\log n}\right)}\\

Here, (n) represents Boolean variables and (m) the clauses.

The important part is the exponent. Since

\\\lim\_{n \to \infty} \frac{\log\log n}{\sqrt{\log n}} = 0\\

the running time is subexponential for polynomially bounded (m). If the result is correct, the original ETH cannot hold.

There is a technical nuance worth keeping in mind. The [published scope of OpenAI’s Lean formalization](https://github.com/openai/math/blob/main/lean/docs/378.md) documents a somewhat weaker bound, containing an additional (\log\log n) factor in the exponent. Both bounds remain subexponential, but a machine-checked statement and every detail of the accompanying manuscript are not automatically interchangeable.

What does this mean in practical terms?

A reduction in asymptotic complexity is a statement about how computational effort grows as problems become arbitrarily large. It does not tell us how long an implementation will take to solve a particular instance.

In fact, an algorithm with a superior asymptotic bound may be less efficient at every problem size we can realistically compute.

That is an especially important qualification when the discussion moves from mathematical logic to cryptography.

## From 3-SAT to AES: the missing connection

Suppose an attacker wants to recover an AES-128 key using a known plaintext and its corresponding ciphertext.

The relationship can be expressed as

\\E_K(P) = C\\

where (P) is the plaintext, (C) the ciphertext and (K) the secret key.

A Boolean circuit can represent the encryption operation. But transforming that circuit into a SAT formula generally introduces additional variables for intermediate operations.

The resulting formula has a variable count of the form

\\N = 128 + \|z\|\\

where (z) denotes the auxiliary variables.

Why does that matter?

Because the new algorithms operate on the SAT instance they receive. Their complexity cannot simply be calculated using the original 128 secret-key bits while ignoring the Boolean representation needed to express the encryption operation.

An example predates the current debate by two decades.

In a [2006 paper](https://past.date-conference.com/proceedings-archive/2006/DATE06/DF_FILES/04D_4.PDF), Potlapally and colleagues described a satisfiability-based approach to analysing cryptographic software. Their AES-128 encoding reported 10,240 entries described as *literals* and 542,432 clauses.

That example is relevant to understanding representation costs. It is not a universal measure of AES complexity, and the reported literal count should not be mistaken for a verified count of distinct SAT variables.

[](https://substackcdn.com/image/fetch/$s_!8b1C!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F668a6f80-cb20-4d8f-946d-56f781a242a0_1600x643.png)

![Comparison of brute-force search and SAT encoding](https://substackcdn.com/image/fetch/$s_!8b1C!,w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F668a6f80-cb20-4d8f-946d-56f781a242a0_1600x643.png "Comparison of brute-force search and SAT encoding")

Figure 1: Panel A illustrates the Tseitin variable expansion from raw secret key/seed bits (n) to encoded 3-CNF variables (N) across published cryptographic benchmarks. Panel B compares direct brute-force complexity (log₂ ops = n) against the idealized (C = 1) sparse subexponential \#3-SAT exponent N / √(log₂ N), demonstrating why multi-round banking ciphers remain thousands of bits more expensive to attack via SAT reduction than via brute force.

A specialised algorithm might avoid much of this expansion. An alternative cryptanalytic approach might be more effective still.

But where is that attack?

Neither October paper demonstrates a practical key-recovery method against full-round AES. Nor do the results establish a practical compromise of SHA-2, SHA-3, RSA, elliptic-curve cryptography or standardised post-quantum schemes.

## How does it effect a Financial Institution?

Consider a bank relying on encryption for its core infrastructure, alongside external dependencies on payment, clearing and settlement systems.

An important mathematical result appears. Senior management asks whether the cybersecurity risk assessment needs updating.

I would begin with the threat model.

Has anyone demonstrated an attack on a specific cryptographic primitive, using realistic parameters and resources? What information would an adversary need? How much computation and memory would the attack require? What is its probability of success?

Those answers must come before any calculation of institutional exposure.

Even a credible attack against a cryptographic construction is not automatically an attack against a particular financial participant. The next task is to establish how, where and under which controls that construction is deployed.

This is the distinction between scientific relevance and operational materiality.

The same reasoning applies to Martket Infrastructure Services, such as Fedwire or CLS. Their security depends on more than a single cryptographic primitive; an assessment establishes the actual attack path and its consequences for critical services.

OpenAI’s results also concern inversion of Boolean maps with constant output locality. Certain experimental one-way functions and pseudorandom generators rely on precisely the kinds of exponential-hardness assumptions challenged by this work.

Interesting applications might be also enabled, exploring more secure multiparty computation, zero-knowledge technology, faster formal verification and anti-money-laundering analytics.

## Where financial institutions should focus

One consequence would concern me more than the immediate cryptographic threat: confusing this research with the separate challenge posed by quantum computing.

Shor’s algorithm threatens widely deployed public-key cryptography under a sufficiently capable quantum-computing model. The October SAT results do not eliminate that concern, and they do not establish a substitute migration strategy.

[NIST’s post-quantum transition guidance](https://csrc.nist.gov/pubs/ir/8547/final) remains relevant.

For financial institutions, the sensible course is to continue mapping cryptographic dependencies, strengthening implementation controls, assessing third-party exposure and preparing for post-quantum migration.

I would put the matter to a risk committee in one sentence:

**Show me the newly feasible attack, the system it affects and the resources required. Then we can discuss the change in risk.**

Until those elements are established, an extraordinary result in theoretical computer science remains exactly just that.

And the next application of this question may be more revealing.

**Next chapter — Blockchain networks.** I will examine what happens when cryptographic assumptions underpin public consensus, digital signatures, zero-knowledge proofs and smart-contract execution, and whether the October results create a different security problem for blockchain-based financial infrastructure.

------------------------------------------------------------------------

*Carles Cerqueda*

*Independent commentary on financial stability, market infrastructures and emerging technologies. Views are personal and do not represent any current or former institution.*

