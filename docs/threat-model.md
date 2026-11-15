# Threat model for the reference settlement system

Scope: the system in `contracts/src` (key registry, settlement token, DvP, verifiers) as deployed by `contracts/test/utils/Fixture.sol`, plus the off-chain components any real deployment would need (signing service, key storage, governance multisig, front ends). The off-chain parts are not built here; they are in scope because that is where the incidents in `research/primary/incidents.md` happened.

Likelihood and impact are **low / medium / high with stated reasoning**. No numeric probabilities are used anywhere in this document.

## 1. What is being protected

| Asset | Why it matters |
|---|---|
| Balances of the cash and asset tokens | Claims on a bank or issuer; the settlement asset itself |
| Atomicity of DvP | Principal risk reappears if one leg can settle alone |
| The key registry (who may sign for whom, under which scheme) | Controls every signed instruction |
| Governance powers: upgrade, scheme life cycle, registrar, freeze, pause, issue | Each can move, block or redefine balances |
| Signing keys and, separately, the service that uses them | The Bybit and Binance cases show these are different assets |

## 2. Who holds which power

| Power | Holder in the reference deployment | Delay | Concentration |
|---|---|---|---|
| Upgrade token code | Timelock, proposed by governance multisig | 2 days | Multisig threshold |
| Approve, deprecate, disallow a signature scheme | Timelock | 2 days | Multisig threshold |
| Change roles in the access manager | Timelock | 2 days | Multisig threshold |
| Set or replace a participant's key (registrar) | Registrar account | none | **Single role** |
| Freeze, allow-list | Compliance account | none | Single role |
| Pause | Pauser account | none | Single role |
| Mint, burn (including claw-back from frozen accounts) | Issuer account | none | Single role |
| Move tokens without the holder's signature | DvP contract only, after two valid signatures | none | Code |
| Sign for a participant | That participant's registered key | none | Participant |

The registrar, compliance, pauser and issuer roles act immediately by design: a freeze that waits two days is not a freeze. The consequence is that these four roles are where an attacker with operational access would aim.

## 3. Trust boundaries

1. Participant's signing environment → ledger (what the signer sees versus what is signed).
2. Signing service → key store (who may ask for a signature, and for what).
3. Governance multisig signers → timelock.
4. Ledger protocol → contracts (protocol upgrades can add message types and precompiles).
5. This ledger → other ledgers (bridges, messaging). Out of scope for the build; demonstrated in `Demo4`.
6. Third-party code → this system (OpenZeppelin libraries; the ML-DSA verifier, which is experimental).

## 4. Attack trees

**Goal A: move a participant's balance without their consent**

- A1. Forge a signature under the participant's scheme
  - A1.1 Break the primitive mathematically. *No known method for the schemes used; not affected by the October 2026 SAT results (annex §2).*
  - A1.2 Break it with a large quantum computer (secp256k1, P-256). *Not available today; public key is exposed permanently once registered.*
  - A1.3 Exploit an implementation flaw in a verifier. *Relevant to the experimental ML-DSA verifier; mitigated by hybrid mode.*
- A2. Obtain a genuine signature over the wrong instruction
  - A2.1 Compromise what the signer sees (Bybit pattern, `Demo3a`).
  - A2.2 Ask a signing service that checks who asks but not what is asked (Binance pattern, `Demo3b`).
  - A2.3 Replay a genuine signature (`Demo1`). *Closed here: chain, contract and nonce are bound; verified by Halmos P2, Certora R2.*
- A3. Obtain the key
  - A3.1 Weak generation (`Demo5`). A3.2 Theft from storage. A3.3 Insider.
- A4. Bypass signatures through a privileged role
  - A4.1 Registrar replaces the participant's key, then signs. *Open by design; see risk R2.*
  - A4.2 Issuer burns and re-mints elsewhere. A4.3 Malicious upgrade. *Timelocked.*
- A5. Use the ledger's own transaction signature instead of the registry (plain `transfer`). *Open; audit finding M-1.*

**Goal B: settle one leg of a DvP without the other.** Requires a token that misbehaves (the order names its tokens; finding L-1) or a malicious upgrade. Otherwise excluded: Halmos P3, invariant and fuzz campaigns.

