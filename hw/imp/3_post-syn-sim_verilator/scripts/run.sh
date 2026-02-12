# -----------------------------------------------------------------------------
# Confidential and Proprietary Information
#
# This file contains confidential and proprietary information of
# Huawei Technologies Co., Ltd.
#
# Unauthorized copying, distribution, modification, or disclosure of this
# file, in whole or in part, is strictly prohibited without prior written
# permission from Huawei Technologies Co., Ltd.
#
# This material is provided for internal use only and must not be shared
# with third parties.
#
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
    -f "${HUAWEI_CODE}/ai_core/hw/imp/3_post-syn-sim_verilator/scripts/filelist.f" \
    -Mdir "${HUAWEI_CODE}/ai_core/hw/imp/3_post-syn-sim_verilator/build/obj_dir" \
    -o "${HUAWEI_CODE}/ai_core/hw/imp/3_post-syn-sim_verilator/build/simv"

exec "${HUAWEI_CODE}/ai_core/hw/imp/3_post-syn-sim_verilator/build/simv" "$@"

# Add option --trace-fst to verilator command for FST generation.
