# Incident fact verification against primary sources

Checked 15 Nov 2026. Labels: V = I read the primary myself; R = secondary only; U = not found.
Quotes are as returned by the fetch tool (a summarising model), so treat them as near-verbatim, not guaranteed character-exact.

## Priority 1 - Binance theft, 29 Oct 2026

### 1.1 Binance, initial update (V)
- URL: https://www.binance.com/en-GB/support/announcement/security-incident-update-2026-10-30-c5a8729a97ac486d963784d96c5642d7
- Dated 2026-10-30 02:23.
- Claims: impact "around $6.3B"; "no evidence of any wallet private key leak"; initial investigation points to a "compromised DevOps engineer's laptop" giving access to a service container and unauthorised withdrawals; about $3bn frozen on-chain.

### 1.2 Binance, Security Incident Update #2 (V)
- URL: https://www.binance.com/en-GB/support/announcement/security-incident-update-2-2026-10-30-d3306d9dca5243548c813b605e1d1751
- Dated 2026-10-30 19:33. Hot wallets compromised "around 2026-10-29 20:05 (UTC)".
- Amount: approx. $6.3B of token assets.
- Quote: "we have found no evidence that wallet private keys were leaked."
- Access path: the laptop explanation is called incomplete ("additional points of breach"). No detail on the signing path.
- Frozen: "Approximately $3 billion has been frozen on-chain to date." The freezer is not named. Binance only says it worked with law enforcement, blockchain intelligence firms, asset issuers and partners.
- EIP-7702: not mentioned. AI tool: not mentioned.

### 1.3 Binance, "29 October 2026 Binance Security Incident: Initial Findings and Response Update" (V)
- URL: https://www.binance.com/en/blog/community/3229153443759566763 (a blog URL, not under /support/announcement)
- Post date 2026-11-03; status line "As of Nov 3, 2026". I saw no "updated 7 Nov" label, so the 7 Nov update is unconfirmed (R/U).
- Amount: "Approximately USD 6.34 billion in digital assets were impacted by the incident."
- Frozen: approx. USD 2.85bn "frozen or intercepted, subject to reconciliation and market price volatility". This differs from the ~$3bn in Updates 1 and 2. The freezer is again unnamed ("coordinating with partners to freeze affected tokens").
- Private keys: the hot wallet used MPC, so "there was no single private key that could be used to immediately revoke" the malicious authorizations. This is not a flat "no key leaked" statement. The "no evidence of key leak" wording is in Updates 1 and 2 (see 1.1 and 1.2).
- Signing service: the attacker "exploited unauthorized access to an internal wallet signing service" to start transactions outside the normal withdrawal process.
- EIP-7702: the attacker used the signing service to exploit Ethereum's EIP-7702 authorization mechanism. This gave an attacker-controlled contract partial execution rights over a hot wallet. Binance does not describe an EIP-7702 flaw.
- AI tool: V. The attacker "used an internal AI tool to gain control over the Wallet DevOps Engineer A", then used a stolen deployment token. The report does not explain how the AI tool was abused (per Maborak and SecurityWeek, R).
- Timeline: delegation code cleared 00:10 UTC on 30 Oct. Replenishment figure "as of 31 October".
- FBI: the post cites the FBI alert. The attribution to the DPRK comes from the FBI, not from Binance.
- Discrepancy: replenishment was reported as 80% (Update 2), 90% (Update 3, 31 Oct), 95% (1 Nov, R) and 98% (3 Nov report, per Blockchain.News, R).
- Discrepancy: time zones. Binance says 29 Oct 20:05 UTC. Some outlets say 30 Oct (UTC+8).

### 1.4 Binance recovery update #3 (R)
- Link taken from aicybr.com, not opened by me: https://www.binance.com/en-GB/support/announcement/security-incident-recovery-update-3-90-of-stolen-assets-replenished-proof-of-reserves-snapshot-provided-2026-10-31-1fdf1f61559c401da0435895ffcccb62
- Dated 31 Oct. Reported wording: "more than $6.34 billion set aside to cover the impact"; 90% replenished.

### 1.5 FBI alert (R, primary not opened)
- Claim: the FBI attributes the theft to DPRK / TraderTraitor.
- Primary: http://www.fbi.gov/investigate/cyber/alerts/2026/north-korea-responsible-for-6-billion-binance-attack. The fetch returned HTTP 403, so it was not read. BleepingComputer links to this URL and not to ic3.gov. I found no ic3.gov page.
- The alert was published Saturday 31 Oct 2026. No alert number was given by any source.
- Wording as reported (BleepingComputer, 1 Nov 2026): "more than $6 billion USD in virtual assets". The body of the article says approx. $6.36bn.
- Addresses as reported: 628 in total (608 Ethereum, 19 Bitcoin, 1 Solana).
- Discrepancy: the claim "ic3.gov alert" appears wrong. It is an fbi.gov alert. Amounts differ across sources: FBI ">$6bn", Binance $6.3bn then $6.34bn, Chainalysis $6.4bn.

