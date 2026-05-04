#!/usr/bin/env python3

# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

import os
import csv
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

_DIR = os.path.dirname(os.path.abspath(__file__))
CSV  = os.path.join(_DIR, '..', '..', 'data', 'area', 'area.csv')

C_BAS   = "#97665b"
C_SQR   = "#005f73"
C_ALPHA = "#97bdc5"

def load():
    with open(CSV) as f:
        return {r['design']: float(r['area_um2']) for r in csv.DictReader(f)}

def main():
    d         = load()
    bas_total = 256 * d['Baseline 4x8']
    sqr_pe    = 256 * d['Square 4x8 SC']
    alpha_tot = 16  * (4 * d['Alpha Squared'] + 3 * d['Alpha'])
    sqr_total = sqr_pe + alpha_tot

    x     = np.array([0, 1])
    width = 0.5

    fig, ax = plt.subplots(figsize=(7, 5))
    ax.bar(x[0], bas_total,  width, color=C_BAS)
    ax.bar(x[1], sqr_pe,     width, color=C_SQR)
    ax.bar(x[1], alpha_tot,  width, bottom=sqr_pe, color=C_ALPHA)

    pct = (sqr_total - bas_total) / bas_total * 100.0
    ax.text(x[0], bas_total  * 1.01, f"{bas_total:.0f} µm²", ha="center", va="bottom", fontsize=9)
    ax.text(x[1], sqr_total  * 1.01, f"{pct:+.1f}%",          ha="center", va="bottom", fontsize=9)

    ax.set_ylim(0, max(bas_total, sqr_total) * 1.40)
    ax.set_xticks(x)
    ax.set_xticklabels(['Baseline 4x8', 'Square 4x8 SC'])
    ax.set_ylabel("Area (µm²)")
    ax.set_title("Area Analysis: AI-Core Level")
    ax.legend(handles=[
        Patch(color=C_BAS,   label="PE Baseline 4x8 ×256"),
        Patch(color=C_SQR,   label="PE Square 4x8 SC ×256"),
        Patch(color=C_ALPHA, label="16× (4× Alpha Sqr + 3× Alpha)"),
    ])
    plt.tight_layout()
    plt.savefig("area_ai_core_level.png", dpi=200)

if __name__ == "__main__":
    main()
