# Limitations

Read this before relying on any number, figure or statement in this repository.

## What the work does not show

- **It does not show that any primitive is secure.** It reports that no attack on deployed blockchain cryptography follows from the October 2026 3-SAT results as published, and that no loss in the incident list came from a broken primitive. Neither is a proof of security.
- **It does not assess any real institution's system.** Statements about named platforms come only from public material. "Not found in public material retrieved" means exactly that: a time-boxed search on 15 November 2026 did not find it. It is not a claim that the operator has not documented it, has not done it, or has a weakness.
- **It does not estimate the cost of attacking a full-round hash function.** The SAT experiment measures three solvers on one plain encoding at reduced rounds and at full rounds with few unknown bits. No extrapolation is made or implied.
- **It does not predict when a cryptographically relevant quantum computer will exist**, and uses no probability for it.

## The October 2026 results

Both papers are unrefereed. Independent review is reported as under way; as of 15 November 2026 no confirmation and no refutation has been published. Everything here is conditional on the results standing. The Lean formalisations were not re-checked in this project.

## Contracts

- Reference code for research. Not audited by a third party. Not for production use.
- The ML-DSA verifier is third-party code (ZKNoxHQ/ETHDILITHIUM, pinned commit) that its authors label experimental and unaudited. It is used to measure cost. Its gas figure is specific to that implementation; the same authors report a much cheaper experimental variant, which was not measured here.
- Gas figures are for the Osaka EVM rules as implemented by Foundry 1.9.0, with the optimiser at 10,000 runs. Other ledgers, including permissioned EVM networks with different gas schedules and non-EVM ledgers, will differ.
- Application-level scheme replacement does not reach the ledger's own transaction signatures (audit finding M-1). The model changes who can sign *instructions to these contracts*; it cannot change how the underlying ledger authenticates transactions.
- ML-DSA signatures in tests come from a fixture produced by a Python reference signer with a public test seed, because they cannot be produced inside the test runner.

## Verification

- **Formal results are relative to their abstractions.** Halmos replaces the signature schemes with an oracle; Certora treats signature validity and access-manager answers as uninterpreted. The properties proved are about what the contracts do with those answers. Certora covers the token only; DvP atomicity is covered by Halmos and fuzzing, not by Certora.
- **Medusa could not be run** against this project (compilation artefacts were not found by its build step). Echidna ran the same harness.
- **Coverage** was measured with a reduced-optimisation compiler mode that the tooling requires for this code base; five lines reported as uncovered are executed by tests and appear to be instrumentation artefacts (listed in the audit report).
- **Mutation testing** covers the Foundry suite only, not the symbolic or formal checks.
- **Continuous integration and the container build have not been run.** Docker was unavailable in the build environment and nothing has been pushed; the workflow file is untested until the first push.

## Evidence

- Labels: **V** verified against a primary source read for this project; **R** reported by a secondary source or an excerpt; **U** not found. Many statements about institutional platforms and several historical incidents remain **R** or **U**; `CLAIMS.md` says which.
- Primary sources were read through a fetch tool that summarises pages. Quotations recorded in `research/primary/` are near-verbatim and should be checked against the original before being printed as exact quotes.
- Several primary pages refused automated access (the FBI's alert on the Binance theft, Swift's press releases, some incident post-mortems). Those facts remain **R**.
- Loss figures are gross and as reported; sources disagree by several percent on the largest cases, and recoveries are not netted.
- The incident list is a selection of large and instructive cases, not a census. Shares by root cause describe the list, not the industry. Industry-wide figures are quoted from the firms that compile them.
- The cryptographic bill of materials is comparative and public-source only. A real CBOM is produced by the operator from its own systems.

## Models

- The migration timeline uses step durations chosen as planning assumptions. They are not estimates of any programme. Policy dates in the same figure are from sources.
- The threat model's likelihood and impact ratings are qualitative judgements with stated reasons.
