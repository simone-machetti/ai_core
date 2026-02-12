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

source $env(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/scripts/compile.tcl

vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/tb/testbench.sv

vsim -gui -wlf $env(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/build/build.wlf work.testbench -voptargs="+acc"

if {!$env(SEL_SIM_GUI)} {
run -all
exit
}
