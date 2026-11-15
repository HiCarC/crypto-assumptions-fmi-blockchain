# Environment inventory (Phase 0)

Recorded on 15 November 2026 by running each tool's version command. Nothing here is copied from the brief; where the brief and the machine disagree, the machine is recorded.

## Host

| Item | Value |
|---|---|
| OS | Ubuntu 24.04.1 LTS on WSL2 (kernel 5.15.167.4-microsoft-standard-WSL2) |
| CPU / RAM | 12 cores / 15 GB |
| Git | 2.43.0 |
| GitHub CLI | gh 2.104.0, signed in (scopes: gist, read:org, repo, workflow) |

## Toolchain

| Tool | Version | Purpose in this project |
|---|---|---|
| Foundry (forge, anvil, cast) | 1.9.0 | Build, unit/fuzz/invariant tests, local chain, gas measurement |
| solc (via solc-select) | 0.8.38 (only version installed) | Solidity compiler |
| Slither | 0.11.6 | Static analysis |
| Aderyn | 0.6.8 | Static analysis |
| Semgrep | 1.185.0 | Static analysis (Solidity rule sets) |
| Echidna | 2.4.0 | Property-based fuzzing |
| Medusa | 1.5.1 | Property-based fuzzing |
| Halmos | 0.3.3 | Symbolic testing |
| certora-cli | 8.20.3 (`CERTORAKEY` set; value never printed) | Formal verification, free tier, 2,000 prover-minutes a month |
| Rust / cargo | 1.100.0 / 1.100.0 (targets: wasm32v1-none, wasm32-unknown-unknown) | Soroban contracts |
| Stellar CLI | 30.0.1 | Soroban build and test |
| Daml SDK | 3.7.1 via `dpm` 1.1.1-snapshot-20261102 | Daml model and Daml Script tests |
| Java | Temurin 21.0.13 (default); OpenJDK 17 present | Daml tooling |
| GCC | 13.3.0 | Native builds |
| Kissat | 4.0.4 | SAT experiment |
| CaDiCaL | 1.7.3 | SAT experiment |
| CryptoMiniSat | 5.11.15 | SAT experiment |
| Python | 3.12.3 at `~/.venvs/research` | Analysis and figures |
| Python packages | python-sat 1.9.dev22, pycryptosat 5.18.0, numpy 2.5.4, pandas 3.1.1, scipy 1.18.1, matplotlib 3.11.2, jupyter 1.1.1 | |
| Lean 4 / elan | 4.35.0 / 4.2.4 | Only to inspect the Chapter 1 formalisation if needed |
| Tectonic / pandoc | 0.17.0 / 3.1.3 | PDF annex |
| uv | 0.13.8 | Python tooling |
| Node.js | 18.19.1 | Ancillary |
| GNU Make | 4.3 | `make all` |

## Not installed (and the effect)

| Tool | Status | Plan |
|---|---|---|
| Gambit (mutation testing) | not found | Install in Phase 2, or use the Trail of Bits `mutation-testing` skill tooling (mewt/muton); record which |
| Kontrol | not found | Not needed if Halmos and Certora cover the three critical invariants |
| just | not found | Use `make` |
| Docker inside WSL | only the Windows Docker Desktop binary is on the path; not tested | A Dockerfile/devcontainer will be written, but whether it was built and run here will be stated explicitly |

## MCP servers (as reported by `claude mcp list`)

| Server | Endpoint / origin | Status | Publisher check |
|---|---|---|---|
| context7 | mcp.context7.com | connected | Upstash Context7 official endpoint |
| slither | `uvx --with fastmcp<2.14.6 --from git+https://github.com/trailofbits/slither-mcp` | connected | Trail of Bits repository; pin kept (upstream issue #35) |
| OpenZeppelinSolidityContracts, …StellarContracts, …CairoContracts, …StylusContracts, …ConfidentialContracts, …UniswapHooks | mcp.openzeppelin.com/contracts/… | connected | OpenZeppelin domain |
| plugin:zeroize-audit:serena | `git+https://github.com/oraios/serena` | connected | Serena upstream repository |
| Claude Docs, Google Sheets, Google Calendar, bioRxiv | claude.ai connectors | connected | Not planned for use |
| Gmail, Vercel | claude.ai connectors | connected, tool fetch timed out | Not planned for use |

## Skills and plugins available

Trail of Bits marketplace plugins present: `building-secure-contracts`, `entry-point-analyzer`, `audit-context-building`, `property-based-testing`, `mutation-testing`, `static-analysis`, `testing-handbook-skills`, `constant-time-analysis`, `spec-to-code-compliance`, `fp-check`, `variant-analysis`, `sharp-edges`, `rust-review`, `trailmark`, `writing-lean-proofs`, plus `differential-review`, `semgrep-rule-creator`, `dimensional-analysis`, `zeroize-audit`, `c-review`, `insecure-defaults`, `supply-chain-risk-auditor`, `cvss-scoring`, `patching-bugs`, `post-patch-validation`.

## Usage log

Which MCP servers and skills were actually used, and for what. Updated as the work proceeds.

| Date | Tool / skill | Used for |
|---|---|---|
| 2026-11-15 | Web search and fetch | Phase 1 research |
