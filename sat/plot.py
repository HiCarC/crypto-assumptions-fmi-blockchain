#!/usr/bin/env python3
"""Figures for the SAT experiment, from results/sat_scaling.csv. No extrapolation is drawn."""
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results")
df = pd.read_csv(os.path.join(RES, "sat_scaling.csv"))
timeout = df.loc[df.status == "TIMEOUT", "seconds"].max()
colors = {"kissat": "#1b6ca8", "cadical": "#c0392b", "cryptominisat": "#2e8b57"}

fig, axes = plt.subplots(1, 3, figsize=(15, 4.6))

a = df[df.sweep == "A_rounds"]
size = a.groupby("rounds")[["variables", "clauses"]].first()
axes[0].plot(size.index, size.variables / 1e3, "o-", color="#444", label="variables")
axes[0].plot(size.index, size.clauses / 1e3, "s--", color="#999", label="clauses")
axes[0].set(title="A. Size of the encoded problem", xlabel="SHA-256 rounds (full function: 64)", ylabel="thousands")
axes[0].legend(frameon=False)

for ax, sweep, x, xlabel, title in (
    (axes[1], "A_rounds", "rounds", "SHA-256 rounds, all 512 message bits unknown", "B. Solver time as rounds increase"),
    (axes[2], "B_unknown_bits", "unknown_bits", "unknown message bits, full 64 rounds", "C. Solver time at full rounds"),
):
    d = df[df.sweep == sweep]
    for solver, g in d.groupby("solver"):
        ok = g[g.status == "SAT"]
        to = g[g.status == "TIMEOUT"]
        ax.scatter(ok[x], ok.seconds, s=22, color=colors[solver], label=solver, alpha=0.85)
        ax.scatter(to[x], to.seconds, s=38, color=colors[solver], marker="x")
    if pd.notna(timeout):
        ax.axhline(timeout, color="#bbb", lw=0.8, ls=":")
        ax.text(d[x].min(), timeout * 1.08, f"time limit {timeout:.0f} s (x = not solved)", fontsize=8, color="#777")
    ax.set(yscale="log", xlabel=xlabel, ylabel="seconds (log scale)", title=title)
    ax.legend(frameon=False, fontsize=8)

for ax in axes:
    ax.spines[["top", "right"]].set_visible(False)
fig.tight_layout()
out = os.path.join(RES, "fig_sat_scaling.png")
fig.savefig(out, dpi=170)
print("wrote", out)

summary = (
    df.assign(solved=df.status == "SAT")
    .groupby(["sweep", "rounds", "unknown_bits", "solver"])
    .agg(variables=("variables", "first"), clauses=("clauses", "first"), solved=("solved", "sum"), n=("solved", "size"),
         median_seconds=("seconds", "median"))
    .reset_index()
)
summary.to_csv(os.path.join(RES, "sat_summary.csv"), index=False)
print(summary.to_string(index=False), file=sys.stderr)

# Article version: two panels, plain labels, no figure title (the caption carries the message).
fig, axes = plt.subplots(1, 2, figsize=(10.5, 4.2), sharey=True)
for ax, sweep, x, xlabel, title in (
    (axes[0], "A_rounds", "rounds", "rounds of SHA-256 (the full function has 64)", "Whole input unknown"),
    (axes[1], "B_unknown_bits", "unknown_bits", "number of hidden input bits", "Full 64 rounds, a few bits hidden"),
):
    d = df[df.sweep == sweep]
    for solver, g in d.groupby("solver"):
        ok, to = g[g.status == "SAT"], g[g.status == "TIMEOUT"]
        ax.scatter(ok[x], ok.seconds, s=24, color=colors[solver], label=solver, alpha=0.85)
        ax.scatter(to[x], to.seconds, s=40, color=colors[solver], marker="x")
    ax.axhline(timeout, color="#bbb", lw=0.8, ls=":")
    ax.set(yscale="log", xlabel=xlabel, title=title)
    ax.spines[["top", "right"]].set_visible(False)
axes[0].set_ylabel("seconds to find an input (log scale)")
axes[0].text(12, timeout * 1.12, f"{timeout:.0f}-second limit; x = not found", fontsize=8, color="#666")
axes[1].legend(frameon=False, fontsize=8, loc="lower right")
fig.tight_layout()
fig.savefig(os.path.join(RES, "fig_sat_article.png"), dpi=170)
print("wrote", os.path.join(RES, "fig_sat_article.png"))
