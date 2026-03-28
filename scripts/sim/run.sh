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
    --trace-max-array 0 \
    --trace-max-width 0 \
    -Wall \
    -Wno-fatal \
    -DVCD \
    -DCLK_PERIOD_NS=${SEL_CLK_PERIOD_NS} \
    -GMULT_TYPE=${SEL_MULT_TYPE} \
    -I"${CODE_HOME}/ai_core/rtl" \
    --top-module tb_${SEL_TOP_LEVEL} \
    -f "${CODE_HOME}/ai_core/scripts/sim/filelist.f" \
    -Mdir "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/obj_dir" \
    -o "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/simv" \
    | tee "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/output/compile.log"

exec "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/simv" "$@" \
    | tee "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/output/run.log"
