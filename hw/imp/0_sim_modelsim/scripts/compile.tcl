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

vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/rtl/top_level/multsigned/AdderN.sv
vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/rtl/top_level/multsigned/Encoder.sv
vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/rtl/top_level/multsigned/Extender.sv
vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/rtl/top_level/multsigned/Mux9x1.sv
vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/rtl/top_level/multsigned/Shifter1.sv
vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/rtl/top_level/multsigned/Shifter2.sv

vlog -work work $env(HUAWEI_CODE)/ai_core/hw/src/rtl/top_level/multsigned.sv
