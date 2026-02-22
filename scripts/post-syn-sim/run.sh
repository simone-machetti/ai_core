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
    -GIN_SIZE_0=${SEL_IN_SIZE_0} \
    -GIN_SIZE_1=${SEL_IN_SIZE_1} \
    --top-module tb_${SEL_TOP_LEVEL} \
    -DPOST_SYNTH=1 \
    --x-initial fast \
    --x-assign fast \
    -f "${CODE_HOME}/ai_core/scripts/post-syn-sim/filelist.f" \
       "${CODE_HOME}/ai_core/tb/tb_${SEL_TOP_LEVEL}.sv" \
    -Mdir "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/obj_dir" \
    -o "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/simv"

exec "${CODE_HOME}/ai_core/sim/${SEL_OUT_DIR}/build/simv" "$@"

# Add option --trace-fst to verilator command for FST generation.
