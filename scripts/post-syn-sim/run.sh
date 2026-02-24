# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

#!/usr/bin/env bash
set -euo pipefail

verilator \
    -sv \
    --binary \
    --timing \
    --trace \
    -Wall \
    -Wno-fatal \
    -DPOST_SYN_SIM \
    -DVCD \
    -DCLK_PERIOD_NS=${SEL_CLK_PERIOD_NS} \
    -GIN_SIZE_0=${SEL_IN_SIZE_0} \
    -GIN_SIZE_1=${SEL_IN_SIZE_1} \
    -GARRAY_SIZE=${SEL_ARRAY_SIZE} \
    --top-module tb_${SEL_TOP_LEVEL} \
    -DPOST_SYNTH=1 \
    --x-initial fast \
    --x-assign fast \
    -f "${CODE_HOME}/ai_core/scripts/post-syn-sim/filelist.f" \
       "${CODE_HOME}/ai_core/tb/tb_${SEL_TOP_LEVEL}.sv" \
    -Mdir "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/obj_dir" \
    -o "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/simv" \
    | tee "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/output/compile.log"

exec "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/simv" "$@" \
    | tee "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/output/run.log"

# Add option --trace-fst to verilator command for FST generation.
