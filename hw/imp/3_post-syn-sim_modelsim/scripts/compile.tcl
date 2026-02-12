# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

vlib work

vlog -work work $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_SEQ_RVT_TT_220101.v
vlog -work work $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_AO_RVT_TT_201020.v
vlog -work work $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_INVBUF_RVT_TT_201020.v
vlog -work work $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/verilog/stdcell/asap7sc7p5t_SIMPLE_RVT_TT_201020.v

vlog -work work $env(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/output/netlist.v
