#!/usr/bin/env python3
"""Migration model for an institutional ledger moving from ECDSA/EdDSA to ML-DSA or hybrid,
set against published policy dates. Writes results/fig_migration_timeline.png and
results/migration_model.md.

Two kinds of content, kept visibly apart:
  * POLICY DATES and PLATFORM PLANS are taken from sources (label and source in the table).
  * STEP DURATIONS are planning assumptions made for this model. They are not estimates of
    any institution's programme and carry no probability. Change them in STEPS and rerun.
"""
import os
from datetime import date

import matplotlib

matplotlib.use("Agg")
import matplotlib.dates as mdates
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results")

# (date, text, evidence label, source)
POLICY = [
    (date(2024, 8, 13), "NIST FIPS 203/204/205 final", "V", "csrc.nist.gov"),
    (date(2025, 6, 23), "EU coordinated PQC roadmap published", "V", "digital-strategy.ec.europa.eu"),
    (date(2026, 10, 27), "NIST IR 8547 final", "V", "csrc.nist.gov/pubs/ir/8547/final"),
    (date(2026, 12, 31), "EU: first steps and national roadmaps", "V", "EU PQC roadmap v1.1"),
    (date(2030, 12, 31), "NIST: ECDSA/EdDSA/RSA deprecated after 2030\nEU: high-risk use cases migrated", "V", "NIST IR 8547; EU roadmap"),
    (date(2035, 12, 31), "NIST: disallowed after 2035\nEU: medium-risk migrated; G7 CEG: general target", "V", "NIST IR 8547; G7 CEG roadmap"),
]
PLANS = [
    (date(2026, 12, 31), "Stellar: ML-DSA verification in contracts (plan)", "V", "stellar.org"),
    (date(2027, 12, 31), "Stellar: quantum-safe account signers (plan)", "V", "stellar.org"),
    (date(2029, 6, 30), "Ethereum: L1 upgrades estimated around 2029", "V (stated as an estimate)", "pq.ethereum.org"),
]
# (step, assumed months, depends on, who decides)  -- ASSUMPTIONS
STEPS = [
    ("1. Cryptographic inventory (CBOM) of ledger, contracts, wallets, HSMs, bridges", 6, None, "operator + participants"),
    ("2. Governance decision: target scheme, hybrid or not, sunset dates", 6, 1, "ledger governance body"),
    ("3. HSM / KMS / wallet support for the new scheme", 12, 2, "vendors + each participant"),
    ("4. Verifier deployed and approved on the ledger; audit and testing", 9, 2, "operator + auditors"),
    ("5. Participants register new keys (hybrid), dual running", 12, 4, "every participant"),
    ("6. Classical-only keys deprecated: no new registrations", 6, 5, "ledger governance body"),
    ("7. Classical-only keys disallowed; stragglers recovered by registrar", 6, 6, "ledger governance body + registrar"),
]
START = date(2027, 1, 1)


def add_months(d, m):
    y, mo = divmod(d.month - 1 + m, 12)
    return date(d.year + y, mo + 1, 1)


sched = {}
for i, (name, months, dep, who) in enumerate(STEPS, 1):
    begin = START if dep is None else sched[dep][1]
    if i == 4:  # runs in parallel with step 3, both after step 2
        begin = sched[2][1]
    if i == 5:  # needs both 3 and 4
        begin = max(sched[3][1], sched[4][1])
    sched[i] = (begin, add_months(begin, months))

fig, ax = plt.subplots(figsize=(12.5, 6.2))
n = len(STEPS)
for i, (name, months, dep, who) in enumerate(STEPS, 1):
    b, e = sched[i]
    ax.barh(n - i, (e - b).days, left=mdates.date2num(b), height=0.55, color="#1b6ca8" if i < 6 else "#b03a2e")
    ax.text(mdates.date2num(e) + 20, n - i, f"{name}  [{who}]", va="center", fontsize=8.3)
for j, (d, text, label, _) in enumerate(POLICY):
    ax.axvline(mdates.date2num(d), color="#555", lw=0.9, ls="--")
    ax.text(mdates.date2num(d) + 15, n + 2.6 - 0.45 * (j % 4), f"{text}", fontsize=7.6, va="top", color="#333",
            bbox=dict(facecolor="white", edgecolor="none", pad=0.6))
for k, (d, text, label, _) in enumerate(PLANS):
    ax.plot(mdates.date2num(d), -1.2 - 0.55 * k, "D", color="#2e8b57", ms=6)
    ax.text(mdates.date2num(d) + 25, -1.2 - 0.55 * k, text, fontsize=7.8, va="center", color="#2e8b57")
ax.set_ylim(-3.2, n + 2.8)
ax.set_xlim(mdates.date2num(date(2024, 1, 1)), mdates.date2num(date(2039, 6, 1)))
ax.xaxis_date()
ax.xaxis.set_major_locator(mdates.YearLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
ax.set_yticks([])
ax.spines[["top", "right", "left"]].set_visible(False)
end = sched[n][1]
ax.set_title(f"Migration model for an institutional ledger: start {START:%B %Y}, classical keys disallowed {end:%B %Y} "
             "(step lengths are planning assumptions)", fontsize=10, loc="left")
fig.tight_layout()
fig.savefig(os.path.join(RES, "fig_migration_timeline.png"), dpi=170)

total = (end.year - START.year) * 12 + end.month - START.month
with open(os.path.join(RES, "migration_model.md"), "w") as fh:
    fh.write("### Policy dates and platform plans (from sources)\n\n| Date | Item | Evidence | Source |\n|---|---|---|---|\n")
    for d, text, label, src in POLICY + PLANS:
        fh.write(f"| {d:%d %b %Y} | {text.replace(chr(10), '; ')} | {label} | {src} |\n")
    fh.write("\n### Migration steps (durations are planning assumptions, not estimates)\n\n"
             "| Step | Assumed months | Begins | Ends | Who decides or acts |\n|---|---|---|---|---|\n")
    for i, (name, months, dep, who) in enumerate(STEPS, 1):
        fh.write(f"| {name} | {months} | {sched[i][0]:%b %Y} | {sched[i][1]:%b %Y} | {who} |\n")
    fh.write(f"\nCritical path under these assumptions: {total} months from {START:%B %Y} to {end:%B %Y}. "
             f"Deprecation (step 6) begins {sched[6][0]:%B %Y}.\n")
print(f"critical path {total} months; ends {end:%B %Y}; step 6 begins {sched[6][0]:%B %Y}")
