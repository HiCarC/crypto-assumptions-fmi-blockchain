# Checkpoint 1 — report to the author

15 November 2026. Phases 0 and 1. Supporting files: `docs/environment.md`, `docs/chapter-1.md`, `research/01-chapter1-reverification.md`, `research/02-findings-rq1-rq6.md`, `research/claims-ledger.md`.

## Where the evidence stands

Phase 1 located sources for all six research questions and read the primary sources for the October results. Most other claims are still labelled "reported": the secondary source is identified, the primary has not yet been read. That reading is scheduled with the annex, and none of those claims will reach the article as plain fact before then.

## Key findings

1. **The October results are unchanged since Chapter 1.** Neither paper has been revised or withdrawn. Review by Impagliazzo, Paturi and Williams is reported as under way, with no confirmation and no refutation published. Chapter 2 can proceed on "if the results stand".
2. **No deployed blockchain primitive rests on ETH or SETH.** Elliptic curves, pairings, hashes and zero-knowledge soundness depend on other assumptions. Constructions that do rest on fine-grained hardness exist only in research; no production use was found. One nuance for the annex: some lattice hardness lower bounds are proved under ETH-type hypotheses, so a supporting argument weakens there without any attack appearing.
3. **Losses come from operations, not mathematics.** No incident found in which a standard primitive was broken. The one 2026 loss rooted in cryptographic code (THORChain, about $11m, a threshold-signature implementation flaw) is small.
4. **AI-assisted exploitation passes the Chapter 1 test; the ETH result does not.** Published benchmarks show agents exploiting real contract vulnerabilities at stated cost. Counter-evidence exists (weak performance on real incidents) and will be shown alongside.
5. **Institutional tokenisation is converging on two stacks**, Canton and EVM (permissioned Besu or public Base), both entirely classical in their signatures. None of the institutional platforms examined has a published post-quantum roadmap that I could find; the public chains (Ethereum, Stellar, Bitcoin proposals) have more public planning than the bank networks.

## Surprises

- **The Binance theft of 29 October 2026 (about $6.3–6.4bn) happened between the October papers and Chapter 1's publication, and it is now the largest on record.** Reported facts: no private key leaked; the attackers reached the internal signing service through compromised engineer devices; the service issued valid signatures. This replaces Bybit as the natural hook.
- **A protocol upgrade changed what a signature could authorise.** The attacker reportedly used a transaction type added to Ethereum in May 2025 that lets a wallet delegate to arbitrary code, and the signing policy had not been updated for it. This is the agility problem in reverse: the ledger changed and the institution's controls did not follow.
- **"Cannot be rolled back" is too strong.** Stablecoin issuers froze roughly $2.2–2.85bn of the proceeds within about an hour. Permanence depends on who holds a freeze key over the asset, which matters directly for tokenised deposits.
- **Secondary accounts say an internal AI tool was abused inside Binance** during the intrusion. I have not confirmed this in Binance's own text and will not use it until I have.
- **NIST IR 8547 is reported final as of 27 October 2026**, with deprecation after 2030 extended to all approved strengths. To be confirmed at NIST.
- **A slip in the brief:** §2 gives the OpenAI exponent with "log n" in the denominator. The source and the published Chapter 1 have "√log n". Chapter 1 is correct.

## Effect on the planned thesis

The planned thesis survives and sharpens. Proposed wording: *the mathematics held and the signatures were valid; the questions that matter are who can instruct the signer, who can change the ledger's rules, and who can freeze the asset.* Two adjustments to the brief follow:

- RQ2 should treat immutability as a governance property of each asset, not of blockchains in general.
- The Bybit-style demonstration (Component D3) should be joined or replaced by a Binance-style one: a signer that accepts a delegation authorisation its policy never anticipated. It is the most current failure mode and can be reproduced locally with contracts I write.

## Gaps

Not yet researched to source: Fnality, Partior, Citi and D7 technical detail; Hedera, XRP Ledger, Solana, Polygon, Avalanche; Bank of England, MAS, Federal Reserve; digital euro design; current DORA, MiCA and DLT Pilot Regime texts. The OpenAI announcement page refused automated access; the repository was read instead. The Wintermute/Profanity attribution was not confirmed by the sources read so far.

## Decisions needed

1. Go-ahead for Phase 2 (the build), or a pause to close the gaps first. My recommendation is to proceed and close the gaps while writing the annex.
2. Whether to add the Binance-style delegation demonstration to Component D.
3. Whether research may be run in parallel with sub-agents. It is faster and costs more; so far everything was done in a single session.
