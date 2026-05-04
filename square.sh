#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

set -uo pipefail

PASS=0
FAIL=0
RESULTS=()

run() {
    local desc="$1"
    shift
    if make "$@" > /dev/null 2>&1; then
        RESULTS+=("  PASS  $desc")
        ((PASS++))
    else
        RESULTS+=("  FAIL  $desc")
        ((FAIL++))
    fi
}

CLK=1.35

# -----------------------------------------------------------------------------
# Baseline 4x8
# -----------------------------------------------------------------------------
run "sim          Baseline 4x8"  sim          TOP_LEVEL=bas_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=bas_4x8_sim                                    PARAMS="IS_PIPELINED=1 MULT_TYPE=0"
run "syn          Baseline 4x8"  syn          TOP_LEVEL=bas_4x8_top                      OUT_DIR=bas_4x8_syn                                    PARAMS="IS_PIPELINED=1 MULT_TYPE=0"
run "post-syn-sim Baseline 4x8"  post-syn-sim TOP_LEVEL=bas_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=bas_4x8_post_syn_sim  NETLIST_DIR=bas_4x8_syn  PARAMS="IS_PIPELINED=1 MULT_TYPE=0"
run "post-syn-sta Baseline 4x8"  post-syn-sta TOP_LEVEL=bas_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=bas_4x8_post_syn_sta  NETLIST_DIR=bas_4x8_syn
run "post-syn-dpa Baseline 4x8"  post-syn-dpa TOP_LEVEL=bas_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=bas_4x8_post_syn_dpa  NETLIST_DIR=bas_4x8_syn  VCD_DIR=bas_4x8_post_syn_sim

# -----------------------------------------------------------------------------
# Square 4x8 SC
# -----------------------------------------------------------------------------
run "sim          Square 4x8 SC"  sim          TOP_LEVEL=sqr_4x8_sc_top  CLK_PERIOD_NS=$CLK  OUT_DIR=sqr_4x8_sc_sim                                          PARAMS="IS_PIPELINED=1"
run "syn          Square 4x8 SC"  syn          TOP_LEVEL=sqr_4x8_sc_top                      OUT_DIR=sqr_4x8_sc_syn                                          PARAMS="IS_PIPELINED=1"
run "post-syn-sim Square 4x8 SC"  post-syn-sim TOP_LEVEL=sqr_4x8_sc_top  CLK_PERIOD_NS=$CLK  OUT_DIR=sqr_4x8_sc_post_syn_sim  NETLIST_DIR=sqr_4x8_sc_syn  PARAMS="IS_PIPELINED=1"
run "post-syn-sta Square 4x8 SC"  post-syn-sta TOP_LEVEL=sqr_4x8_sc_top  CLK_PERIOD_NS=$CLK  OUT_DIR=sqr_4x8_sc_post_syn_sta  NETLIST_DIR=sqr_4x8_sc_syn
run "post-syn-dpa Square 4x8 SC"  post-syn-dpa TOP_LEVEL=sqr_4x8_sc_top  CLK_PERIOD_NS=$CLK  OUT_DIR=sqr_4x8_sc_post_syn_dpa  NETLIST_DIR=sqr_4x8_sc_syn  VCD_DIR=sqr_4x8_sc_post_syn_sim

# -----------------------------------------------------------------------------
# Alpha
# -----------------------------------------------------------------------------
run "sim          Alpha"  sim          TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_sim                                  PARAMS="IS_PIPELINED=1 IS_SQUARE=0"
run "syn          Alpha"  syn          TOP_LEVEL=sqr_4x8_sc_alpha_top                      OUT_DIR=alpha_syn                                  PARAMS="IS_PIPELINED=1 IS_SQUARE=0"
run "post-syn-sim Alpha"  post-syn-sim TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_post_syn_sim  NETLIST_DIR=alpha_syn  PARAMS="IS_PIPELINED=1 IS_SQUARE=0"
run "post-syn-sta Alpha"  post-syn-sta TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_post_syn_sta  NETLIST_DIR=alpha_syn
run "post-syn-dpa Alpha"  post-syn-dpa TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_post_syn_dpa  NETLIST_DIR=alpha_syn  VCD_DIR=alpha_post_syn_sim

# -----------------------------------------------------------------------------
# Alpha Squared
# -----------------------------------------------------------------------------
run "sim          Alpha Squared"  sim          TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_sqr_sim                                      PARAMS="IS_PIPELINED=1 IS_SQUARE=1"
run "syn          Alpha Squared"  syn          TOP_LEVEL=sqr_4x8_sc_alpha_top                      OUT_DIR=alpha_sqr_syn                                      PARAMS="IS_PIPELINED=1 IS_SQUARE=1"
run "post-syn-sim Alpha Squared"  post-syn-sim TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_sqr_post_syn_sim  NETLIST_DIR=alpha_sqr_syn  PARAMS="IS_PIPELINED=1 IS_SQUARE=1"
run "post-syn-sta Alpha Squared"  post-syn-sta TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_sqr_post_syn_sta  NETLIST_DIR=alpha_sqr_syn
run "post-syn-dpa Alpha Squared"  post-syn-dpa TOP_LEVEL=sqr_4x8_sc_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=alpha_sqr_post_syn_dpa  NETLIST_DIR=alpha_sqr_syn  VCD_DIR=alpha_sqr_post_syn_sim

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "Regression results:"
echo "-------------------"
for r in "${RESULTS[@]}"; do
    echo "$r"
done
echo "-------------------"
echo "PASS: $PASS  FAIL: $FAIL  TOTAL: $((PASS + FAIL))"
echo ""

[ $FAIL -eq 0 ]
