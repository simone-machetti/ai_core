# Copyright 2023 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Simone Machetti - simone.machetti@epfl.ch

set REPORT_DIR $env(HUAWEI_CODE)/ai_core/hw/imp/4_post-syn-dpa_opensta/report

# -----------------------------------------------------------------------------
# Libraries (timing/power models)
# -----------------------------------------------------------------------------
read_liberty $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib
read_liberty $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib
read_liberty $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib
read_liberty $env(HUAWEI_TOOLS)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib

# -----------------------------------------------------------------------------
# Netlist & top-level linking
# -----------------------------------------------------------------------------
read_verilog $env(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/output/netlist.v
link_design multsigned

# -----------------------------------------------------------------------------
# Virtual clock & I/O constraints (required to avoid "No clocks defined")
# -----------------------------------------------------------------------------
create_clock -name vclk -period 1000
set_input_delay 0 -clock vclk [all_inputs]
set_output_delay 0 -clock vclk [all_outputs]

# -----------------------------------------------------------------------------
# VCD-based switching activity
# -----------------------------------------------------------------------------
read_vcd -scope testbench/multsigned_i $env(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_verilator/output/activity.vcd

report_activity_annotation -report_annotated   > $REPORT_DIR/vcd_annotated.rpt
report_activity_annotation -report_unannotated > $REPORT_DIR/vcd_unannotated.rpt

# -----------------------------------------------------------------------------
# Power reports
# -----------------------------------------------------------------------------
report_power > $REPORT_DIR/power_summary.rpt
# report_units
