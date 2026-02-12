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
    --top-module testbench \
    -DPOST_SYNTH=1 \
    --x-initial fast \
    --x-assign fast \
    -f "${CODE_HOME}/ai_core/hw/imp/3_post-syn-sim_verilator/scripts/filelist.f" \
    -Mdir "${CODE_HOME}/ai_core/hw/imp/3_post-syn-sim_verilator/build/obj_dir" \
    -o "${CODE_HOME}/ai_core/hw/imp/3_post-syn-sim_verilator/build/simv"

exec "${CODE_HOME}/ai_core/hw/imp/3_post-syn-sim_verilator/build/simv" "$@"

# Add option --trace-fst to verilator command for FST generation.
