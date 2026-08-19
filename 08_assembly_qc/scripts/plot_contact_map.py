#!/usr/bin/env python3
"""
Labelled Omni-C contact map for H. glaberrima, built from mapped.pairs
(PretextSnapshot's raster has no axes or legend). Sequential single-hue log
color scale — contact count is a magnitude, not a category.
"""
import sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, LogNorm

BIN = 1_000_000
CHR_TSV = sys.argv[1]
MATRIX  = sys.argv[2]
OUTBASE = sys.argv[3]

# --- documented sequential ramp: blue, steps 100 -> 700, light -> dark --------
BLUE = ["#cde2fb", "#b7d3f6", "#9ec5f4", "#86b6ef", "#6da7ec", "#5598e7",
        "#3987e5", "#2a78d6", "#256abf", "#1c5cab", "#184f95", "#104281",
        "#0d366b"]
SURFACE = "#ffffff"
INK, INK_MUTED, GRID = "#1a1a1a", "#5c5c5c", "#d8d8d8"

cmap = LinearSegmentedColormap.from_list("seq_blue", [SURFACE] + BLUE, N=512)
cmap.set_bad(SURFACE)

# --- geometry ----------------------------------------------------------------
names, lens = [], []
for line in open(CHR_TSV):
    n, l = line.split()
    names.append(n); lens.append(int(l))
nbins = [l // BIN + 1 for l in lens]
offs, cum = [], 0
for nb in nbins:
    offs.append(cum); cum += nb
TOT = cum

M = np.zeros((TOT, TOT), dtype=np.float64)
for line in open(MATRIX):
    i, j, c = line.split()
    i, j, c = int(i), int(j), float(c)
    M[i, j] += c
    if i != j:
        M[j, i] += c

total_contacts = M.sum() / 2
Mm = np.ma.masked_where(M <= 0, M)

# --- dynamic range -----------------------------------------------------------
# Floor vmin at the trans-contact median, not 1, so the trans background
# recedes to the light end instead of saturating the whole map.
lab = np.zeros(TOT, dtype=int)
for k, (o, nb_) in enumerate(zip(offs, nbins)):
    lab[o:o + nb_] = k
same = lab[:, None] == lab[None, :]
trans_med = float(np.median(M[~same]))
cis_off = M[same & ~np.eye(TOT, dtype=bool)]
vmin = max(trans_med, 1.0)
vmax = float(np.percentile(cis_off, 99))

# --- figure ------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(11.5, 10.0), dpi=300)
fig.patch.set_facecolor(SURFACE); ax.set_facecolor(SURFACE)

im = ax.imshow(Mm, cmap=cmap, norm=LogNorm(vmin=vmin, vmax=vmax),
               interpolation="nearest", origin="upper")

# recessive chromosome boundaries -- neutral gray reads on both the light
# background and the dark diagonal blocks (white would vanish on the blocks)
for o in offs[1:]:
    ax.axhline(o - 0.5, color="#8f8f8f", lw=0.45, zorder=3)
    ax.axvline(o - 0.5, color="#8f8f8f", lw=0.45, zorder=3)
for spine in ax.spines.values():
    spine.set_edgecolor(GRID); spine.set_linewidth(0.8)

centres = [offs[i] + nbins[i] / 2 for i in range(len(names))]
labels = [n.replace("Hglab_", "") for n in names]
ax.set_xticks(centres); ax.set_xticklabels(labels, fontsize=8, color=INK_MUTED)
ax.set_yticks(centres); ax.set_yticklabels(labels, fontsize=8, color=INK_MUTED)
ax.tick_params(length=0, pad=4)

ax.set_xlabel("Chromosome-scale scaffold  (ordered by length; tick = scaffold midpoint)",
              fontsize=10, color=INK, labelpad=10)
ax.set_ylabel("Chromosome-scale scaffold", fontsize=10, color=INK, labelpad=10)
ax.set_title("Omni-C contact map — $\\it{Holothuria\\ glaberrima}$",
             fontsize=14, color=INK, pad=30, loc="left", fontweight="bold")
ax.text(0.0, 1.018,
        f"{total_contacts/1e6:.1f} M valid contacts  ·  {BIN//1000:,} kb bins  ·  "
        f"23 scaffolds spanning {sum(lens)/1e9:.2f} Gb (93.6% of assembly)  ·  "
        f"scale floored at the inter-scaffold median ({vmin:.0f})",
        transform=ax.transAxes, fontsize=9, color=INK_MUTED, va="bottom")

cb = fig.colorbar(im, ax=ax, fraction=0.040, pad=0.02, extend="max")
cb.set_label(f"Contacts per {BIN//1000:,} kb × {BIN//1000:,} kb bin  (log scale)",
             fontsize=9.5, color=INK)
cb.ax.tick_params(labelsize=8, colors=INK_MUTED, length=2)
cb.outline.set_edgecolor(GRID); cb.outline.set_linewidth(0.6)

fig.tight_layout()
for ext in ("png", "pdf"):
    fig.savefig(f"{OUTBASE}.{ext}", dpi=300, facecolor=SURFACE, bbox_inches="tight")
print(f"wrote {OUTBASE}.png and {OUTBASE}.pdf")
print(f"matrix {TOT}x{TOT} bins, {total_contacts:,.0f} contacts, vmax(99.9pct)={vmax:.0f}")
