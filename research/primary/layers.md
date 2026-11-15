# Primary-source check: cryptographic layers vs. a faster SAT algorithm

Checked 15 November 2026. Labels: V = primary source read by me; R = secondary source or search-result excerpt only; U = not found / could not open. Quotes are at most 25 words. "Ω" etc. may be garbled in the PDF text extraction; formulas are paraphrased where the glyphs were lost.

## 1. OpenAI preprint, "The Exponential Time Hypothesis is False" — V (PDF read)

- URL: https://github.com/openai/math/blob/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026/paper.pdf (text extracted from the raw PDF at raw.githubusercontent.com/openai/math/main/preprints/.../paper.pdf; WebFetch alone returned only GitHub chrome).
- Date: file name and title page give the version of 25 October 2026. A secondary report (R) says the first version was dated 17 October. OpenAI community thread (R): https://community.openai.com/t/the-exponential-time-hypothesis-is-false/1410073 (27 Oct 2026). Status: preprint, not peer reviewed; external verification still pending in the sources I saw.
- Main claim (abstract): a deterministic algorithm that counts the satisfying assignments of any k-CNF in polynomial space and time (n+m)^O_k(1) * 2^(n / (log n)^(1/2 + o(1))); "refutes the Exponential Time Hypothesis".
- Locality/inversion: the Introduction points to Appendix C.2, "algorithms for inversion and exact preimage counting of Boolean maps with constant output locality". Corollary C.2 (Appendix C): for fixed locality d, the preimage count |G^-1(b)| is computed exactly and a preimage found, in deterministic time (n+m)^O_d(1) * 2^o(n) and polynomial space. The proof encodes each forbidden local assignment as one width-d clause and applies the main theorem with k = max{2,d}.
- Cryptography statement (page 53, end of Appendix C): "the corollary applies to constant-locality versions of Goldreich's candidate one-way functions" [Gol00]; for polynomially many output bits it gives a 2^o(n)-time inversion for every output in the image, "ruling out 2^Ω(n) inversion hardness for these families". Following sentence: "This does not rule out one-wayness against polynomial-time algorithms."
- The word "crypt" does not occur in the PDF text (0 hits). No mention of pseudorandom generators, SHA, or hashing (0 hits for "pseudorandom", "hash"). The only crypto discussion is the Goldreich remark above.
- Caveat: the sub-exponential bound is only barely below 2^n (the saving is n / sqrt(log n) in the exponent); no concrete running times are given in what I read.

## 2. Goldreich's candidate one-way function — V (abstract page)

- Oded Goldreich, "Candidate One-Way Functions Based on Expander Graphs", ECCC TR00-090, submitted 3 Dec 2000 (published 4 Dec 2000). URL: https://eccc.weizmann.ac.il/report/2000/090/
- Finding: input bits are grouped into small overlapping subsets defined by an expander-like graph, and one fixed predicate is applied to each subset; the output is the list of these local evaluations. Hardness of inversion is conjectured, not derived from a standard assumption (the author poses it as an open problem).
- 2011 book chapter version (Springer, LNCS 6650, doi 10.1007/978-3-642-22670-0_10): not opened (Springer redirect to login) — U for the chapter; the ECCC report is the V source.

## 3. Jain–Lin–Sahai iO — V (abstract page)

- Aayush Jain, Huijia Lin, Amit Sahai, "Indistinguishability Obfuscation from Well-Founded Assumptions", IACR ePrint 2020/1003 (received 19 Aug 2020, revised 12 Nov 2020); STOC 2021 (venue from my own knowledge, not shown on the page I read, so R for the venue). URL: https://eprint.iacr.org/2020/1003
- Finding: iO from subexponential hardness of four assumptions: LWE, LPN over Z_p with a specified error rate, a Boolean pseudorandom generator in NC^0 with stretch n^(1+tau), and SXDH on asymmetric bilinear groups. So an NC^0 PRG (constant locality) is one of the four assumptions. The abstract does not use the words "constant locality".

