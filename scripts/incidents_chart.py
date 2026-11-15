#!/usr/bin/env python3
"""Root causes of major thefts, from data/incidents.csv. Writes results/fig_incidents.png and
results/incidents_summary.md. The list is a set of large and instructive cases, not a census:
totals by class describe this list only (see LIMITATIONS.md)."""
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.patches import Patch

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results")
df = pd.read_csv(os.path.join(HERE, "..", "data", "incidents.csv")).sort_values("loss_usd_m")
CLASSES = {
    "a": ("Cryptographic primitive broken", "#000000"),
    "b": ("Error in cryptographic code or key generation", "#8e44ad"),
    "c": ("Operational compromise of keys or signing", "#b03a2e"),
    "d": ("Smart-contract logic flaw", "#1b6ca8"),
    "e": ("Bridge or message-verification flaw", "#e3b23c"),
    "f": ("Social engineering of governance", "#2e8b57"),
    "u": ("Root cause not published", "#aaaaaa"),
}
fig, ax = plt.subplots(figsize=(9.2, 4.9))
ax.barh([f"{r.incident} ({r.date[:4]})" for r in df.itertuples()], df.loss_usd_m, color=[CLASSES[c][1] for c in df["class"]])
for y, r in enumerate(df.itertuples()):
    ax.text(r.loss_usd_m + 60, y, f"${r.loss_usd_m:,.0f}m", va="center", fontsize=8.5)
ax.set_xlabel("reported loss, US$ million (gross, before recoveries)")
ax.set_xlim(0, df.loss_usd_m.max() * 1.14)
ax.spines[["top", "right"]].set_visible(False)
counts = df["class"].value_counts()
ax.legend(handles=[Patch(color=col, label=f"{name}: {counts.get(k, 0)} case{'s' if counts.get(k, 0) != 1 else ''}") for k, (name, col) in CLASSES.items()],
          frameon=False, fontsize=8.5, loc="lower right")
ax.set_title("Where the money was lost: root cause of twelve major thefts, 2021-2026", fontsize=11, loc="left")
fig.tight_layout()
fig.savefig(os.path.join(RES, "fig_incidents.png"), dpi=170)

tot = df.groupby("class").loss_usd_m.agg(["count", "sum"])
with open(os.path.join(RES, "incidents_summary.md"), "w") as fh:
    fh.write("| Root-cause class | Cases | Reported loss (US$ m) | Share of listed losses |\n|---|---|---|---|\n")
    for k, (name, _) in CLASSES.items():
        c, s = (int(tot.loc[k, "count"]), float(tot.loc[k, "sum"])) if k in tot.index else (0, 0.0)
        fh.write(f"| {name} | {c} | {s:,.0f} | {100 * s / df.loss_usd_m.sum():.1f}% |\n")
    fh.write(f"| **Total** | {len(df)} | {df.loss_usd_m.sum():,.0f} | |\n")
print(open(os.path.join(RES, "incidents_summary.md")).read())
