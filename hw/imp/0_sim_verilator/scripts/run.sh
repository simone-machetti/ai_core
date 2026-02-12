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
        --top-module testbench \
        -f "${CODE_HOME}/ai_core/hw/imp/0_sim_verilator/scripts/filelist.f" \
        -Mdir "${CODE_HOME}/ai_core/hw/imp/0_sim_verilator/build/obj_dir" \
        -o "${CODE_HOME}/ai_core/hw/imp/0_sim_verilator/build/simv"

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
        --top-module testbench \
        -f "${CODE_HOME}/ai_core/hw/imp/0_sim_verilator/scripts/filelist.f" \
        -Mdir "${CODE_HOME}/ai_core/hw/imp/0_sim_verilator/build/obj_dir" \
        -o "${CODE_HOME}/ai_core/hw/imp/0_sim_verilator/build/simv"

fi

exec "${CODE_HOME}/ai_core/hw/imp/0_sim_verilator/build/simv" "$@"