**Goal C: block settlement (availability).** Pauser or compliance role compromise; disallowing a scheme before participants have migrated (governance error rather than attack); a verification cost that exceeds what the ledger allows in one transaction (ML-DSA at about 8 million gas, annex §5).

## 5. STRIDE

| Category | Example in this system | Control present | Residual |
|---|---|---|---|
| Spoofing | Forged or replayed authorisation | Registry verification; EIP-712 domain; single-use nonces | A2, A3 (off-chain) |
| Tampering | Malicious upgrade; altered order terms | Timelock; both parties sign the full order | Multisig collusion or compromise |
| Repudiation | Participant disputes an instruction | Events for every key change and authorisation | "Valid signature, wrong instruction" is not repudiable on-chain |
| Information disclosure | Public keys and balances visible | None: a public EVM deployment exposes both | Permanent key exposure (harvest now, forge later) |
| Denial of service | Pause, freeze, scheme disallowed early, gas cost | Role separation; deprecate-before-disallow life cycle | Single-role powers act instantly |
| Elevation of privilege | Outsider calls a restricted function | Access manager; Certora R5, Halmos P4 | Compromise of a role holder's key or signing service |

## 6. MITRE ATT&CK mapping (enterprise matrix), where meaningful

| Incident pattern | Technique |
|---|---|
| Fake job offer with malicious coding test (reported for the Binance case) | T1566 Phishing; T1204 User Execution |
| Tampered developer tool download (reported for the Binance case) | T1195 Supply Chain Compromise |
| Compromised web front end of a wallet provider (Bybit) | T1195 Supply Chain Compromise; T1565 Data Manipulation |
| Use of an internal signing service with valid credentials | T1078 Valid Accounts; T1199 Trusted Relationship |
| Theft of the assets | T1657 Financial Theft |

ATT&CK has no technique for on-chain logic flaws; those are classified by root cause in the annex instead.

## 7. Risk register

| ID | Risk | Likelihood | Impact | Reasoning | Treatment |
|---|---|---|---|---|---|
| R1 | Genuine signature over the wrong instruction (signing interface or signing service compromised) | **High** | **High** | The two largest thefts on record (Bybit 2025, Binance 2026) followed this pattern; both involved operational compromise of well-resourced firms | Typed signing policy; independent display; per-type allow-list reviewed at every protocol upgrade |
| R2 | Registrar role compromised or misused | Medium | High | One role can re-key any participant immediately; it is also the only remedy after a scheme break | Multi-party control and a delay for re-keying existing accounts; alerts on `KeyRegistered` by registrar |
| R3 | Plain transfers bypass the registry's scheme life cycle | Medium | Medium | Any holder with an ordinary account can use the ledger's native signature; matters once that scheme is deprecated | Restrict holders to contract accounts, or disable direct transfers when the native scheme is deprecated |
| R4 | Classical signature scheme broken by a quantum computer before migration completes | Low today, rising | High | No such machine exists; resource estimates fell in 2026; registered public keys cannot be withdrawn | Hybrid keys; deprecate/disallow schedule tied to NIST IR 8547 and the EU roadmap |
| R5 | Flaw in the post-quantum verifier | Medium | Medium in hybrid mode, High alone | The verifier used is experimental and unaudited by its authors' statement | Hybrid only; independent audit before any production use |
| R6 | Post-quantum verification too expensive to use | High on today's EVM | Medium | Measured: about 8.1 million gas per check | Native precompile, cheaper encoding, or a ledger with native support |
| R7 | Governance multisig compromised | Low | High | Needs a threshold of signers and survives a 2-day public delay | Monitoring of the timelock queue; pause |
| R8 | A protocol upgrade adds a message type the signing policy does not cover | Medium | High | This is what the Binance report describes for EIP-7702 | Change-management link from ledger upgrades to signer policy |
| R9 | Mathematical break of a deployed primitive by classical means, including via the October 2026 SAT results | Low | High | No attack demonstrated; the affected hypothesis is not what these primitives rest on | Monitor; no action specific to this result |
| R10 | Freeze, pause or issuer role compromised | Medium | Medium | Immediate single-role powers; effects are visible and reversible by governance | Role separation (tested); rate limits; multi-party control |
