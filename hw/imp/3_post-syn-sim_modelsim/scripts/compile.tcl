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

vlib work

vlog -work work $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_SEQ_RVT_TT_220101.v
vlog -work work $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_AO_RVT_TT_201020.v
vlog -work work $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_INVBUF_RVT_TT_201020.v
vlog -work work $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_SIMPLE_RVT_TT_201020.v

vlog -work work $env(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/output/netlist.v
