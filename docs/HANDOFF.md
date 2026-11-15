# Handoff — Chapter 2 run

## Updated

15 November 2026, around 13:00 CET. 5-hour usage window at 95% (resets 14:10 CET). Model: Opus 5.5 (switched by the author); commit attribution "Claude Opus 5.5". The article and adversarial review are reserved for Fable after its limit resets on **20 November 2026**.

## Mission and where we are

Chapter 2 of the author's series (brief pasted in the first session; summary in `docs/checkpoint-1.md` and `docs/checkpoint-2.md`): a reproducible repository, a technical annex and later a Substack article on cryptographic assumptions and blockchain-based financial infrastructure. **Checkpoint 2 is answered.** We are executing the author's Checkpoint 2 decisions; Phase 4 (annex) has not started. **After the annex: write this handoff and STOP.**

## Author decisions (binding)

Checkpoint 1 answers (15 Nov 2026):
- Proceed with the build; close research gaps alongside the annex. Any claim used in the article must be V (primary source read) before Checkpoint 3.
- Add the Binance-style demonstration (signer whose policy never anticipated an EIP-7702 authorisation); keep the Bybit-style one, smaller. Both done.
- Sub-agents: at most 2–3 in parallel, only for reading primary sources. Be economical (Pro plan).
- Bridging paragraph from exchange to FMIs and tokenised deposits: "an exchange is not an FMI".
- Develop the freeze-key point fully: immutability is a governance property of each asset; say who holds freeze, upgrade and signer-policy powers on each institutional ledger.
- Gambit for mutation testing; Kontrol skipped; if Docker fails, say so and rely on GitHub Actions.
- Keep the repository private.

Checkpoint 2 answers (15 Nov 2026), verbatim where possible:
1. "Yes: push to a private GitHub repo crypto-assumptions-fmi-blockchain and run CI. Before pushing, check that no secret or key is committed (scan the history, check .gitignore). Do not put Certora in CI unless it reads CERTORAKEY from a GitHub secret; if so, tell me and I'll add the secret myself. Never print the key."
2. "Hook: Binance, based on Binance's own 3 November report. Leave the North Korea attribution out of the article; the argument doesn't need it. Keep it in the annex as 'reported'."
3. "Yes: close the primary-source gaps with at most two reading agents, limited to what the annex and article cite."
4. "Yes: adopt the 'who holds the powers' framing (signer policy, upgrade, freeze, registrar) as the spine. The PQ cost result is the second pillar."
5. "Do not use the 79%/59% figures from the twelve-case list in the article. Use TRM Labs' industry figures with the source, or state it qualitatively. Write 'not found in public material', never 'does not exist'."
6. "Add a minimal Daml/Canton model, short, focused on powers: signatories, controllers, who can archive or freeze, and how package upgrades are authorised. Skip it only if it costs more than about 10% of the remaining budget, and say so."
7. "Try Medusa once more with crytic-compile's Foundry settings; if it fails again, leave it disclosed as it is."
8. "After the annex, write docs/HANDOFF.md and stop. I want the article and the adversarial review done with Fable after its limit resets on 20 November."

These rules are also in Claude memory (`chapter2-working-rules`).

## Done

| Item | Proof |
|---|---|
| Environment, Chapter 1 text, Phase 1 research, Checkpoint 1 | `docs/environment.md`, `docs/chapter-1.md`, `research/`, `docs/checkpoint-1.md` |
| Primary-source reading (round 1) | `research/primary/{incidents,standards-quantum,ledgers}.md` |
| Components A–G, Soroban, audit, repo docs | commit `1944185`; `docs/checkpoint-2.md` §1 |
| 61 Foundry tests pass; Echidna, Halmos (+ vacuity), Certora R1–R5, mutation 93.3% with survivors triaged | `audit/report.md`, `audit/reports/` |
| Checkpoint 2 report | `docs/checkpoint-2.md`, commit `6a03b56` |
| Secret scan, partial (this session) | CERTORAKEY: **0 occurrences** in `git log --all -p` (checked by `grep -cF -- "$CERTORAKEY"`, key never printed). 64-hex literals found are public constants only (ERC-1967/ERC-7201 storage slots, secp256k1 and P-256 curve orders). `.certora_internal/`, `.serena/`, `tools/.venv-pq/` are ignored, not tracked. No `.env`, `.pem`, `.key`, `id_rsa`, `.p12` tracked |

## In progress

- **Secret scan:** the pattern search over history failed on a regex error (empty alternative in `(RSA |EC |OPENSSH |)`). Rerun before pushing:
  ```bash
  git log --all -p | grep -nE "BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_|xox[baprs]-|sk-[A-Za-z0-9]{20,}|CERTORAKEY *=" | cut -c1-120
  ```
  Expected: no output. Note: `contracts/lib/` submodules are not part of our history; `contracts/test/fixtures/mldsa44.json` holds an ML-DSA *public* key and signatures from a public test seed (not secret).
