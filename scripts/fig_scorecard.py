"""Scorecard graphic for the Chapter 2 article: four ledger layers vs. the October 3-SAT results."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

INK, MUTED, RULE, BG = "#1f2328", "#5b6470", "#d8dbe0", "#ffffff"
GOOD, GOOD_BG = "#1b7f5a", "#e3f2ec"
WATCH, WATCH_BG = "#8a5a00", "#fbf0d6"

rows = [
    ("1", "Hash functions", "SHA-256 vs. three top SAT solvers, 12 bits hidden:\nup to a minute; plain guessing takes milliseconds", "✓  HOLDS", GOOD, GOOD_BG),
    ("2", "Signatures", "How validators agree (PoS, PoA, BFT) and transfers\nare approved: elliptic curves, a different problem", "✓  HOLDS", GOOD, GOOD_BG),
    ("3", "Zero-knowledge proofs", "Rest on other assumptions; only research-only\nfunctions are touched", "✓  HOLDS*", GOOD, GOOD_BG),
    ("4", "Smart contracts", "The tools that prove contracts safe run on SAT-type\nsolvers: faster solvers help defenders and attackers", "!  TWIST", WATCH, WATCH_BG),
]

fig = plt.figure(figsize=(12, 6.75), dpi=150, facecolor=BG)
ax = fig.add_axes([0, 0, 1, 1]); ax.set_xlim(0, 1200); ax.set_ylim(0, 675); ax.axis("off")
ax.text(60, 615, "Did AI just break the blockchain?", fontsize=26, fontweight="bold", color=INK, va="center")
ax.text(60, 572, "Four ledger layers tested against October's 3-SAT results", fontsize=15, color=MUTED, va="center")
top, h = 520, 100
for i, (n, layer, detail, verdict, c, cbg) in enumerate(rows):
    y = top - i * (h + 8)
    ax.add_patch(FancyBboxPatch((60, y - h), 1080, h, boxstyle="round,pad=0,rounding_size=10", fc="#f6f7f9", ec="none"))
    ax.text(95, y - h / 2, n, fontsize=22, fontweight="bold", color=MUTED, va="center", ha="center")
    ax.text(135, y - h / 2 + 2, layer, fontsize=17, fontweight="bold", color=INK, va="center")
    ax.text(475, y - h / 2, detail, fontsize=12, color=INK, va="center", linespacing=1.4)
    ax.add_patch(FancyBboxPatch((935, y - h / 2 - 22), 180, 44, boxstyle="round,pad=0,rounding_size=8", fc=cbg, ec=c, lw=1.5))
    ax.text(1025, y - h / 2, verdict, fontsize=15, fontweight="bold", color=c, va="center", ha="center")
ax.text(60, 52, "Tested on an Ethereum-style (EVM) ledger, Stellar and Canton.   *Only research-only constructions are touched.",
        fontsize=11.5, color=MUTED, va="center")
ax.text(60, 25, "Code, tests and data: github.com/HiCarC/crypto-assumptions-fmi-blockchain  ·  TheKarlC",
        fontsize=11.5, color=MUTED, va="center")
fig.savefig("results/fig_scorecard.png", facecolor=BG)
print("ok")
