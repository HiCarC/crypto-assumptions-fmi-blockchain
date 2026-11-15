### Policy dates and platform plans (from sources)

| Date | Item | Evidence | Source |
|---|---|---|---|
| 13 Aug 2024 | NIST FIPS 203/204/205 final | V | csrc.nist.gov |
| 23 Jun 2025 | EU coordinated PQC roadmap published | V | digital-strategy.ec.europa.eu |
| 27 Oct 2026 | NIST IR 8547 final | V | csrc.nist.gov/pubs/ir/8547/final |
| 31 Dec 2026 | EU: national transition plans started | R | EU roadmap (secondary reading) |
| 31 Dec 2030 | NIST: ECDSA/EdDSA/RSA deprecated after 2030; EU: high-risk use cases migrated | V / R | NIST IR 8547; EU roadmap |
| 31 Dec 2035 | NIST: disallowed after 2035; G7 CEG: general target 2035 | V | NIST IR 8547; G7 CEG roadmap |
| 31 Dec 2026 | Stellar: ML-DSA verification in contracts (plan) | V | stellar.org |
| 31 Dec 2027 | Stellar: quantum-safe account signers (plan) | V | stellar.org |
| 30 Jun 2029 | Ethereum: L1 upgrades estimated around 2029 | V (stated as an estimate) | pq.ethereum.org |

### Migration steps (durations are planning assumptions, not estimates)

| Step | Assumed months | Begins | Ends | Who decides or acts |
|---|---|---|---|---|
| 1. Cryptographic inventory (CBOM) of ledger, contracts, wallets, HSMs, bridges | 6 | Jan 2027 | Jul 2027 | operator + participants |
| 2. Governance decision: target scheme, hybrid or not, sunset dates | 6 | Jul 2027 | Jan 2028 | ledger governance body |
| 3. HSM / KMS / wallet support for the new scheme | 12 | Jan 2028 | Jan 2029 | vendors + each participant |
| 4. Verifier deployed and approved on the ledger; audit and testing | 9 | Jan 2028 | Oct 2028 | operator + auditors |
| 5. Participants register new keys (hybrid), dual running | 12 | Jan 2029 | Jan 2030 | every participant |
| 6. Classical-only keys deprecated: no new registrations | 6 | Jan 2030 | Jul 2030 | ledger governance body |
| 7. Classical-only keys disallowed; stragglers recovered by registrar | 6 | Jul 2030 | Jan 2031 | ledger governance body + registrar |

Critical path under these assumptions: 48 months from January 2027 to January 2031. Deprecation (step 6) begins January 2030.
