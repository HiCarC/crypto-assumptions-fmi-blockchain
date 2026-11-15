# SHA-256 literature check (primary sources), 15 Nov 2026

Labels: V = paper/abstract text read by me; R = secondary (search snippet or citing paper); U = could not read.
Reading notes: eprint.iacr.org PDFs, springer.com and iacr.org/archive returned 403/redirect to WebFetch. I read abstract pages (eprint HTML), and extracted text from PDFs fetched via other routes (Zaikin preprint; Guo-Ling-Rechberger-Wang from KU Leuven Lirias; KRS from the FSE 2012 preproceedings PDF). The Zaikin, GLRW and KRS PDF text was extracted with a small zlib script, so tables are column-garbled in places; I flag where I interpret.

## PART A. Preimage attacks on step-reduced SHA-256

Correction to the working belief: "Aoki et al. 41 steps" is wrong for the ASIACRYPT 2009 paper. 41 steps belongs to a different eprint (Sasaki-Wang-Aoki, 2009/479). The ASIACRYPT 2009 paper reaches 43 steps.

### A1. ePrint 2009/477 (Guo, Matusiewicz) - V (abstract page)
- Title: "Preimages for Step-Reduced SHA-2" (note: the ePrint PDF header reads "Jian Guo and Krystian Matusiewicz"; the ePrint entry has only these two authors).
- URL: https://eprint.iacr.org/2009/477 (2009)
- Claim: 42 steps of SHA-256, time 2^251.7, memory ~2^12; also 42-step SHA-512 at 2^502.3, memory 2^22. MITM preimage attack. Quote: "we present a preimage attack for 42 step-reduced SHA-256 with time complexity 2^251.7" (V).
- This is a precursor, merged into the ASIACRYPT paper below. Its 2^251.7 / 2^12 figure is cited as "42 steps [6]" in GLRW Table 1 (V).

### A1b. ePrint 2009/479 (Sasaki, Wang, Aoki) - V (abstract page)
- Title: "Preimage Attacks on 41-Step SHA-256 and 46-Step SHA-512". Authors: Yu Sasaki, Lei Wang, Kazumaro Aoki. URL: https://eprint.iacr.org/2009/479 (2009).
- Claim: 41-step SHA-256, time 2^253.5 compression function operations, memory 2^16 x 10 words (also describes 40-step at 2^249). Quote: "The time complexity for 41-step SHA-256 is 2^253.5 compression function operations" (V).
- This is the source of the "41 steps" number. Superseded by the merged paper.

### A1c. ASIACRYPT 2009 (Aoki, Guo, Matusiewicz, Sasaki, Wang) - partly V, partly R
- Title: "Preimages for Step-Reduced SHA-2". Authors: Kazumaro Aoki, Jian Guo, Krystian Matusiewicz, Yu Sasaki, Lei Wang. Venue: ASIACRYPT 2009, LNCS 5912, pp. 578-597. DOI 10.1007/978-3-642-10366-7_34 (Springer; paywall/redirect, abstract page not read).
- Result: 43-step SHA-256: pseudo-preimage 2^251.9, preimage 2^254.9 compression-function operations, memory ~2^6 words; 46-step SHA-512: 2^509 / 2^511.5. Also 43-step SHA-224, 46-step SHA-384 (pseudo-preimage).
- Evidence: (V) GLRW Table 1 lists "43 steps ... 2^254.9, memory 2^6 [6]" with [6] = this paper (V, text of GLRW). (V) KRS Table 1 row "[1,11] SHA-256 43 steps: 2^251.9 / 2^254.9 / 2^254.9, memory 2^6" (V). The abstract itself I did not read; wording is R (search snippet).
- Type: 2^251.9 is a pseudo-preimage (free IV); 2^254.9 is a full preimage on the (step-reduced) hash, converted from pseudo-preimage.

