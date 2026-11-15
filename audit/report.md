# Internal audit report: reference wholesale settlement system

| | |
|---|---|
| Date | 15 November 2026 |
| Commit | see `git log` (report written at Checkpoint 2) |
| Auditor | Internal review by the author's research team (AI-assisted). **Not an independent third-party audit.** |
| Status | Reference code for research. Not for production use. |

## 1. Scope

In scope (Solidity 0.8.38, OpenZeppelin Contracts 5.7.0, EVM version Osaka):

| File | Purpose |
|---|---|
| `contracts/src/KeyRegistry.sol` | Participant signing keys, signature-scheme life cycle (Approved → Deprecated → Disallowed), rotation and registrar replacement |
| `contracts/src/SettlementToken.sol` | Permissioned UUPS-upgradeable ERC-20 (tokenised deposit or security): allow-list, freeze, pause, issue/redeem, signed transfers |
| `contracts/src/DvP.sol` | Atomic delivery versus payment between two settlement tokens |
| `contracts/src/verifiers/ECDSAVerifier.sol`, `HybridVerifier.sol` | ERC-7913 signature verifiers |

Also reviewed, as an integration: OpenZeppelin `ERC7913P256Verifier` and the third-party ML-DSA-44 verifier `ZKNoxHQ/ETHDILITHIUM` at commit `f9f4fe1`. The latter was **not audited**: its authors describe it as experimental and unaudited, and this review relies on that statement. Soroban contracts in `soroban/` were unit-tested only (section 4.7).

Out of scope: `contracts/src/demos/` (deliberately vulnerable), deployment scripts, off-chain components (signing services, key storage, front ends). The threat model (`docs/threat-model.md`) covers the off-chain components qualitatively.

## 2. System summary

Participants never hold a signing key "on the token". Each token and the DvP contract ask the key registry whether a signature is valid for an account. The registry holds, per account, a pair (verifier contract, key bytes). Governance can approve new verifiers and retire old ones, so a ledger can move from ECDSA to a post-quantum or hybrid scheme without moving balances. Powers are split across an OpenZeppelin AccessManager: issuer, compliance (freeze and allow-list), pauser, registrar, settlement operator (the DvP contract), and timelocked governance (upgrades, scheme life cycle, role administration).

## 3. Methodology

| Technique | Tool and version | Result file |
|---|---|---|
| Manual review | line by line, against the threat model | this report |
| Unit, fuzz and invariant tests | Foundry 1.9.0: 61 tests; fuzz 512 runs; invariants 128 runs × 64 calls with 11 handler actions including hostile ones | `forge test` |
| Coverage | `forge coverage --ir-minimum` | `reports/coverage.txt` |
| Property-based fuzzing | Echidna 2.4.0, 50,160 calls, seed 2026 | `reports/echidna.txt`, corpus in `corpus-echidna/` |
| Property-based fuzzing | Medusa 1.5.1 | **could not run** (`reports/medusa.txt`) |
| Static analysis | Slither 0.11.6; Aderyn 0.6.8; Semgrep 1.185.0 with Decurity smart-contract rules (commit `2e878a8`) | `reports/slither.txt`, `aderyn.md`, `semgrep.txt` |
| Symbolic execution | Halmos 0.3.3: 4 properties plus 2 vacuity controls | `reports/halmos.txt`, `halmos-vacuity.txt` |
| Formal verification | Certora Prover (certora-cli 8.20.3): 5 rules on the token | `reports/certora.txt`, spec in `certora/` |
| Mutation testing | Gambit (Certora), all in-scope files | `reports/mutation.csv`, `mutation.txt` |
| Review checklists | Trail of Bits `building-secure-contracts` guidance (access control, upgradeability, signature handling) | this report |

## 4. Results of automated verification

### 4.1 Tests and coverage

61 tests pass. Core-contract coverage: 95.0% of lines (114/120), 95.2% of statements, 100% of branches (28/28), 100% of functions. Six lines are reported uncovered: constructor `_disableInitializers()`, `__ERC20Pausable_init()`, the pause/unpause internal calls, the storage-slot assembly line, and the hybrid verifier's success return. All six are executed by passing tests (for example `test_pauseStopsEveryMovement`, `test_hybridNeedsBothSignatures`); the gap is an artefact of the reduced-optimisation instrumentation that coverage requires for this code base. It has not been investigated further.

### 4.2 Properties checked

