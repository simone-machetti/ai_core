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
CSV  = os.path.join(_DIR, '..', '..', 'data', 'power', 'power.csv')

C_BAS = "#97665b"
C_PWR = "#005f73"

def load():
    with open(CSV) as f:
        rows = list(csv.DictReader(f))
    names  = [r['design'] for r in rows]
    powers = np.array([float(r['power_mw']) for r in rows])
    return names, powers

def main():
    names, powers = load()
    x      = np.arange(len(names))
    width  = 0.5
    colors = [C_BAS] + [C_PWR] * (len(names) - 1)

    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(x, powers, width, color=colors)

    for i, p in enumerate(powers):
        if i == 0:
            ax.text(x[i], p * 1.01, f"{p:.2f} mW", ha="center", va="bottom", fontsize=9)
        else:
            pct = (p - powers[0]) / powers[0] * 100.0
            ax.text(x[i], p * 1.01, f"{pct:+.1f}%", ha="center", va="bottom", fontsize=9)

    ax.set_ylim(0, max(powers) * 1.20)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=15, ha='right')
    ax.set_ylabel("Power (mW)")
    ax.set_title("Power Analysis: PE Level")
    ax.legend(handles=[Patch(color=C_BAS, label="Baseline 4x8"),
                       Patch(color=C_PWR, label="Other")])
    plt.tight_layout()
    plt.savefig("pwr_pe_level.png", dpi=200)

if __name__ == "__main__":
    main()
