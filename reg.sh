#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

set -uo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/sourceme.sh"

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

CLK=1

# -----------------------------------------------------------------------------
# bas_4x4_top
# -----------------------------------------------------------------------------
run "sim  bas_4x4_top  R4"  sim  TOP_LEVEL=bas_4x4_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_bas_4x4_r4  PARAMS="MULT_TYPE=0"
run "sim  bas_4x4_top  R8"  sim  TOP_LEVEL=bas_4x4_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_bas_4x4_r8  PARAMS="MULT_TYPE=1"
run "syn  bas_4x4_top  R4"  syn  TOP_LEVEL=bas_4x4_top                      OUT_DIR=reg_bas_4x4_r4  PARAMS="MULT_TYPE=0"
run "syn  bas_4x4_top  R8"  syn  TOP_LEVEL=bas_4x4_top                      OUT_DIR=reg_bas_4x4_r8  PARAMS="MULT_TYPE=1"

# -----------------------------------------------------------------------------
# bas_4x8_top
# -----------------------------------------------------------------------------
run "sim  bas_4x8_top  R4"  sim  TOP_LEVEL=bas_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_bas_4x8_r4  PARAMS="MULT_TYPE=0"
run "sim  bas_4x8_top  R8"  sim  TOP_LEVEL=bas_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_bas_4x8_r8  PARAMS="MULT_TYPE=1"
run "syn  bas_4x8_top  R4"  syn  TOP_LEVEL=bas_4x8_top                      OUT_DIR=reg_bas_4x8_r4  PARAMS="MULT_TYPE=0"
run "syn  bas_4x8_top  R8"  syn  TOP_LEVEL=bas_4x8_top                      OUT_DIR=reg_bas_4x8_r8  PARAMS="MULT_TYPE=1"

# -----------------------------------------------------------------------------
# win_4x4_top
# -----------------------------------------------------------------------------
run "sim  win_4x4_top  R4"  sim  TOP_LEVEL=win_4x4_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_win_4x4_r4  PARAMS="MULT_TYPE=0"
run "sim  win_4x4_top  R8"  sim  TOP_LEVEL=win_4x4_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_win_4x4_r8  PARAMS="MULT_TYPE=1"
run "syn  win_4x4_top  R4"  syn  TOP_LEVEL=win_4x4_top                      OUT_DIR=reg_win_4x4_r4  PARAMS="MULT_TYPE=0"
run "syn  win_4x4_top  R8"  syn  TOP_LEVEL=win_4x4_top                      OUT_DIR=reg_win_4x4_r8  PARAMS="MULT_TYPE=1"

# -----------------------------------------------------------------------------
# win_4x8_top
# -----------------------------------------------------------------------------
run "sim  win_4x8_top  R4"  sim  TOP_LEVEL=win_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_win_4x8_r4  PARAMS="MULT_TYPE=0"
run "sim  win_4x8_top  R8"  sim  TOP_LEVEL=win_4x8_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_win_4x8_r8  PARAMS="MULT_TYPE=1"
run "syn  win_4x8_top  R4"  syn  TOP_LEVEL=win_4x8_top                      OUT_DIR=reg_win_4x8_r4  PARAMS="MULT_TYPE=0"
run "syn  win_4x8_top  R8"  syn  TOP_LEVEL=win_4x8_top                      OUT_DIR=reg_win_4x8_r8  PARAMS="MULT_TYPE=1"

# -----------------------------------------------------------------------------
# sqr_4x4_top (no MULT_TYPE)
# -----------------------------------------------------------------------------
run "sim  sqr_4x4_top"  sim  TOP_LEVEL=sqr_4x4_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_sqr_4x4
run "syn  sqr_4x4_top"  syn  TOP_LEVEL=sqr_4x4_top                      OUT_DIR=reg_sqr_4x4

# -----------------------------------------------------------------------------
# sqr_4x4_alpha_top (no MULT_TYPE)
# -----------------------------------------------------------------------------
run "sim  sqr_4x4_alpha_top  linear"  sim  TOP_LEVEL=sqr_4x4_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_sqr_4x4_alpha_lin  PARAMS="IS_SQUARE=0"
run "sim  sqr_4x4_alpha_top  square"  sim  TOP_LEVEL=sqr_4x4_alpha_top  CLK_PERIOD_NS=$CLK  OUT_DIR=reg_sqr_4x4_alpha_sqr  PARAMS="IS_SQUARE=1"
run "syn  sqr_4x4_alpha_top  linear"  syn  TOP_LEVEL=sqr_4x4_alpha_top                      OUT_DIR=reg_sqr_4x4_alpha_lin  PARAMS="IS_SQUARE=0"
run "syn  sqr_4x4_alpha_top  square"  syn  TOP_LEVEL=sqr_4x4_alpha_top                      OUT_DIR=reg_sqr_4x4_alpha_sqr  PARAMS="IS_SQUARE=1"

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