| Property (brief §6 C) | Fuzz / invariant | Echidna | Halmos (all inputs) | Certora (all states) |
|---|---|---|---|---|
| Supply conservation | invariant | held | — | R3 verified |
| No settlement of one leg without the other | invariant, fuzz | held | P3 holds | — (token only) |
| Only timelocked governance can upgrade | invariant | held | P4 holds | R5 verified |
| Pause stops all value movement | invariant | held | — | R4 verified |
| Signature replay impossible across nonces, chains, tokens | invariant, unit | held | P2 holds | R2 verified |
| No valid signature, no transfer | invariant, fuzz | held | P1 holds | R1 verified |

**Abstractions.** Halmos replaces signature verification with an oracle that accepts exactly one byte string per key; Certora treats signature validity and access-manager answers as uninterpreted. Both prove what the contracts do *with* those answers, not the cryptography. Halmos path counts are small (2 to 10), so two vacuity controls were added that assert the opposite of the success case; both fail as required, showing that the success paths are reachable. Certora's sanity check reported no vacuous rule.

**Specification error found and fixed.** The first Certora run reported R5 violated. The cause was the specification, not the contract: OpenZeppelin queries the access manager through a low-level staticcall inside `AuthorityUtils.canCallWithDelay`, which the first summary did not intercept. Summarising that function fixed it. Recorded so that the green result is not read as first-time-right.

### 4.3 Mutation testing

282 mutants generated; 193 did not compile and are excluded. Of the 89 that compiled, 83 were killed (93.3%). The six survivors were triaged by hand: four exposed real gaps in the tests (rotation-nonce replay masked by a key change; token metadata unchecked; unfreezing never tested; an over-long ECDSA key never tried). Four tests were added and each mutant, re-applied by hand, is now killed. The remaining two are equivalent mutants. The full campaign was not rerun after the fix.

### 4.4 Static analysis triage

| Tool | Finding | Verdict | Reason |
|---|---|---|---|
| Slither | `unused-return` in `ECDSAVerifier.verify` | False positive | The third return value of `tryRecoverCalldata` is extra error detail; the error code itself is checked |
| Slither | `timestamp` in `DvP.settle`, `transferWithAuthorization` | Accepted risk | Deadlines are minutes to hours; proposer influence on timestamps is a few seconds |
| Aderyn | H-1 "contract locks Ether" (`SettlementToken`) | Accepted risk | The only payable entry point is inherited `upgradeToAndCall`, callable only by timelocked governance. Ether sent with an upgrade would be stuck; governance procedure should forbid it |
| Aderyn | H-2 "state change after external call" (`DvP.settle`, `transferWithAuthorization`) | False positive | The external call is `KeyRegistry.isValidSignature`, a `view` function compiled to STATICCALL, which cannot re-enter to change state |
| Aderyn | L-1 empty block (`_authorizeUpgrade`) | False positive | Intentional: the `restricted` modifier is the check |
| Aderyn | L-2 literal instead of constant (`0xffffffff`) | Accepted | ERC-7913 failure value, used where the standard says |
| Aderyn | L-3 PUSH0 opcode | Accepted | Target is Osaka-compatible EVM chains |
| Aderyn | L-4 unspecific pragma | Accepted | Compiler pinned in `foundry.toml`; pragma left open for reuse |
| Aderyn | L-5 unused state variable `STORAGE_SLOT` | False positive | Used in inline assembly |
| Semgrep | 6 findings (payable constructors, prefix increment, nested `if`) | Accepted | Gas-optimisation suggestions from the performance rule set; no security impact |

No tool reported a true positive.

## 5. Findings

Severity follows impact and likelihood in this reference deployment. No finding is critical or high.

### M-1. Scheme agility does not reach the ledger's own transaction signature — Medium

**Description.** `SettlementToken` still exposes standard `transfer`, `approve` and `transferFrom`. These are authorised by the ledger's native transaction signature (ECDSA secp256k1 on Ethereum), not by the key registry. When governance deprecates or disallows ECDSA in the registry, a holder whose account is an ordinary key-controlled account can still move tokens by sending a normal transaction.

**Impact.** The migration path tested here changes who can sign *instructions to these contracts*; it does not change how the ledger authenticates transactions. If ECDSA were broken, holdings in ordinary accounts would remain exposed whatever the registry says. This is the central limit of application-level agility on a public EVM ledger.