### A2. Guo, Ling, Rechberger, Wang, ASIACRYPT 2010 - V (full text)
- Title: "Advanced Meet-in-the-Middle Preimage Attacks: First Results on Full Tiger, and Improved Results on MD4 and SHA-2". Venue: ASIACRYPT 2010, LNCS 6477, pp. 56-75. ePrint 2010/016 (https://eprint.iacr.org/2010/016; abstract page read, PDF read via Lirias).
- Abstract only says "improved preimage attacks on SHA-2 members" (V).
- Table 1 (V): SHA-256 preimage: 24 of 64 steps, 2^240 [Isobe-Shibutani]; 42 steps 2^251.7, mem 2^12 [6]; 42 steps 2^248.4, mem 2^12 (this paper, Appendix A); 43 steps 2^254.9, mem 2^6 [6]. Appendix A: "we find preimages in 2^248.4 ... compared with 2^251.7 for 42-step SHA-256".
- So GLRW do NOT reach 42 steps first (that was Guo-Matusiewicz 2009) and do NOT improve the step count; they improve the complexity at 42 steps only (2^251.7 -> 2^248.4). The "42 steps" attribution to GLRW is a complexity improvement, not a new step record.

### A3. Khovratovich, Rechberger, Savelieva, FSE 2012 - V (full text of preproceedings PDF)
- Title: "Bicliques for Preimages: Attacks on Skein-512 and the SHA-2 family". Venue: FSE 2012, LNCS 7549, pp. 244-263; ePrint 2011/286 (https://eprint.iacr.org/2011/286). Preproceedings PDF: https://www.iacr.org/workshops/fse2012/FSEpreproceedings/PDF/59.pdf
- Intro quote (V): "we build attacks on 45-round SHA-256 and 50-round SHA-512, both the best attacks in the hash mode."
- Intro quote (V): "Regarding the compression functions, we penetrate up to seven more rounds, thus reaching 52 rounds."
- Table 1 (V; column-garbled, my reading; columns Pseudo-preimage / Second preimage / Preimage / Memory in words):
  - SHA-256, 43 steps [1,11]: 2^251.9 / 2^254.9 / 2^254.9 / 2^6
  - SHA-256, 45 steps (Section 5): 2^253 / 2^255.5 / 2^255.5 / 2^6
  - SHA-256, 52 steps (Section 6): pseudo-preimage 2^255, memory 2^6 (no preimage entry)
- Conclusion on type: 45 steps is a genuine PREIMAGE (and second-preimage) attack on the step-reduced HASH function, 2^255.5 (also a 2^253 pseudo-preimage). 52 steps is a PSEUDO-preimage attack on the COMPRESSION function only, 2^255 (text: "a 52-round attack on the SHA-256 compression function").
- Note: success probability gain over brute force 2^256 is tiny (2^0.5). These are "shortcut" attacks, not practical.

### A4. Later results (2013-2026)
- Found: Guo, Li, Liu, Wang, Zhang, "Dual-Syncopation Meet-in-the-Middle Attacks: New Results on SHA-2 and MD5", ePrint 2026/353 (https://eprint.iacr.org/2026/353; received 2026-02-22; listed as "a major revision of an IACR publication in EUROCRYPT 2026"; Springer chapter 10.1007/978-3-032-25333-0_5, not readable). V (abstract page): "we obtain the first preimage attacks on 46- and 47-step SHA-256, extending the previous record of 45 steps". Also improves 43-45 step SHA-256.
- NOT READ: time/memory complexities for 46/47 steps, and whether they are preimage or pseudo-preimage, hash or compression function (abstract does not say; PDF returned 403). Status: U for these details. Do not quote numbers for them.
- Other 2013-2025 work seen only as hits: collision-type results (e.g., eprint 2015/350 "Improving Local Collisions", quantum collision attacks), none a preimage improvement. I did not do an exhaustive survey; no 2013-2025 preimage step improvement was surfaced besides the above (R).

### Conclusion (Part A)
The best published preimage attack on step-reduced SHA-256 is, per its own abstract, Guo-Li-Liu-Wang-Zhang (ePrint 2026/353, EUROCRYPT 2026 line) at 47 steps; its complexity I could not read. The best peer-reviewed-and-fully-read result is Khovratovich-Rechberger-Savelieva (FSE 2012) at 45 steps, preimage on the hash function, time 2^255.5, memory 2^6 words (compression-function pseudo-preimage reaches 52 steps at 2^255). Earlier chain: 41 steps (Sasaki-Wang-Aoki, 2^253.5), 42 (Guo-Matusiewicz 2^251.7; GLRW improve to 2^248.4), 43 (Aoki et al. ASIACRYPT 2009, 2^254.9 preimage, 2^251.9 pseudo-preimage). All are only marginally below 2^256, so they say nothing about practical inversion of the round counts that SAT reaches (about 19).

## PART B. SAT-based inversion

### B5. O. Zaikin 2026 preprint - V (extracted full text)
- Title: "Preimage attacks on round-reduced MD5, SHA-1, and SHA-256 using parameterized SAT solver". Author: Oleg Zaikin (ISDCT SB RAS, Irkutsk). 2026 preprint (38 pages). URL: https://olegzaikin.github.io/publications/2026-z-constraints-preprint.pdf
- Result (abstract, V): "first inverted 29-step MD5, 24-round SHA-1, and 19-round SHA-256 compression functions." Method: Kissat (CDCL) parameterised via ParamILS, Cube-and-Conquer (EnCnC). 19-round SHA-256: about 18 h 33 min on 192 cores (Table 9); 18 rounds 25 s, 1 core; 17 rounds 1 s.
- (a) What is inverted: the COMPRESSION function ("invert these compression functions"; Section 2 "we focus on analyzing the practical preimage resistance of compression functions"). Not the padded hash.
- (b) IV / feed-forward: for MD5 the text says registers are initialised from constants and "incremented by the values they had after the initialization". For SHA-256 the text (Section 2.5, Algorithm 3) describes only the round and message schedule; I found no explicit statement about the SHA-256 final feed-forward addition or its treatment in the reduced versions. Status: U (not stated in the extracted text; encodings are Nossum's SAT-encoding program and Transalg TA programs, whose feed-forward handling I did not check).
- (c) Targets: the headline "1-hash" results use the ALL-ONES output ("128 one-bits, 160 one-bits, and 256 one-bits ... called 1-hashes"). Justification quoted: it should be a regular output "otherwise it may be hard to justify this choice and prove that a random pair of input and output was not picked." Table 7: preimage of 256 one-bits for 19-round SHA-256. Encoding comparison used all-zero, all-one and eight random 256-bit outputs (Appendix A, Table 10), first 256 bits of each random sequence for SHA-256.
- Important: for the weakened "intermediate" problems, a preimage found for the j-th intermediate function inverts the true (i+1)-round function with probability 2^-(32-j) (text: "with probability 1/2^(k-j)"); for j = 20, 24, 28 the probabilities were 1/4096, 1/256, 1/16 and "no preimage for 19-round SHA-256 was found" (V). So the final 19-round result is for the full 19-round function only if a j=32 case or lucky hit was achieved; Section 7.4 (V): direct Cube-and-Conquer on the full 19-round problem found nothing in 7 days on 192 cores; the (18|29|32)-round intermediate problem was solved (18 h 33 min, parameterised Kissat) and, with probability 1/8, that preimage was also a preimage of the true 19-round function, which it turned out to be (Table 7). So the 19-round result is a lucky lift from an intermediate problem, for the all-ones target.
- (d) Padding: no padding imposed. Compression function with 512-bit block input; all message bits free ("find any its preimage (input)"). Padding is mentioned only in the MD5 description of the full hash.
- (e) Counting: "rounds" for SHA-1/SHA-256 (1..64), "steps" for MD5 (1..64). The i-th round computes W[i-1] from the schedule in the standard way; a reduced function runs the first r rounds (schedule computed only as needed). Intermediate "(i|j)-round" functions weaken the message word of round i+1 to its leftmost j bits.
- (f) Earlier work cited, with correction: the abstract says "In 2012, 28-step MD5, 23-round SHA-1, and 16-round SHA-256 compression functions were reduced to SAT and inverted". Per the reference list and Section 2/9: 28-step MD5 and 23-round SHA-1 are [2] Legendre, Dequen, Krajecki, "Encoding hash functions as a SAT problem", ICTAI 2012, pp. 916-921 (doi 10.1109/ICTAI.2012.128), plus [20],[27] for others. The 16-step/round SHA-256 is NOT from Legendre et al.; it is [4] Homsirikamol, Morawiecki, Rogawski, Srebrny, "Security margin evaluation of SHA-3 contest finalists through SAT-based attacks", CISIM 2012, LNCS 7564 (ePrint 2012/421; "In [4], 16-round SHA-256 and 2-round SHA-3 were inverted"; Section 2: "a practical SAT-based preimage attack on 16-step SHA-256 compression function"). Zaikin also notes in Section 9 that [6] inverted full SHA-1 and [8] a similar thing for SHA-256 "but most message bits were assigned randomly".
- Zaikin also cites for theoretical attacks: "52-round (reduced) SHA-256 compression function [25]" with [25] = KRS FSE 2012, consistent with A3.

### B6. 2012 SAT work
- Legendre-Dequen-Krajecki (ICTAI 2012): abstract (R, via search snippet; full text U) reports inversions up to 39 (MD4), 28 (MD5), 23 (SHA-1) steps. Nothing on SHA-256 found; SHA-256 16-round is not theirs.
- Homsirikamol et al. (CISIM 2012 / ePrint 2012/421): abstract page confirms topic (SAT attacks on SHA-3 finalists, "all the finalists have substantially bigger security margin than ... SHA-256 and SHA-1") (R). The SHA-256 16-step set-up (target, IV, padding) is U: hal-01551728 returned an access-denied page and I did not retrieve the ePrint PDF.

## Our set-up (context only, not researched)
One compression call from the standard IV, feed-forward included, all 512 message bits free, target = output of a uniformly random 512-bit message (preimage guaranteed), rounds = number of the 64 rounds performed, schedule computed only as far as needed.

## Why results may differ
1. Targets: Zaikin's headline instances use the constant all-ones output. For a round-reduced function with feed-forward there is no guarantee that a constant target has any preimage; for the full function it is believed to, but "1-hash" instances are not drawn from the image distribution. Our target is always in the image. Satisfiability and hardness can differ in either direction (a target with no or few preimages is a UNSAT/hard proof instance; a typical image has about one preimage per ~2^256 outputs for the full function but many more for few rounds).
2. Few-round functions are far from surjective-uniform: with r rounds only part of the 512 message bits matter, so many preimages exist per image for small r. Hardness is driven by the number of solutions, which changes with r and with the target.
3. Feed-forward and IV: Zaikin's SHA-256 text does not state them (U); SAT papers on "round-reduced compression function" sometimes drop the final addition or use a free state. Our function keeps feed-forward from the fixed standard IV (not free-start). MITM papers in Part A mostly give pseudo-preimages (free IV) before converting to preimages; mixing these with our fixed-IV, fixed-padding-free setting is not apples to apples.
4. Step vs round counting: MD5 "steps" and SHA-256 "rounds" are the same granularity, but for SHA-256 the MITM literature says "steps" (one round = one step), and the schedule (W[16..]) is only needed for r > 16. KRS and Aoki et al. count the first N steps from step 0 with feed-forward included; Zaikin's "weakened" (i|j) functions are neither r nor r+1 rounds.
5. Padding: the cryptanalytic attacks on the "hash function" (KRS 45 steps) must satisfy padding/length fields in the last block (GLRW Table 1 notes "msg refers to original message before padding"); pseudo-preimage and compression-function results (52 steps) ignore padding. Zaikin and ours impose none.
6. Complexity measures differ: MITM numbers are in compression-function evaluations on a (barely sub-brute-force) asymptotic scale, SAT numbers are wall-clock times of a solver on a cluster (Zaikin: 192 cores). They share no scale; a 19-round SAT inversion and a 45/47-step MITM attack are not comparable as security margins (Zaikin Section 8.4 makes the same point).
7. Parameterisation: Zaikin's best instances use the intermediate-weakened last round and need a probabilistic lift (probabilities 1/4096 ... 1/16 per hit), unlike our plain r-round instances.

## Summary
(see final reply)
