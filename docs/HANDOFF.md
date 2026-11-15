# Handoff — Chapter 2 run

## Updated

15 November 2026, afternoon. Model for this session: Opus 5.5. **Stopped as instructed after the annex.** The article and the adversarial review are reserved for **Fable, after its limit resets on 20 November 2026**.

## Mission and where we are

Chapter 2 of the author's series on cryptography and financial stability. Deliverables:
- a reproducible repository;
- a technical annex;
- a Substack article (1,400–1,800 words; at most one displayed equation; only claims verified at source).

The full brief is in the first session. Its essentials are in `docs/checkpoint-1.md`, `docs/checkpoint-2.md` and the rules below.

**Done:** Phases 0–4. Repository, tests and verification; Checkpoints 1 and 2 answered; technical annex written (`report/annex.md`, `report/annex.pdf`, 18 pages).

**Next:** Phase 5 (article draft), then Phase 6 (adversarial review, step-size audit, Checkpoint 3).

## Author decisions (binding)

Checkpoint 1 (15 Nov 2026):
- Any claim used in the article must be V (primary source read) before Checkpoint 3.
- Keep both "valid signature, wrong instruction" demonstrations: Binance pattern (EIP-7702) and Bybit pattern (smaller).
- Sub-agents: at most 2–3, only for reading primary sources. Be economical (Pro plan).
- Include one bridging paragraph from exchange to FMIs and tokenised deposits: "an exchange is not an FMI".
- Develop the freeze-key point fully: immutability is a governance property of each asset; say who holds freeze, upgrade and signer-policy powers on each institutional ledger.
- Gambit for mutation; Kontrol skipped; GitHub Actions for the container check.
- Keep the repository private.

Checkpoint 2 (15 Nov 2026), author's words where possible:
1. Push to a **private** GitHub repo `crypto-assumptions-fmi-blockchain` and run CI, after a secret scan. Do not put Certora in CI unless it reads CERTORAKEY from a GitHub secret; the author adds the secret himself. **Never print the key.**
2. **Hook: Binance, based on Binance's own 3 November report. Leave the North Korea attribution out of the article.** The annex may keep it as "reported".
3. Close primary-source gaps with at most two reading agents, limited to what the annex and article cite.
4. **Spine of the article: "who holds the powers" (signer policy, upgrade, freeze, registrar). Second pillar: the post-quantum cost result.**
5. **Do not use the 79%/59% figures from the twelve-case list in the article.** Use TRM Labs' industry figures with the source, or state it qualitatively. **Write "not found in public material", never "does not exist".**
6. Add a minimal Daml/Canton powers model. Done.
7. Try Medusa once more with crytic-compile's Foundry settings; if it fails, leave it disclosed. Done: it failed again and is disclosed.
8. "After the annex, write docs/HANDOFF.md and stop. I want the article and the adversarial review done with Fable after its limit resets on 20 November."

The same rules are in Claude memory (`chapter2-working-rules`).

## Done

