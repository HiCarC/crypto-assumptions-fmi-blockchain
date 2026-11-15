#!/usr/bin/env python3
"""Cost of each signature-verification mode, from results/gas.json (written by the Foundry
test PostQuantumTest.test_writeGasTable). Produces results/gas_table.md and
results/fig_gas.png.

Transaction cost model (Ethereum rules as of the Osaka fork used by the tests):
  total = max(21000 + 4*zero_bytes + 16*nonzero_bytes + execution,
              21000 + 10*(zero_bytes + 4*nonzero_bytes))          # EIP-7623 calldata floor
`execution` is measured; the rest is arithmetic on measured calldata.
The "per 30M gas" column is an illustration of scale for a block of 30 million gas, a round
reference figure, not a statement about any network's current limit.
"""
import json
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results")
g = json.load(open(os.path.join(RES, "gas.json")))

ORDER = [
    ("ecdsa-secp256k1", "ECDSA secp256k1 (today's default)"),
    ("p256-precompile", "ECDSA P-256, native precompile"),
    ("p256-solidity", "ECDSA P-256, contract code only"),
    ("hybrid-ecdsa+p256", "Hybrid: secp256k1 + P-256"),
    ("mldsa44", "ML-DSA-44 (post-quantum), contract code"),
    ("hybrid-ecdsa+mldsa44", "Hybrid: secp256k1 + ML-DSA-44"),
]


def tx_total(row):
    zero = row["transferCalldataZeroBytes"]
    nonzero = row["transferCalldataBytes"] - zero
    standard = 21000 + 4 * zero + 16 * nonzero + row["transferExecutionGas"]
    floor = 21000 + 10 * (zero + 4 * nonzero)
    return max(standard, floor)


base = g["ecdsa-secp256k1"]
lines = ["| Verification mode | Key (bytes) | Signature (bytes) | Verification gas | × ECDSA | Full transfer gas | Transfers per 30M gas |",
         "|---|---|---|---|---|---|---|"]
out = {}
for key, label in ORDER:
    r = g[key]
    total = tx_total(r) if r["transferCalldataBytes"] else None
    out[key] = dict(label=label, verifyGas=r["verifyGas"], ratio=r["verifyGas"] / base["verifyGas"], transferGas=total)
    lines.append(f"| {label} | {r['keyBytes']:,} | {r['sigBytes']:,} | {r['verifyGas']:,} | {r['verifyGas'] / base['verifyGas']:,.0f}× | "
                 + (f"{total:,} | {30_000_000 // total:,} |" if total else "not measured | |"))
lines += ["", f"One-off registration of an ML-DSA-44 public key (stored expanded, {g['mldsa44ExpandedKeyBytes']:,} bytes): "
              f"{g['mldsa44KeyRegistrationGas']:,} gas."]
open(os.path.join(RES, "gas_table.md"), "w").write("\n".join(lines) + "\n")
json.dump(out, open(os.path.join(RES, "gas_summary.json"), "w"), indent=1)
print("\n".join(lines))

fig, ax = plt.subplots(figsize=(8.6, 3.9))
labels = [l for _, l in ORDER][::-1]
vals = [g[k]["verifyGas"] for k, _ in ORDER][::-1]
cols = ["#b03a2e" if "ML-DSA" in l else "#1b6ca8" for l in labels]
ax.barh(labels, vals, color=cols)
ax.set_xscale("log")
ax.set_xlabel("gas to verify one signature (log scale)")
for y, v in enumerate(vals):
    ax.text(v * 1.15, y, f"{v:,}", va="center", fontsize=9)
ax.set_xlim(1e3, 1e8)
ax.spines[["top", "right"]].set_visible(False)
ax.set_title("Cost of checking one signature on an EVM ledger, by scheme", fontsize=11, loc="left")
fig.tight_layout()
fig.savefig(os.path.join(RES, "fig_gas.png"), dpi=170)
