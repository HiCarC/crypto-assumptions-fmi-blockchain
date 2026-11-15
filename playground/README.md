# Ledger Lab

A single, self-contained HTML page for testing the rules and failure modes of this repository in a browser. Download `index.html` and open it: no install, no network needed.

- **Real:** ECDSA P-256 signatures and SHA-256 hashes (the browser's WebCrypto), the hash-lab plain search, the signature-malleability twin and the weak-key seed search.
- **Ported:** the settlement token, DvP, key-registry and failure-mode rules, re-implemented in JavaScript from `contracts/src`, `soroban/` and `daml/`. Error names match the Solidity contracts.
- **Recorded:** SAT solver times (`results/sat_scaling.csv`) and gas figures (`results/gas.json`).
- **Simulated:** ML-DSA-44 signatures (browsers have none), using the measured sizes and costs.

It is an explainer, not a blockchain node and not the audited code. Run `make all` for the real tests.
