# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

#!/usr/bin/env bash
set -euo pipefail

if [[ "${SEL_SIM_GUI:-0}" -eq 0 ]]; then

    verilator \
        -sv \
        --binary \
        --timing \
        --trace \
        -Wall \
        -Wno-fatal \
        -GIN_SIZE_0=${SEL_IN_SIZE_0} \
        -GIN_SIZE_1=${SEL_IN_SIZE_1} \
        --top-module tb_${SEL_TOP_LEVEL} \
        -f "${CODE_HOME}/ai_core/scripts/sim/filelist.f" \
           "${CODE_HOME}/ai_core/tb/tb_${SEL_TOP_LEVEL}.sv" \
        -Mdir "${CODE_HOME}/ai_core/scripts/sim/build/obj_dir" \
        -o "${CODE_HOME}/ai_core/scripts/sim/build/simv"

else

    verilator \
        -sv \
        --binary \
        --timing \
        --trace \
        -Wall \
        -Wno-fatal \
        -DVCD \
        -GIN_SIZE_0=${SEL_IN_SIZE_0} \
        -GIN_SIZE_1=${SEL_IN_SIZE_1} \
        --top-module tb_${SEL_TOP_LEVEL} \
        -f "${CODE_HOME}/ai_core/scripts/sim/filelist.f" \
           "${CODE_HOME}/ai_core/tb/tb_${SEL_TOP_LEVEL}.sv" \
        -Mdir "${CODE_HOME}/ai_core/scripts/sim/build/obj_dir" \
        -o "${CODE_HOME}/ai_core/scripts/sim/build/simv"

fi

exec "${CODE_HOME}/ai_core/scripts/sim/build/simv" "$@"
