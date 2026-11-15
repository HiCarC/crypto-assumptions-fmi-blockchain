# Handoff — Chapter 2 run

Written 15 November 2026 when the usage window reached 95%. Work is in Phase 2/3 (build and test), between Checkpoint 1 (approved) and Checkpoint 2 (not yet reached). Nothing has been pushed; the repository is local only.

## Author's standing decisions (after Checkpoint 1)

- Proceed with the build; close research gaps alongside the annex. Any claim in the article must be verified from a primary source before Checkpoint 3.
- Sub-agents: at most 2–3 in parallel, only for reading primary sources. Be economical (Pro plan).
- Binance may be the article hook: confirmed from Binance's own 3 November 2026 report (see `research/primary/incidents.md`). Add one bridging paragraph from exchange to FMIs and tokenised deposits.
- Develop the freeze-key point fully: say who holds freeze, upgrade and signer-policy powers on each institutional ledger.
- Gambit installed for mutation testing; Kontrol skipped; Docker is not available in WSL, so rely on GitHub Actions for the container check.
- Keep the repository private; do not push before Checkpoint 2.

## Done

| Item | Where | State |
|---|---|---|
| Environment inventory | `docs/environment.md` | Done; add usage-log rows for tools used since |
| Chapter 1 text | `docs/chapter-1.md` | Done |
| Phase 1 research and Checkpoint 1 | `research/`, `docs/checkpoint-1.md` | Done |
| Primary-source reading (3 reader agents) | `research/primary/{incidents,standards-quantum,ledgers}.md` | Done; **not yet merged into `research/claims-ledger.md`** |
| Core contracts | `contracts/src/{KeyRegistry,SettlementToken,DvP}.sol`, `src/verifiers/` | Done, compiling with solc 0.8.38, OpenZeppelin 5.7.0 |
| ML-DSA-44 verifier | submodule `contracts/lib/ETHDILITHIUM` pinned at `f9f4fe1` | Third-party, experimental, unaudited by its authors' own statement |
| Unit, fuzz, invariant tests | `contracts/test/` | 57 tests pass; invariants 128 runs × 64 calls |
| Failure-mode demonstrations | `contracts/src/demos/Vulnerable.sol`, `test/Demos.t.sol` | 6 demos pass, including a real EIP-7702 delegation (Binance pattern) and the Bybit pattern |
| Gas table | `results/gas.json` | ECDSA verify 7,955 gas; P-256 precompile 12,712; P-256 in Solidity 237,278; ML-DSA-44 8,146,057; ML-DSA key registration 5,263,193 |
| Coverage | `audit/reports/coverage.txt` | 95.0% lines, 100% branches on core contracts (run with `--ir-minimum`) |
| Slither, Aderyn, Semgrep | `audit/reports/` | Run; findings not yet triaged in writing |

## In progress when stopped

- **Halmos**: all four properties pass (`audit/reports/halmos.txt`; run with `FOUNDRY_DYNAMIC_TEST_LINKING=false halmos --contract HalmosChecks`, about 2 seconds). Path counts are small (4 to 10), so before reporting these as proofs, add a vacuity check: confirm at least one path reaches the success branch in `check_nonceIsSingleUse` and `check_dvpIsAtomic` (for example a mirror check asserting the opposite, which must fail). The cryptography is replaced by an oracle verifier in these checks; say so in the audit report.
- Uncommitted work since commit `0ee1d02`: demos, invariants, Halmos file, audit reports. Committed together with this file.

## Not started

1. Component C remainder: Halmos vacuity check, Echidna and/or Medusa campaign, Certora Prover on the three critical invariants (free tier, keep runs focused), Gambit mutation score, written triage of static-analysis findings, internal audit report (`audit/report.md`).
2. Component E: reduced-round SHA-256/Keccak SAT experiment (`sat/`).
3. Component A: CBOM (CycloneDX JSON + CSV) from `research/primary/ledgers.md`; many fields are "not publicly documented".
4. Component F: quantum exposure table and migration timeline. Note the correction below on the Glassnode figure.
5. Component G: threat model, STRIDE, risk register.
6. Second ecosystem: Soroban (OpenZeppelin Stellar contracts) or Daml DvP.
7. Repository engineering: README, Makefile (`make all`, `make pq-fixtures`), CI workflow, CLAIMS.md, LIMITATIONS.md, SECURITY.md, LICENSE, CITATION.cff, `docs/demos.md`.
8. Checkpoint 2 report, then annex, article, adversarial review.

## Findings to carry forward

Audit observations of my own, to go into the internal audit report:

- **Agility gap (medium).** The token still exposes plain `transfer`/`approve`, which rely on the ledger's own secp256k1 transaction signature. Disallowing ECDSA in the key registry does not stop a holder's account from moving funds by ordinary transaction. Application-layer agility does not reach the ledger's native signatures. Not fixed; it is a result worth reporting.
- **Registrar concentration (medium, by design).** The registrar can replace any participant's key. It is the remedy when a scheme breaks and also a single point of control.
- **DvP accepts any token address named in the signed order (low).** Recommend an allow-list.
- **Key rotation has no proof of possession of the new key (low).**
- **ML-DSA verification at about 8.1 million gas** is a large share of a block; upstream reports an experimental packed variant near 1.2 million, which I have not measured.

Corrections from primary reading, not yet applied to the ledger:

- Glassnode's own page (20 May 2026) says 6.04M BTC / 30.2% with exposed keys. The 7.12M / 35.4% figure for 10 November appears only in press.
- The FBI's Binance alert is on fbi.gov (not ic3.gov) and could not be opened (HTTP 403): still "reported".
- Binance's "no evidence of a private-key leak" is in its 30 October updates; the 3 November report instead describes an MPC wallet and an unauthorised use of the internal signing service, names EIP-7702, and mentions an internal AI tool without explaining how it was abused.
- THORChain's second exploit report is dated 3 July 2026 and says the library never verified the Paillier modulus; loss about $10m.
- NIST IR 8547 is final (27 October 2026). Check Table 2 by eye for the treatment of 128-bit strengths before citing.
- Swift's use of Besu is not confirmed on swift.com. L2BEAT now redirects to another domain; all rollup governance data is still "reported".

## How to resume

```bash
cd ~/work/crypto-assumptions-fmi-blockchain/contracts
forge test                                   # 57 tests
FOUNDRY_DYNAMIC_TEST_LINKING=false halmos --contract HalmosChecks
```

ML-DSA fixtures are regenerated with `forge test --match-test test_emitDigests`, then `tools/.venv-pq/bin/python tools/mldsa.py fixtures results/pq-digests.json contracts/test/fixtures/mldsa44.json`. The Python environment in `tools/.venv-pq` is not committed; `docs/environment.md` should gain its package list.

Note: the usage hook asked me to follow a `/handoff` skill. No skill of that name is available in this session, so this file was written by hand.
