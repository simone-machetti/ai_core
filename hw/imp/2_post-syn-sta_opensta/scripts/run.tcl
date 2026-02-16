# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

set REPORT_DIR $env(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta/report

# -----------------------------------------------------------------------------
# Libraries (timing models)
# -----------------------------------------------------------------------------
read_liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib
read_liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib
read_liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib
read_liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib

# -----------------------------------------------------------------------------
# Netlist + top-level linking
# -----------------------------------------------------------------------------
read_verilog $env(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/output/netlist.v
link_design baseline

# -----------------------------------------------------------------------------
# Constraints (combinational I/O timing)
# -----------------------------------------------------------------------------
set_max_delay 1000 -from [all_inputs] -to [all_outputs]
set_input_transition 50 [all_inputs]
set_load 20 [all_outputs]

# -----------------------------------------------------------------------------
# Reports generation
# -----------------------------------------------------------------------------
report_checks -unconstrained > $REPORT_DIR/unconstrained.rpt
report_checks \
    -path_delay max \
    -fields {slew cap input_pins} \
    -digits 4 \
    -group_count 10 \
    > $REPORT_DIR/critical_paths.rpt
report_wns > $REPORT_DIR/wns.rpt
report_tns > $REPORT_DIR/tns.rpt
# report_units