### 1.6 DOJ seizure (U)
- I found no DOJ seizure or forfeiture announcement for the Binance funds. Blockworks "fbi-binance-seizure" exists, but I got HTTP 403 and could not read it.

### 1.7 Chainalysis, Binance exploit blog (V)
- URL: https://www.chainalysis.com/blog/binance-exploit-latest-findings-and-response/. Published 30 Oct 2026 and updated to 3 Nov 11:30 ET.
- Amount: approx. $6.4bn across multiple chains. Outflows began about 4:20pm ET on 29 Oct.
- Mechanism: a wallet funded through Tornado Cash submitted "valid signed authorizations that allowed a Binance hot wallet to run attacker-deployed code." The attacker then swept it. Chainalysis does not name EIP-7702 in the fetched text, but the mechanism matches.
- Frozen: "About $2.8 billion has been frozen" as of 3 Nov. Freezes began by 5:14pm ET on 29 Oct.
- Attribution: TraderTraitor, based on on-chain commingling with funds from the earlier Bitget theft.
- Other: $325m of stablecoins were swapped for $285m of ETH over about 20 minutes.

## Priority 2 - Bybit, 21 Feb 2025

### 2.1 FBI PSA (V)
- URL: https://www.ic3.gov/PSA/2025/PSA250226. Number I-022625-PSA. Dated 26 Feb 2025.
- Amount: "approximately $1.5 billion USD in virtual assets". The theft was on or about 21 Feb 2025.
- Attribution: DPRK, "TraderTraitor". The fetch reported 51 Ethereum addresses listed. I did not independently count them.