| Item | Proof |
|---|---|
| Secret scan before push | CERTORAKEY: 0 occurrences in `git log --all -p` (never printed). Pattern scan for private keys and tokens: no matches (only the scan command itself, quoted in an earlier handoff). Hex constants are public storage slots and curve orders. Ignored: `.certora_internal/`, `.serena/`, `tools/.venv-pq/` |
| Private repository and CI | https://github.com/HiCarC/crypto-assumptions-fmi-blockchain (PRIVATE). First CI run `43721599058` on `2c167c1`: contracts, soroban, analysis (container) and certora all *success*. The certora job only skips itself until the secret exists |
| SAT experiment | `results/sat_scaling.csv`, `fig_sat_scaling.png`; `docs/checkpoint-2.md` §5; CLAIMS C13 |
| Medusa third attempt | `audit/reports/medusa.txt` (failed; crytic-compile exports the harness, so the fault is in Medusa's loader) |
| Daml powers model | `daml/` (`dpm build && dpm test`: 6 tests plus the setup script reported as 7), `daml/README.md` |
| Primary sources, round 2 | `research/primary/regulation.md` (PFMI, cyber guidance, DORA and RTS, EU roadmap, NIST IR 8547, Project Leap all V; CNSA 2.0 R); `research/primary/technical.md` (lattice bounds, Daml upgrades and authorisation, Frozen Heart, SNARK SoK, EIP-7702 all V; Ronin and Nomad R) |
| Claims ledger updated | `CLAIMS.md` sections A–E (A6, D5, D21–D24, E1–E6, C12–C13, C16) |
| Technical annex | `report/annex.md` (6,479 words), `report/annex.pdf` (18 pages; built with pandoc and Tectonic, command below) |

## In progress

Nothing. All work is committed and pushed.

## Next steps (for the Fable session from 20 November)

1. **Read first, in this order:**
   - `docs/HANDOFF.md`
   - `report/annex.md`
   - `CLAIMS.md`
   - `docs/chapter-1.md` (for voice and continuity)
   - the article specification (brief §10–§11, summarised below)
2. **Phase 5: write the draft as `article/draft.md`.**
   - English, British spelling; 1,400–1,800 words.
   - Zero displayed equations by default, at most one.
   - Persona: Head of FMI Oversight at a euro-area NCB. One inferential step per paragraph.
   - Use "authorities", never name "supervisors".
   - Required elements:
     - 3 headline options and 3 subtitle options (announce Chapter 3);
     - a TL;DR of 3–4 sentences;
     - the hook: Binance from its own report, with no attribution;
     - a 2–3 sentence bridge to Chapter 1;
     - the answer to the promise, in order: (a) the October result does not change blockchain cryptography; (b) the four powers; (c) where losses happen, using TRM figures; (d) AI capability; (e) institutional ledgers, using "not found in public material";
     - the bridging paragraph from exchange to FMI;
     - the PQ cost as the second pillar;
     - one or two figures from `results/` (candidates: `fig_gas.png`, `fig_powers_heatmap.png`), with alt text and modest captions;
     - "What authorities should ask": 5–7 questions mapped to the four powers;
     - "What to do now": 3–5 sequenced actions tied to DORA RTS Arts 6–7, PFMI P2/P8/P17, the EU roadmap and NIST IR 8547;
     - a closing line in the spirit of Chapter 1's test;
     - 6–12 primary-source links;
     - the signature block;
     - SEO title, meta description, slug, tags.
   - **Use only V claims.**
3. **Phase 6:**
   - the six adversarial reviews (cryptographer, FMI overseer, G-SIB CISO, smart-contract auditor, sceptical economist, the Chapter 1 reviewer);
   - the step-size audit table;
   - a claims check against `CLAIMS.md`;
   - a British-spelling proofread;
   - a number check (each number traced to `results/` or `CLAIMS.md`).
   Then produce `article/final.md` and `docs/author-brief.md`, which must include:
   - the thesis in 3 sentences, and how the evidence changed it;
   - the step-size table;
   - the review log;
   - open questions;
   - the Chapter 3 proposal;
   - the external actions awaiting approval.
   **Checkpoint 3: stop for the author.**
4. Candidate Chapter 3 topics for the brief: post-quantum migration of payment systems (building on Project Leap and the cost result), or AI as an attacker of financial infrastructure.

## Verify first

- `git status --short` (expect clean); `git log --oneline -1`; `gh run list --limit 1` (expect success for the latest push).
- `cd contracts && forge test | tail -1` (expect 61 passed).
- Claims still **R/U** and therefore barred from the article as fact:
  - B7, the FBI attribution (also excluded by the author's decision);
  - B8, which issuers froze funds;
  - B9, "largest on record": Chainalysis wording only. Phrase carefully, or say "the largest reported theft of digital assets".
  - B11, the Bybit cause;
  - B16 (Ronin, Nomad and others), D15 (rollup powers), D16 (Swift), D20 (EVMbench), D24 (CNSA 2.0, MiCA/DLT Pilot), E6.
- The Frozen Heart mechanism wording ("public values omitted from the transcript hash") was **not** confirmed at source. Describe it only as "insecure Fiat–Shamir implementations".
- NIST IR 8547's strength column was decoded by inference. The text-level statement (all quantum-vulnerable signatures deprecated after 2030 and disallowed after 2035) is V.

## Open questions for the author

- Add the GitHub secret `CERTORAKEY` (Settings → Secrets → Actions) if Certora should run in CI. The job already exists and skips itself until then.
- Chapter 3 topic (to be proposed in the author brief).

## External actions awaiting approval

- **Not approved:** making the repository public; publishing the article or annex.
- The repository is private on GitHub. Pushes to it are within the Checkpoint 2 approval.

## Key files

- `report/annex.md` and `report/annex.pdf` — the technical annex
- `CLAIMS.md` — evidence label per claim; the article may use only V
- `LIMITATIONS.md` — what the work does not show
- `docs/checkpoint-2.md` — results and decisions
- `results/` — every figure and table
- `audit/report.md`, `docs/threat-model.md`, `docs/demos.md`
- `research/primary/*.md` — source notes with URL, date and label
- `daml/`, `soroban/`, `contracts/`, `sat/`, `cbom/`

## Environment notes

- Annex PDF: `cd report && pandoc annex.md -o annex.pdf --pdf-engine=tectonic --resource-path=.:.. -V geometry:margin=2.3cm -V fontsize=10.5pt -V colorlinks=true --toc --toc-depth=1 -V mainfont="DejaVu Serif"`. `pdfinfo` is not installed; count pages by decompressing object streams with Python.
- Halmos and Echidna need `FOUNDRY_DYNAMIC_TEST_LINKING=false`. Coverage needs `--ir-minimum`.
- Medusa 1.5.1 cannot load this project's artefacts.
- The Daml SDK is reached through `dpm` (3.7.1); there is no `daml` command.
- ML-DSA fixtures: `make pq-fixtures` (needs `make pq-venv`).
- `tools/mutation.sh` edits sources in place; if interrupted, run `git checkout -- contracts/src`.
- Git identity is repository-local, using the author's GitHub no-reply address. Commit trailer: "Co-Authored-By: Claude Opus 5.5" for this session; use the current model's trailer next time.
