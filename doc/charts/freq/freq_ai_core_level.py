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
CSV  = os.path.join(_DIR, '..', '..', 'data', 'freq', 'freq.csv')

C_BAS = "#97665b"
C_SQR = "#005f73"

def load():
    with open(CSV) as f:
        return {r['design']: float(r['freq_mhz']) / 1000.0 for r in csv.DictReader(f)}  # GHz

def main():
    d        = load()
    bas_fmax = d['Baseline 4x8']
    sqr_fmax = min(d['Square 4x8 SC'], d['Alpha'], d['Alpha Squared'])

    x     = np.array([0, 1])
    width = 0.5

    fig, ax = plt.subplots(figsize=(7, 5))
    ax.bar(x[0], bas_fmax, width, color=C_BAS)
    ax.bar(x[1], sqr_fmax, width, color=C_SQR)

    pct = (sqr_fmax - bas_fmax) / bas_fmax * 100.0
    ax.text(x[0], bas_fmax * 1.01, f"{bas_fmax:.3f} GHz", ha="center", va="bottom", fontsize=9)
    ax.text(x[1], sqr_fmax * 1.01, f"{pct:+.1f}%",         ha="center", va="bottom", fontsize=9)

    ax.set_ylim(0, max(bas_fmax, sqr_fmax) * 1.40)
    ax.set_xticks(x)
    ax.set_xticklabels(['Baseline 4x8', 'Square 4x8 SC'])
    ax.set_ylabel("f_max (GHz)")
    ax.set_title("Frequency Analysis: AI-Core Level")
    ax.legend(handles=[
        Patch(color=C_BAS, label="Baseline 4x8 (bottleneck: PE Baseline 4x8)"),
        Patch(color=C_SQR, label="Square 4x8 SC (bottleneck: PE Square 4x8 SC)"),
    ])
    plt.tight_layout()
    plt.savefig("freq_ai_core_level.png", dpi=200)

if __name__ == "__main__":
    main()