**Recommendation.** For holders, use contract accounts (account abstraction) whose own validation follows the registry, and disable direct `transfer` for accounts whose native scheme is deprecated; or deploy on a ledger whose native account model supports the target scheme. Record the limit in any supervisory description of the migration plan.

**Status.** Not fixed, deliberately: it is a result of the study (CLAIMS C6).

### M-2. Registrar can replace any participant's key immediately — Medium (by design)

**Description.** `registerKeyFor` lets the registrar role set or replace any account's key with no delay and no consent from the account.

**Impact.** This is the only recovery path when a scheme is broken or disallowed (test `test_disallowedSchemeStrandsSignaturesNotBalances`), and also a single point of control: whoever controls the registrar can re-key an account and then sign for it.

**Recommendation.** Split onboarding from replacement. Require multi-party approval and a delay for replacing an existing key, with an event-driven alert to the account holder; allow immediate action only for first registration.

**Status.** Not fixed; documented in the threat model (risk R2).

### M-3. Post-quantum verification depends on unaudited code and costs about a thousand times ECDSA — Medium

**Description.** The ML-DSA-44 path uses a third-party verifier that its authors label experimental and unaudited. Measured cost is about 8.1 million gas per verification, plus about 5.3 million gas once to register a key.

**Impact.** A flaw in the verifier would let forged signatures pass for accounts using ML-DSA alone. In hybrid mode an attacker would also need a valid classical signature. The cost limits how many such transactions a block can hold.

**Recommendation.** Use hybrid mode only until an audited implementation or a native precompile exists; track the ML-DSA precompile proposal for Ethereum and the native host functions announced for Stellar.

### L-1. DvP accepts any token addresses named in the signed order — Low

**Description.** `settle` calls `settlementTransfer` on whatever token addresses the order names. Both parties sign the order, so neither can be forced into a fake token, but a party can be tricked off-chain into signing one.

**Recommendation.** Keep an allow-list of settlement tokens in the DvP contract, managed by governance.

### L-2. Seller and buyer sign the same digest — Low

**Description.** Both parties sign `orderDigest(o)`. If two accounts were ever registered with the same key (by the registrar, or by an account rotating to another's public key), one party's signature would also satisfy the other's check. `test_signaturesAreNotInterchangeable` passes only because the keys differ.

**Recommendation.** Include the signer's role (seller or buyer) in the signed structure, so the two signatures are over different messages.

### L-3. Key rotation does not prove possession of the new key — Low

**Description.** `rotateKey` and `registerKeyFor` accept any key bytes. An account can lock itself out, or register another party's public key (see L-2).

**Recommendation.** Require a signature by the new key over the rotation message.

### I-1. Immediate single-role powers

Freeze, allow-list, pause, issue and redeem act without delay, by design (a delayed freeze is not a freeze). Each is a separate role, verified by `test_rolesDoNotLeakAcrossPowers`. Operational controls on these roles are where an attacker would aim (threat model R10).

### I-2. Upgrade safety not checked by tooling

Storage-layout compatibility of future implementations is protected by ERC-7201 namespaced storage, but was not checked with OpenZeppelin's upgrade-safety validator. Run it before any upgrade.

### I-3. Medusa and CI not run

Medusa could not compile the project; Echidna covered the same harness. The CI workflow has not run because nothing has been pushed.

## 6. Soroban implementation (second ecosystem)

The token was generated with the OpenZeppelin Contracts Wizard for Stellar (roles, mintable, burnable, pausable, upgradeable; library 0.7.2) and is unmodified. A DvP contract and a contract account with a replaceable signature scheme were written for this repository. 8 unit tests pass and all three build to WebAssembly (`reports/soroban-tests.txt`). No fuzzing, static analysis or formal verification was run on the Soroban code.

The architectural contrast for the annex: on Soroban the DvP contract contains no signature code at all. It calls `require_auth`, the ledger asks each party's account to authorise, and the ledger consumes the nonce. Scheme agility therefore sits in the account, and the account's address does not change when its scheme does (`scheme_changes_address_does_not`). This removes finding M-1 for contract accounts. It does not remove it for classic Stellar accounts, which remain Ed25519.

## 7. Residual risk

After the recommendations, the main residual risks are not in this code. They are in the signing environment and the governance process: a valid signature over the wrong instruction (the Bybit and Binance patterns), and the concentration of powers in the registrar, governance and compliance roles. These are rated in `docs/threat-model.md`.