## 4. Reduced-round SHA-256 preimage attacks

- Aoki, Guo, Matusiewicz, Sasaki, Wang, "Preimages for Step-Reduced SHA-2", ASIACRYPT 2009, LNCS 5912, pp. 578-597. URL: https://link.springer.com/doi/10.1007/978-3-642-10366-7_34 (not opened: login redirect). Abstract figures obtained via search-result excerpt — R. Stated: preimage attacks on up to 43-step SHA-256 and 46-step SHA-512; pseudo-preimage 2^251.9 (SHA-256) and 2^509 (SHA-512); full preimage 2^254.9 and 2^511.5 compression-function operations. Excerpt quote: "preimage attacks on up to 43-step SHA-256 (around 67% of the total 64 steps)".
- Precursor: Guo and Matusiewicz, ePrint 2009/477, https://eprint.iacr.org/2009/477 — V (abstract page): 42-step SHA-256 at about 2^251.7 time, memory about 2^12 (the note says a merged version appears at ASIACRYPT 2009).
- Khovratovich, Rechberger, Savelieva, "Bicliques for Preimages: Attacks on Skein-512 and the SHA-2 family", FSE 2012 (ePrint 2011/286, https://eprint.iacr.org/2011/286, received 3 Jun 2011, revised 7 Feb 2012). The ePrint page I read (V) says the paper attacks SHA-2 for more rounds than earlier work but did not display the numbers. Via search excerpts (R): 45 of 64 rounds of SHA-256 and 50 of 80 rounds of SHA-512 in hash mode; Table 1 reportedly lists 2^255.5 for SHA-256 preimage (pseudo-preimage about 2^253). I could not open the PDF (403 at iacr.org archive; ePrint PDF fetch returned an error page). Treat 2^255.5 as R, verify before citing.
- Net: best published preimage attacks reach well under 64 steps and save only a few bits against 2^256, i.e. they are theoretical; full SHA-256 has no known preimage attack better than generic (not stated in a source I read; this is a negative claim, U).
- SAT-based SHA-256 preimage results:
  - Zaikin, "Preimage attacks on round-reduced MD5, SHA-1, and SHA-256 using parameterized SAT solver", preprint 2026 (venue not shown), https://olegzaikin.github.io/publications/2026-z-constraints-preprint.pdf — V (PDF text extracted). Abstract: in 2012, 28-step MD5, 23-round SHA-1 and 16-round SHA-256 compression functions were reduced to SAT and inverted, with no progress since; the paper inverts, for the first time, 29-step MD5, 24-round SHA-1 and 19-round SHA-256 compression functions. It states the SHA-256 result is "of practical interest in terms of security" in the sense that SHA-256 is still secure.
  - Nossum, master's thesis, Univ. of Oslo, Nov 2012, https://duo.uio.no/handle/10852/34912 — R (search snippets): the thesis is about SAT preimage attacks on SHA-1, not SHA-256. I found no SHA-256 content in it. Nejati et al.: not searched (U).

## 5. Morawiecki–Srebrny, reduced Keccak — partly V

- "A SAT-based preimage analysis of reduced KECCAK hash functions", ePrint 2010/285 (received 14 May 2010; presented at the Second SHA-3 Candidate Conference, Santa Barbara 2010), https://eprint.iacr.org/2010/285 — V (abstract page). Journal version: Information Processing Letters 113(10-11), 392-397, 2013, doi 10.1016/j.ipl.2013.03.004 — R (search metadata).
- Finding (V): CNF generated by their CryptLogVer toolkit, solved with PrecoSAT; preimages found for some reduced versions; full Keccak resists the attack.
- Rounds reached: the pages I could open do not give them. A secondary table (R, ehash.isec.tugraz.at Keccak page) lists 3 rounds with 40-bit message for the 1024-bit-hash variant. Round counts: R only; the PDF was not readable.

## 6. Tool documentation

- Certora Prover — V. https://docs.certora.com/en/latest/docs/user-guide/ ; quote: "Together with the contract under analysis, these rules are compiled to a logical formula" ... "which is then proved or disproved by an SMT solver." (the page's own wording is "compiled to a logical formula", not "translates"). Date: live documentation, undated.
- Halmos — V for the first part. https://github.com/a16z/halmos README: "Halmos is a _symbolic testing_ tool for EVM smart contracts." The README does not name SMT solvers or define symbolic execution. Solvers: R, from the a16z v0.3.0 release notes via search excerpt (https://a16zcrypto.com/posts/article/halmos-v0-3-0-release-highlights): `--solver` accepts cvc5, yices, z3; Yices is the default. Bitwuzla support: third-party listing only (U for an official source). "Symbolic execution with SMT solvers" as a combined statement was not read in a primary page.

## 7. Deployed signature and hash choices

- Ethereum PoS uses BLS12-381 — partly V. consensus-specs, phase0 beacon chain, https://github.com/ethereum/consensus-specs/blob/master/specs/phase0/beacon-chain.md : the BLSSignature type is "A BLS12-381 signature, a compressed point in the ``G2`` group." The visible portion did not include the attestation verification function (`bls.FastAggregateVerify`), so the link "validator attestations are BLS-signed" is not read directly from the spec by me: R/U for that exact claim. ethereum.org PoS page (https://ethereum.org/en/developers/docs/consensus-mechanisms/pos/) does not mention BLS (checked, negative).
- Bitcoin double SHA-256 — partly V. developer.bitcoin.org block chain reference, https://developer.bitcoin.org/reference/block_chain.html : headers are "hashed as part of Bitcoin's proof-of-work algorithm"; the table says the previous-block hash is "A SHA256(SHA256()) hash in internal byte order of the previous block's header." So double SHA-256 for header hashing is V; the page does not itself say the PoW target check uses it explicitly. Whitepaper https://bitcoin.org/bitcoin.pdf: PDF could not be text-extracted with my tools — U (it is expected to describe SHA-256 and hashcash; not verified).
- CometBFT Ed25519 — partly V. https://github.com/cometbft/cometbft/blob/main/docs/core/using-cometbft.md : sample genesis sets validator `pub_key_types` to ["ed25519"] and the sample key file uses "tendermint/PubKeyEd25519". The page does not say "default" in words. docs.cometbft.com pages redirected to docs.cosmos.network, which did not mention it. Label: V for sample configuration, R for the word "default".

## 8. SETH implies ETH — R

- Wikipedia, https://en.wikipedia.org/wiki/Exponential_time_hypothesis : defines SETH as the conjecture s_inf = 1 and states that if s_k > 0 for some k > 0 then s_3 > 0, so ETH holds (the page gives no single sentence "SETH implies ETH"; the implication follows). Sparsification is credited to Impagliazzo, Paturi, Zane, "Which problems have strongly exponential complexity?", JCSS 63(4):512-530, 2001. The original "On the complexity of k-SAT" (JCSS 2001; conference version CCC 1999, pp. 237-240) was not opened: R only.

## Summary of labels

1. ETH-false preprint: V (PDF text read, sentences quoted; no PRG/hash claims in it).
2. Goldreich TR00-090: V (ECCC abstract page); 2011 chapter U.
3. Jain-Lin-Sahai: V (eprint abstract; NC^0 PRG listed as one of four assumptions); STOC venue R.
4. SHA-256 preimages: Guo-Matusiewicz 42 steps V; Aoki et al. 43 steps/2^254.9 R; KRS 45 rounds/2^255.5 R; Zaikin SAT 19 rounds V; Nossum thesis R (SHA-1 only).
5. Keccak SAT: V for method/outcome; rounds reached R (3 rounds, 40-bit).
6. Certora V; Halmos tool description V, solvers R.
7. Bitcoin double SHA-256 V (header table), whitepaper U; Ethereum BLS12-381 type V, attestation use R/U; CometBFT ed25519 V (sample config), "default" R.
8. SETH implies ETH: R (Wikipedia); original paper not opened.
