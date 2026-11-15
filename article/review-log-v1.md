# Adversarial review log — Chapter 2 article

Draft reviewed: `article/draft.md` (15 November 2026). Each reviewer's objections were written down before any revision. Resolutions are applied in `article/final.md`. "CLAIMS" refers to `CLAIMS.md`.

## 1. Applied cryptographer (MIT/IACR standard)

| # | Objection | Resolution |
|---|---|---|
| 1.1 | "The signatures, hash functions and zero-knowledge proofs … do not rest on that hardness" is stated as fact, but CLAIMS A5 is an inference. | Reworded as the author's reading of the published security analyses ("As I read…"). The supporting evidence (A6, E1, E2) is in the annex. |
| 1.2 | "Large quantum computers would break the signature schemes" is imprecise: it needs a sufficiently large, error-corrected machine running Shor's algorithm, and it applies to elliptic-curve and RSA signatures, not to hash-based ones. | Now "a sufficiently large, error-corrected quantum computer would break the elliptic-curve signatures that ledgers use today". |
| 1.3 | "ML-DSA, the new NIST standard": NIST published three post-quantum standards in 2024. | Now "one of NIST's new post-quantum signature standards". |
| 1.4 | The SAT paragraph risks being read as evidence that SHA-256 is secure. | The existing caveat ("a statement about today's tools") is kept, and "and one way of writing the problem" is added. |
| 1.5 | "Every signature was valid" — whose assessment? | Supported by Chainalysis ("valid signed authorizations", V) and by Binance's description of the signing service being used. Kept. |

## 2. Head of FMI oversight at a euro-area NCB (primary persona)

| # | Objection | Resolution |
|---|---|---|
| 2.1 | "Hot wallet", "gas", "contract code", "DLT" and "multi-party key stores" are not defined. | Each is defined in one clause at first use, or replaced. |
| 2.2 | The paragraph on cost ("The cost is not fixed…") makes three steps: native verifier, governance, Project Leap. | Split into two paragraphs. |
| 2.3 | "Two further limits appeared" makes two separate points. | Split into two paragraphs. |
| 2.4 | The closing frameworks paragraph makes three steps (PFMI silence, DORA wording, the gap). | Split: first the PFMI and DORA facts, then the gap. |
| 2.5 | "Leave about five years" — from November 2026 to end-2030 is about four. | Corrected to "about four years". |
| 2.6 | Can I act on Monday? The questions are answerable, but action 2 does not say what a good signer policy looks like. | Action 2 now names the control: signing systems accept only request types they understand, with limits. |

## 3. G-SIB CISO

| # | Objection | Resolution |
|---|---|---|
| 3.1 | "At Binance, the system checked who was asking, not what it was being asked to sign" goes beyond what Binance published. | Removed as a statement about Binance. The point is now made through our own reconstruction (CLAIMS C7, V), labelled as such. |
| 3.2 | "Binance's signing policy, on its own account, was not ready for it" — Binance's report does not say this; it came from third-party analysis. | Removed. The article now says only that the attacker used the authorisation type added in May 2025 (V). |
| 3.3 | "Handing control of a hot wallet" overstates Binance's "partial execution rights". | Now "giving code chosen by the attacker the right to act on a hot wallet". |
| 3.4 | The registrar point needs a control, not only a warning. | Covered by question 4 and the annex; no change in the article, for length. |

## 4. Smart-contract auditor

| # | Objection | Resolution |
|---|---|---|
| 4.1 | The thousandfold figure comes from one experimental, unaudited verifier; its authors report an optimised version about seven times cheaper. | Sentence added: "its authors report an experimental version about seven times cheaper", read from the project's own README. The caption already states the implementation is experimental. |
| 4.2 | "In our reference contracts" should make clear that this is a research build, not a production system. | The annex and repository links carry this; the caption says so. Kept. |
| 4.3 | The incident sentence "none came from a broken cryptographic primitive" relies partly on root causes that are only reported (Ronin, Wormhole, Nomad, Bybit). | Reworded to "we found none" and flagged in the author brief as a qualitative statement partly resting on reported sources. |

## 5. Sceptical journalist or economist

| # | Objection | Resolution |
|---|---|---|
| 5.1 | Strongest counter-argument: regulated FMIs on permissioned ledgers, with HSMs and four-eyes controls, are not exchanges. Using Binance is alarmist. | Added: a well-run FMI will have stronger controls than an exchange. The point is that the same four questions apply, and on a shared ledger some answers sit outside the institution. |
| 5.2 | Comparing "affected" (Binance) with "stolen" (Bybit) mixes measures. | Now "more than four times the US$1.5 billion taken from Bybit". Both are gross amounts as reported; noted in the annex. |
| 5.3 | "47 of 56 not found" could be read as an indictment. | Already qualified ("not evidence of weakness … have to be requested"). Kept. |
| 5.4 | "AI-assisted attacks now pass the test" overstates benchmark results; other studies find weaker real-world performance. | Now "comes much closer, at least in benchmarks". |
| 5.5 | "Freezes … were possible only because some assets have issuers…" is an inference about a specific case. | Reworded as a general statement: freezes are possible only where some party holds a freeze power. |

## 6. The senior expert who reviewed Chapter 1

| # | Objection | Resolution |
|---|---|---|
| 6.1 | Formula count. | Zero displayed equations; no inline symbols beyond figures in US$ and percentages. |
| 6.2 | Step size: see the audit in `docs/author-brief.md`. Three paragraphs had two or three steps (2.2–2.4). | Split. No remaining paragraph is rated "large". |
| 6.3 | The jump from "the mathematics holds" to "four powers" needs one sentence of bridge. | "The short answer…" paragraph in the Chapter 1 section provides it; kept. |
| 6.4 | Typos and terminology. | Proofread for British spelling (authorisation, tokenised, programme), consistent "post-quantum", "signer policy", "freeze". |

## Claims check

Every factual sentence in `article/final.md` was traced to a V claim, an explicitly marked inference, or the repository's own measurements. The trace table is in `docs/author-brief.md` §4.

## Number check

| Number in the article | Source |
|---|---|
| US$6.3 billion (Binance) | CLAIMS B1 (Binance report: about US$6.34 billion) |
| US$1.5 billion (Bybit), "more than four times" | B10 (FBI PSA); 6.34 / 1.5 = 4.2 |
| US$2.85 billion frozen or intercepted | B5 |
| May 2025 (EIP-7702) | E3 |
| 18 and 19 of 64 rounds; a dozen bits; up to a minute | C13; `results/sat_summary.csv` (12 bits: median up to 48.7 s) |
| 207 hacks, about US$972 million, 15% / 76% | B13 (TRM Labs) |
| 207 of 405; 2,849 contracts; two flaws; US$3,476 | D19 |
| 27 platforms; 14; 47 of 56 | C15; `results/cbom_summary.json` |
| after 2030 / after 2035 (NIST); end of 2030 (EU) | D1, D5 |
| about a thousand times; 37 times larger | C1 (8,146,057 / 7,955 = 1,024); C2 (2,420 / 65 = 37.2) |
| almost twenty times cheaper | C1 (237,278 / 12,712 = 18.7) |
| about seven times cheaper (optimised variant) | ETHDILITHIUM README: 1,196,707 vs 8.1 million measured = 6.8 |
| at least ten times slower (Project Leap) | D23 ("at least an order of magnitude") |
| about four years | November 2026 to end-2030 |
