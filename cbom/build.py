#!/usr/bin/env python3
"""Builds the comparative CBOM from cbom/data.py:
  cbom/cbom.csv, cbom/primitives.csv, cbom/cbom.cdx.json (CycloneDX 1.6),
  results/cbom_table.md, results/fig_powers_heatmap.png
"""
import csv
import json
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

from data import PLATFORMS, PRIMITIVES

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results")
FIELDS = ["status", "ledger", "signatures", "hash", "consensus", "freeze", "upgrade", "policy", "pq"]
TITLES = dict(status="Status", ledger="Ledger technology", signatures="Signature schemes", hash="Hash functions",
              consensus="Consensus and trust assumption", freeze="Who can freeze or claw back",
              upgrade="Who can upgrade", policy="Who sets signer / transaction policy", pq="Post-quantum roadmap")
NOT_FOUND = "not found in public material retrieved"

with open(os.path.join(HERE, "cbom.csv"), "w", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(["platform", "category"] + [x for f in FIELDS for x in (f, f + "_evidence")] + ["as_of"])
    for p in PLATFORMS:
        w.writerow([p["name"], p["category"]] + [x for f in FIELDS for x in (p[f][0] or NOT_FOUND, p[f][1])] + ["2026-11-15"])

with open(os.path.join(HERE, "primitives.csv"), "w", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(["primitive", "type", "classical_security", "under_large_quantum_computer", "public_key_bytes", "signature_bytes", "standard"])
    w.writerows(PRIMITIVES)

components = []
for p in PLATFORMS:
    components.append({
        "type": "platform", "bom-ref": "platform:" + p["name"], "name": p["name"],
        "properties": [{"name": f"fmi:{f}", "value": p[f][0] or NOT_FOUND} for f in FIELDS]
                      + [{"name": f"fmi:{f}:evidence", "value": p[f][1]} for f in FIELDS]
                      + [{"name": "fmi:category", "value": p["category"]}],
    })
for name, typ, classical, quantum, pk, sig, std in PRIMITIVES:
    components.append({
        "type": "cryptographic-asset", "bom-ref": "crypto:" + name, "name": name,
        "cryptoProperties": {"assetType": "algorithm",
                             "algorithmProperties": {"primitive": "hash" if typ == "hash" else "signature"}},
        "properties": [{"name": "fmi:classicalSecurity", "value": classical}, {"name": "fmi:quantum", "value": quantum},
                       {"name": "fmi:standard", "value": std}]
                      + ([{"name": "fmi:publicKeyBytes", "value": str(pk)}, {"name": "fmi:signatureBytes", "value": str(sig)}] if pk else []),
    })
json.dump({"bomFormat": "CycloneDX", "specVersion": "1.6", "version": 1,
           "metadata": {"timestamp": "2026-11-15T00:00:00Z",
                        "component": {"type": "application", "name": "crypto-assumptions-fmi-blockchain comparative CBOM"},
                        "properties": [{"name": "fmi:evidenceLabels", "value": "V=official source read; R=reported; U=not found in public material retrieved"}]},
           "components": components}, open(os.path.join(HERE, "cbom.cdx.json"), "w"), indent=1, ensure_ascii=False)

cols = ["signatures", "freeze", "upgrade", "policy", "pq"]
with open(os.path.join(RES, "cbom_table.md"), "w") as fh:
    fh.write("| Platform | " + " | ".join(TITLES[c] for c in cols) + " |\n|" + "---|" * (len(cols) + 1) + "\n")
    for p in PLATFORMS:
        fh.write(f"| {p['name']} | " + " | ".join(f"{p[c][0]} [{p[c][1]}]" if p[c][0] else "not found [U]" for c in cols) + " |\n")

heat = ["freeze", "upgrade", "policy", "pq"]
color = {"V": "#1b7f5a", "R": "#e3b23c", "U": "#d9d9d9"}
# Colour shows how well a cell is evidenced, not what it says. Where an official source was
# read and says there is NO roadmap, the cell is marked so that green is not read as "yes".
NOTE = {("Bitcoin", "pq"): "draft proposal", ("Stellar", "pq"): "plan 2026-27", ("Ethereum L1", "pq"): "in development",
        ("Canton Network / Global Synchronizer", "pq"): "none stated", ("BIS Project Agorá", "pq"): "none stated",
        ("Digital euro", "pq"): "aim only", ("Stellar", "freeze"): "issuer", ("USDC (Circle)", "freeze"): "issuer",
        ("USDT (Tether)", "freeze"): "issuer", ("USDC (Circle)", "policy"): "issuer", ("USDT (Tether)", "policy"): "issuer",
        ("Canton Network / Global Synchronizer", "upgrade"): "validator vote", ("Canton Network / Global Synchronizer", "policy"): "validator vote",
        ("ZKsync Prividium", "policy"): "operator", ("Stellar", "policy"): "issuer / holder"}
fig, ax = plt.subplots(figsize=(7.6, 0.33 * len(PLATFORMS) + 1.6))
for y, p in enumerate(PLATFORMS):
    for x, f in enumerate(heat):
        ax.add_patch(plt.Rectangle((x, y), 1, 1, facecolor=color[p[f][1]], edgecolor="white", lw=2))
        if (p["name"], f) in NOTE:
            ax.text(x + 0.5, y + 0.5, NOTE[(p["name"], f)], ha="center", va="center", fontsize=7, color="white")
ax.set_xlim(0, len(heat)); ax.set_ylim(len(PLATFORMS), 0)
ax.set_xticks([i + 0.5 for i in range(len(heat))])
ax.set_xticklabels(["Who can\nfreeze", "Who can\nupgrade", "Who sets\nsigner policy", "Post-quantum\nroadmap"], fontsize=9)
ax.xaxis.tick_top()
ax.set_yticks([i + 0.5 for i in range(len(PLATFORMS))]); ax.set_yticklabels([p["name"] for p in PLATFORMS], fontsize=8.5)
ax.tick_params(length=0)
for s in ax.spines.values():
    s.set_visible(False)
ax.legend(handles=[Patch(color=color["V"], label="stated in an official source we read"),
                   Patch(color=color["R"], label="reported (excerpt or secondary source)"),
                   Patch(color=color["U"], label="not found in public material retrieved")],
          loc="upper center", bbox_to_anchor=(0.5, -0.02), ncol=1, frameon=False, fontsize=8.5)
fig.tight_layout()
fig.savefig(os.path.join(RES, "fig_powers_heatmap.png"), dpi=170)

n = {k: sum(p[f][1] == k for p in PLATFORMS for f in heat) for k in "VRU"}
inst = [p for p in PLATFORMS if p["category"] in ("institutional", "central bank")]
ni = {k: sum(p[f][1] == k for p in inst for f in heat) for k in "VRU"}
json.dump({"platforms": len(PLATFORMS), "cells_all": n, "institutional_and_central_bank_platforms": len(inst), "cells_institutional": ni},
          open(os.path.join(RES, "cbom_summary.json"), "w"), indent=1)
print(len(PLATFORMS), "platforms;", "all cells", n, "; institutional/central-bank cells", ni)
