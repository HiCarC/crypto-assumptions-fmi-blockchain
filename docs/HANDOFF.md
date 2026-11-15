# Handoff — Chapter 2 run

Updated 15 November 2026. **State: at Checkpoint 2, waiting for the author.** Report: `docs/checkpoint-2.md`. Nothing has been pushed; repository is local only. Model switched to Opus 5.5 by the author mid-run; commit attribution now "Claude Opus 5.5".

## Author's standing decisions

- Any claim in the article must be V (primary source read) before Checkpoint 3.
- Sub-agents: at most 2–3, only for reading primary sources. Be economical (Pro plan).
- Binance may be the hook only if confirmed from Binance's own post-mortem or an official attribution. It is confirmed from Binance's 3 Nov report; the FBI attribution is still R.
- Add one bridging paragraph from exchange to FMIs and tokenised deposits.
- Develop the freeze-key point: who holds freeze, upgrade and signer-policy powers on each institutional ledger.
- Kontrol skipped. Docker unavailable: rely on GitHub Actions.
- Keep the repository private; no push until the author answers Checkpoint 2.

## Verify first when resuming

```bash
cd ~/work/crypto-assumptions-fmi-blockchain
git status --short && git log --oneline | head -5
cd contracts && forge test | tail -1          # expect 61 passed
```

## Done (see docs/checkpoint-2.md for results)

Components A–G, Soroban second ecosystem, audit report (`audit/report.md`), threat model, CLAIMS, LIMITATIONS, README, Makefile, CI workflow, licence and citation. Mutation testing complete and triaged. SAT experiment: started in background (`results/sat_run.log`); if it has finished, run `cd sat && ~/.venvs/research/bin/python plot.py`, then fill section 5 of `docs/checkpoint-2.md` and CLAIMS C13.

## Next steps (after the author's answers)

1. If approved: create a **private** GitHub repo with `gh repo create --private`, push, and read the CI result.
2. Close primary-source gaps listed in checkpoint-2 §4 (max two reading agents).
3. Phase 4: technical annex `report/annex.md` + PDF (15–30 pages; figures from `results/`).
4. Phase 5: article draft `article/draft.md` (1,400–1,800 words, 0–1 equations, only V claims).
5. Phase 6: six adversarial reviews, step-size audit, claims check, proofread, number check; `docs/author-brief.md`; Checkpoint 3.

## Gotchas

- Halmos needs `FOUNDRY_DYNAMIC_TEST_LINKING=false`.
- Coverage needs `--ir-minimum`.
- ML-DSA fixtures must be regenerated (`make pq-fixtures`) whenever contract deployment order changes addresses; the PQ tests fail with "stale ML-DSA fixture" otherwise.
- `tools/mutation.sh` mutates sources in place and restores them; if interrupted, run `git checkout -- contracts/src`.
