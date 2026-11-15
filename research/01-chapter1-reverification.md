# Re-verification of the October 2026 results (as of 15 November 2026)

Labels: **V** verified (primary source read), **R** reported (secondary), **I** inferred, **U** unknown.

## Primary sources read

| # | Source | Accessed | What it establishes |
|---|---|---|---|
| S1 | OpenAI, `github.com/openai/math`, `preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026/` (README.md, paper.pdf listed) | 2026-11-15 via GitHub API | Preprint titled "The Exponential Time Hypothesis is False", author "OpenAI", dated 25 October 2026. Single commit touching the folder, 26 October 2026 20:35 UTC. No later revision. |
| S2 | OpenAI, `lean/docs/378.md` in the same repository | 2026-11-15 | Scope of the Lean formalisation (quoted in substance below). Single commit, 26 October 2026. |
| S3 | Anthropic, "A 2^{o(n)} Time Algorithm for 3-SAT", hexagonmath.org/2610.00577v1 | 2026-11-15 | Version 1, 27 October 2026, only version. Deterministic 2^{o(n)} algorithm for 3-SAT, also solving #3-SAT; "formalized in Lean 4"; core algorithm attributed to an internal Claude model; page labels the text primarily AI-generated. No errata. |
| S4 | Chapter 1 as published (`docs/chapter-1.md`) | 2026-11-15 | The text Chapter 2 must be consistent with. |

## Findings

1. **V — Bounds.** The Lean file proves, for fixed k ≥ 2, deterministic exact counting of satisfying assignments of a canonically encoded k-CNF in time (L+1)^{O_k(1)} · 2^{O_k(n (log log n)² / √log n)}, L the encoding length, with polynomially many tape cells visited. The manuscript claims the sharper (n+m)^{O_k(1)} · 2^{O_k(n log log n / √log n)}, improving to 2^{O(n/√log n)} when m ≤ Dn. (S2)
2. **V — Correction to the Chapter 2 brief.** The brief's §2 summary writes the exponent as "n log log n / log n". The primary source and the published Chapter 1 both have **√log n** in the denominator. Chapter 1 is right; the brief's summary has a slip. Chapter 2 and the annex use the √log n form.
3. **V — No revision or erratum** has been posted to either primary source since first publication (S1–S3). The OpenAI repository has issues disabled, so no public defect reports can exist there.
4. **R — Independent review is under way and not concluded.** Scientific American (27 Oct 2026) reports that OpenAI engaged Russell Impagliazzo and Ramamohan Paturi (UC San Diego) and Ryan Williams (MIT) to examine the result, and will sponsor a conference on the proof. Several secondary outlets report that the reviewers say their involvement is not certification. No published confirmation and no published refutation found as of today.
5. **R — Lean status.** Secondary coverage says both Lean developments type-check, and that Anthropic's notes concede that no machine checks whether its Lean statement matches the informal theorem. Not yet read in a primary Anthropic document: label stays R.
6. **R — Practical irrelevance per the authors.** Secondary coverage attributes to Anthropic the statement that for 3-SAT with five clauses per variable its method would not beat brute force below about 10^10,000 variables. To be confirmed in the paper PDF before use in the article.
7. **R — One outlet says Anthropic's paper also refutes SETH.** Trivially true if ETH is refuted (SETH implies ETH, so ¬ETH implies ¬SETH); no separate claim needed.
8. **U — Cryptographers' published assessment** of implications for local PRGs / fine-grained cryptography: none found yet. The annex will reason from the literature (label I) rather than cite commentary that does not exist.

## Consequence for Chapter 2

Status unchanged since Chapter 1: **claimed, machine-checked in part, not independently confirmed, not refuted**. Chapter 2's first section should say exactly that, in one sentence, and proceed on the conditional "if the results stand".

## Secondary sources

- Scientific American, "Dueling proofs from OpenAI and Anthropic astound scientists", 27 Oct 2026: https://www.scientificamerican.com/article/dueling-proofs-from-openai-and-anthropic-astound-scientists/
- Washington Times, 27 Oct 2026: https://www.washingtontimes.com/news/2026/oct/27/openai-says-model-refuted-exponential-time-hypothesis/
- OpenAI announcement (returned HTTP 403 to automated fetch; not read): https://openai.com/index/building-scientific-understanding-with-academic-communities/
