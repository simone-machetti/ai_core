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
    --trace-fst \
    -Wall \
    -Wno-fatal \
    --top-module testbench \
    -f "${HUAWEI_CODE}/ai_core/hw/imp/0_sim_verilator/scripts/filelist.f" \
    -Mdir "${HUAWEI_CODE}/ai_core/hw/imp/0_sim_verilator/build/obj_dir" \
    -o "${HUAWEI_CODE}/ai_core/hw/imp/0_sim_verilator/build/simv"

exec "${HUAWEI_CODE}/ai_core/hw/imp/0_sim_verilator/build/simv" "$@"