### 2.2 Bybit, Safe and forensic firms (R)
- The Bybit post-mortem fetch timed out and gave 404 on the alternate path. The Safe, Sygnia and Verichains reports were not found as documents.
- BleepingComputer (https://www.bleepingcomputer.com/news/security/lazarus-hacked-bybit-via-a-breached-safe-wallet-developer-machine/) cites:
  - Safe statement on X, 26 Feb 2025: https://x.com/safe/status/1894768522720350673. Quote: "compromised Safe{Wallet} developer machine resulting in the proposal of a disguised malicious transaction".
  - Bybit CEO post sharing the forensic findings, https://x.com/benbybit/status/1894768736084885929. Verichains: malicious JavaScript injected into app.safe.global. Sygnia: new JavaScript resources uploaded to Safe's AWS S3 bucket.
  - Bybit's announcement URL (not opened): https://announcements.bybit.com/article/incident-update---eth-cold-wallet-incident-blt292c0454d26e9140/
- Discrepancy: the loss is reported as $1.4bn by some and $1.5bn by others.

## Priority 3 - single primary per incident

| Incident | Amount and root cause (best available) | Label and source |
|---|---|---|
| Ronin, Mar 2022 | 173,600 ETH + 25.5m USDC (about $625m). 5 of 9 validator keys: 4 Sky Mavis, 1 Axie DAO. Spear-phished employee. | R. The Sky Mavis posts (roninchain.com/blog/posts/community-alert-ronin-validators-6513cc78a5edc1001b03c366 and back-to-building-...-6513cc78a5edc1001b03c364) returned 404 or redirected. Only search snippets seen. The Axie DAO allowlist detail is secondary only. |
| Wormhole, Feb 2022 | About $325m. 120,000 wETH minted without backing via a Solana signature or guardian-account verification failure. | R (CertiK and others). The Medium incident report returned 403. |
| Nomad, Aug 2022 | About $190m (range $186m to $200m). Bug in a June 2022 upgrade left the Replica contract unable to authenticate messages. Trusted root of zero. | R (Halborn, BlockSec, Immunefi, Protos). Medium RCA returned 403. |
| Poly Network, Aug 2021 | About $611m, returned. Dedaub: probably keeper keys, not a contract logic bug. | R (Dedaub). Note that Poly's own account described it as an exploit of the cross-chain contract; I did not verify this. |
| Wintermute, Sep 2022 | About $160m (ITPro says $162.2m). | V for Wintermute's own statement. The Block, 20 Sep 2022: https://www.theblock.co/post/171559/security. Gaevoy said it was most likely a "Profanity-type exploit", that Profanity generated the key, and that it was an "internal (human) error". So Wintermute itself said "most likely", linked it to the 1inch Profanity research, and used Profanity plus an internal tool for gas-optimising zero-prefixed addresses. This is a CEO statement, not a full post-mortem. |
| THORChain, 15 May 2026 | About $10m. "three small, individually low-severity issues" in the GG20 library forked from Binance. | V. https://blog.thorchain.org/thorchain-exploit-report-2, published 3 Jul 2026 (not "report 2 in May"). It does not name MOD/FAC proofs. It says the library "never actually verified" that the Paillier modulus is a product of two large primes and "only screened out a handful of tiny factors". A newer library version enforces verification and THORChain had not adopted it. So the substance is confirmed, but the term "missing Paillier proof checks" is not THORChain's wording. MOD/FAC naming comes from QuillAudits and Rekt (R). |
| Bitget, 24 Sep 2026 | $387m. DPRK-attributed. | V for the amount and attribution. https://www.chainalysis.com/blog/387m-bitget-theft-2026/, published 1 Oct 2026. The post gives no technical root cause. The amount is Chainalysis's figure, not Bitget's own. |
| Kelp DAO, 18 Apr 2026 | About 116,500 rsETH (about $290m to $293m). LayerZero blames a 1-of-1 DVN setup and poisoned RPC nodes, attributes to Lazarus/TraderTraitor with preliminary confidence. Kelp disputes this and says the configuration was a default. | R only (The Block, CoinDesk, Defiant). Neither Kelp's nor LayerZero's own statement was opened. Discrepancy: Kelp's refill figure of 117,132 rsETH vs 116,500. TRM gives about $292m. |
| Drift, 1 Apr 2026 | About $285m in 12 minutes. A six-month social-engineering campaign, device malware, pre-signed durable-nonce multisig approvals from 2 of 5 Security Council members, a fake CVT collateral token. Not a smart-contract bug. | R (Nexus Mutual incident report, https://nexusmutual.io/blog/drift-protocol-incident-report). Drift's own 5 Apr update is on X: https://x.com/DriftProtocol/status/2040611161121370409 (not opened). Cointelegraph says about $280m; others $286m. |

## Priority 4 - aggregates

### 4.1 Chainalysis 2025 (V)
- URL fetched: https://www.chainalysis.com/blog/crypto-hacking-stolen-funds-2026/. Published 18 Dec 2025.
- Quote: "The cryptocurrency industry witnessed over $3.4 billion in theft from January through early December 2025."
- DPRK: "at least $2.02 billion", which is $681m more than 2024.
- The 3.4bn figure is confirmed as "over $3.4bn", but only through early December 2025. The year-end figure may differ.

### 4.2 TRM Labs H1 2026 (V)
- URL: https://www.trmlabs.com/resources/blog/h1-2026-crypto-hacks-reach-record-high-as-losses-fall-below-usd-1-billion. Published 1 Jul 2026.
- 207 hacks (83 in H1 2025). About $972m stolen (about $2.3bn in H1 2025).
- Infrastructure compromises: about 15% of incidents and about 76% of losses.
- DPRK-linked: about $643m (66%). Drift about $285m and KelpDAO about $292m, together about $577m.
- Discrepancy: TRM's AI-in-Crime Adoption Index gives 201 hacks and about $600m (61%) DPRK. The main H1 blog is the more recent figure.

## Summary (10 lines)
1. V: Binance Updates 1 and 2 (about $6.3bn, "no evidence" of private-key leak, about $3bn frozen) and the 3 Nov report (about $6.34bn, about $2.85bn frozen or intercepted).
2. V: the 3 Nov report names EIP-7702 and an internal AI tool. It does not explain how the AI tool was abused. Both are on a binance.com blog URL, not /support/announcement.
3. R: FBI Binance alert. It is on fbi.gov, not ic3.gov, with no alert number found. It is reported as 31 Oct, ">$6 billion", 628 addresses (608 ETH, 19 BTC, 1 SOL). fbi.gov returned 403.
4. U: DOJ seizure for the Binance funds. Nothing found. The "updated 7 Nov" claim was also not seen on the page.
5. V: Chainalysis Binance blog ($6.4bn, $2.8bn frozen at 3 Nov, DPRK via Bitget commingling). It does not name EIP-7702 in the text I got.
6. V: FBI PSA I-022625-PSA, 26 Feb 2025, "approximately $1.5 billion". R: the Safe and Bybit root cause (Safe X statement, Sygnia/Verichains via BleepingComputer).
7. V: THORChain report 2 (published 3 Jul 2026, about $10m, Paillier modulus not verified as a product of two primes, but no MOD/FAC wording). V: Wintermute CEO statement ("most likely" a Profanity-type exploit). V: Bitget $387m (Chainalysis, no root cause). V: Chainalysis 2025 ($3.4bn+, through early December) and TRM H1 2026.
8. R only: Ronin, Wormhole, Nomad, Poly Network, Kelp DAO and Drift. Medium and Sky Mavis primaries were blocked or returned 404.
9. Wrong or imprecise in the brief: "ic3.gov" for Binance (it is fbi.gov); THORChain "report #2" is dated July, not May; "no private key leaked" is only in Updates 1 and 2, while the 3 Nov report says the wallet was MPC with no single key.
10. Binance totals are inconsistent across its own posts (frozen about $3bn then $2.85bn; replenished 80%, 90%, 95%, 98%). Quote each figure with its date.