- **SAT experiment: FINISHED** (`results/sat_scaling.csv`, `results/fig_sat_scaling.png`, `results/sat_summary.csv`; 120 s limit, 3 instances per point). All 512 message bits unknown: every solver solved 12–17 rounds; at 18 rounds CryptoMiniSat 1/3, CaDiCaL 2/3, Kissat 3/3; at 19 rounds none. Full 64 rounds with k unknown bits: all solved at k ≤ 12; at k = 16 Kissat 1/3, the others 0/3; at k = 20 none. Interpretation for the annex: at full rounds the solvers do no better than trying the 2^k candidates would (2^16 hash evaluations take well under a second). Still to do: look at the figure once, then fill `docs/checkpoint-2.md` §5 and `CLAIMS.md` C13.

## Next steps

1. **SAT write-up:** view `results/fig_sat_scaling.png`, then update `docs/checkpoint-2.md` §5 and `CLAIMS.md` C13 with the results recorded above.
2. **Finish the secret scan** (command above), then:
   - Add an optional Certora job to `.github/workflows/ci.yml` that runs only when `secrets.CERTORAKEY` is set, and tell the author to add the secret.
   - `gh repo create crypto-assumptions-fmi-blockchain --private --source . --push`, then `gh run watch` or `gh run list`. Fix CI failures.
3. **Medusa, one retry:** set `"platformConfig": {"target": ".", "args": ["--foundry-out-directory", "out", "--compile-force-framework", "foundry"]}` in `audit/medusa.json`, or try `medusa init` then edit. If it fails, leave `audit/reports/medusa.txt` as is.
4. **Daml/Canton model** (budget cap about 10% of the remainder):
   - New directory `daml/`, using `dpm` (Daml SDK 3.7.1; there is no `daml` command).
   - Templates: `Holding` (signatory issuer, observer owner), a freeze or lock through an issuer-controlled choice, `DvP` proposal and accept, and archive powers.
   - A short note on how package upgrades are authorised (smart-contract upgrade requires the signatories' vetting of the new package; verify against current Daml docs).
   - Daml Script tests. Skip and say so if it is expensive.
5. **Close primary-source gaps** with at most two reading agents, limited to what the annex and article cite. Targets:
   - PFMI principles 2, 8, 15 and 17, and the 2016 cyber-resilience guidance
   - DORA (articles on ICT risk and cryptography; the risk-management RTS)
   - The EU PQC roadmap text
   - BIS Project Leap phase 2 report
   - CNSA 2.0
   - NIST IR 8547, final table on security strengths
   - FBI Binance alert (for the annex only)
   - The lattice ETH-lower-bound papers (for CLAIMS A6)
   - TRM Labs H1 2026 (already V)
   Record each in `research/primary/` and update `CLAIMS.md` labels.
6. **Technical annex**, Phase 4: `report/annex.md` plus PDF through pandoc and Tectonic, 15–30 pages.
   - Figures from `results/`; each equation introduced in words.
   - Sections: re-verification of the October results; RQ1 cryptography; powers (spine); PQ cost (second pillar); incidents (TRM figures; the repo list as illustrative only); AI capability; institutional CBOM; regulation; build, tests and verification; SAT; migration model; threat model; limitations.
   - North Korea attribution only as "reported".
7. **Write `docs/HANDOFF.md` and STOP.** Do not start the article: it is reserved for Fable on 20 November.

## Verify first

- `git status --short` should be clean apart from this file's commit; `cd contracts && forge test | tail -1` should report 61 passed.
- `git diff --stat contracts/src` should be empty (the mutation script edits sources in place; restore with `git checkout -- contracts/src`).
- Several claims in `CLAIMS.md` are still R or U (section D21, B7, B8, B16, D15, D16, D20). None may enter the article as plain fact.

## Open questions for the author

- None outstanding beyond the decisions above. The Chapter 3 topic proposal is due in the final author brief.

## External actions awaiting approval

- **Approved:** create a *private* repository `crypto-assumptions-fmi-blockchain` and push, after the secret scan passes. Never make it public.
- **Author to do:** add the GitHub secret `CERTORAKEY` if a Certora CI job is added.
- **Not approved:** publishing the article, or making the repository public.

## Key files

- `docs/checkpoint-2.md` — results and the decisions put to the author
- `CLAIMS.md` — evidence label for every claim; the article may use only V
- `LIMITATIONS.md` — what the work does not show
- `audit/report.md` — internal audit, findings M-1 to I-3
- `docs/threat-model.md` — powers table, attack trees, risk register
- `docs/demos.md` — failure-mode demonstrations
- `results/` — every figure and table (gas, incidents, CBOM heat map, migration, SAT)
- `research/primary/` — primary-source notes with URL, date and label
- `Makefile` — `make quick`, `make all`, `make pq-fixtures`, `make certora`, `make mutation`

## Environment notes

- Halmos needs `FOUNDRY_DYNAMIC_TEST_LINKING=false`.
- Coverage needs `forge coverage --ir-minimum`.
- Echidna needs the same environment variable; its config is `audit/echidna.yaml`.
- Medusa 1.5.1 failed: "FuzzHarness ... not found in the compilation artifacts".
- ML-DSA fixtures: `make pq-fixtures`. This needs `tools/.venv-pq`, created with `make pq-venv`.
- There is no Docker in WSL.
- The Daml SDK is reached through `dpm`; Java 21 is the default.
- Semgrep rules are cloned in the scratchpad (`semgrep-sc`), which is ephemeral; re-clone `Decurity/semgrep-smart-contracts` if needed.
- Git identity is repository-local, using the author's GitHub no-reply address.
