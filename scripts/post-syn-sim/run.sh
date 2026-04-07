#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

set -euo pipefail

verilator \
    -sv \
    --binary \
    --timing \
    --trace \
    --trace-max-array 0 \
    --trace-max-width 0 \
    -Wall \
    -Wno-fatal \
    -DPOST_SYN_SIM \
    -DVCD \
    -DCLK_PERIOD_NS="${SEL_CLK_PERIOD_NS}" \
    -GMULT_TYPE="${SEL_MULT_TYPE}" \
    --top-module "tb_${SEL_TOP_LEVEL}" \
    -DPOST_SYNTH=1 \
    --x-initial fast \
    --x-assign fast \
    -f "${CODE_HOME}/ai-core/scripts/post-syn-sim/filelist.f" \
       "${CODE_HOME}/ai-core/tb/tb_${SEL_TOP_LEVEL}.sv" \
    -Mdir "${CODE_HOME}/ai-core/sim/${SEL_OUT_DIR}/build/obj_dir" \
    -o "${CODE_HOME}/ai-core/sim/${SEL_OUT_DIR}/build/simv" \
    | tee "${CODE_HOME}/ai-core/sim/${SEL_OUT_DIR}/output/compile.log"

exec "${CODE_HOME}/ai-core/sim/${SEL_OUT_DIR}/build/simv" "$@" \
    | tee "${CODE_HOME}/ai-core/sim/${SEL_OUT_DIR}/output/run.log"

# Add option --trace-fst to verilator command for FST generation.
