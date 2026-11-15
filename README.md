# Cryptographic assumptions and blockchain-based financial infrastructure

Companion repository to Chapter 2 of a series on cryptography and financial stability (Carles Cerqueda, *TheKarlC*). Written for the technical team of an authority, an FMI or a bank's tokenisation programme.

**Status: research code, not audited by a third party. Do not deploy anything here.**

## The question

In October 2026 two AI laboratories published claimed refutations of the Exponential Time Hypothesis. Chapter 1 asked whether that changes the risk to the cryptography used by banks and found no newly feasible attack. This repository asks the same of blockchain-based financial infrastructure, and then the broader question: when a ledger's mathematics holds, where do the cryptographic risks actually sit, and can a ledger change its signature scheme?

## What it shows

| Finding | Evidence here |
|---|---|
| No deployed blockchain signature, hash or proof system rests on the hypothesis the October results address | Annex §2 (reasoning; `CLAIMS.md` A5–A7) |
| On the twelve largest and most instructive thefts examined, none came from a broken primitive; operational compromise of keys or signing accounts for about 79% of the listed losses | `data/incidents.csv`, `results/fig_incidents.png` |
| A signing service that authenticates the caller but not the request can be made to sign an EIP-7702 authorisation that hands an account to attacker code. The signature is valid; the key never leaves the service | `contracts/test/Demos.t.sol` (Demo 3b), `docs/demos.md` |
| A ledger's signature scheme can be made replaceable without moving balances, on EVM and on Soroban | `contracts/src/KeyRegistry.sol`, `soroban/account` |
| Verifying one post-quantum signature (ML-DSA-44) in contract code costs about 8.1 million gas, roughly a thousand times ECDSA | `results/gas_table.md`, `results/fig_gas.png` |
| On an EVM ledger, application-level agility does not reach the ledger's own transaction signature | `audit/report.md` finding M-1 |
| For most institutional platforms, who can freeze, upgrade or set signer policy, and any post-quantum plan, is not found in public material | `cbom/`, `results/fig_powers_heatmap.png` |
| How today's SAT solvers scale on reduced-round SHA-256 preimages | `sat/`, `results/fig_sat_scaling.png` |

## What it does not show

It does not show that any primitive is secure, assess any real institution's system, estimate the cost of attacking a full hash function, or predict quantum timelines. See [LIMITATIONS.md](LIMITATIONS.md) before relying on anything here, and [CLAIMS.md](CLAIMS.md) for the evidence label on every claim.

## Layout

```
contracts/       Solidity (Foundry): settlement token, DvP, key registry, verifiers, demos, tests
  src/demos/     deliberately vulnerable contracts (never deploy)
soroban/         Stellar Soroban: OpenZeppelin-generated token, DvP, replaceable-scheme account
audit/           internal audit report, tool output, fuzzing corpus, Certora spec
sat/             SHA-256 CNF encoder, solver experiment, plots
cbom/            comparative cryptographic bill of materials (CSV, CycloneDX JSON)
data/            incident dataset
scripts/         figure and table generators
results/         every number and figure used in the annex and article
research/        source notes; research/primary/ records URL, date and label per fact
docs/            environment, threat model, demos, checkpoints, Chapter 1 text
```

## Reproduce

Toolchain and versions: [docs/environment.md](docs/environment.md). Then:

```bash
git clone --recurse-submodules <repo>
make pq-venv          # once: isolated Python env for the ML-DSA reference signer
make quick            # tests, gas table, CBOM, figures (minutes)
make all              # adds coverage, static analysis, Halmos, Echidna, Soroban, SAT (about an hour or more)
make certora          # needs CERTORAKEY; uses prover minutes
make mutation         # slow
```

No command contacts a blockchain network. All keys are test keys derived from public strings.

## Licence and citation

Apache-2.0 ([LICENSE](LICENSE)). Third-party code under `contracts/lib/` keeps its own licence. Citation: [CITATION.cff](CITATION.cff). Security reports: [SECURITY.md](SECURITY.md).
