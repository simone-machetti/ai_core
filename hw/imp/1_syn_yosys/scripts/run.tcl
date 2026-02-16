# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Load RTL + technology (compile.tcl is a Tcl file -> use Tcl 'source')
# -----------------------------------------------------------------------------

source $env(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/scripts/compile.tcl

# -----------------------------------------------------------------------------
# Override top parameters
# -----------------------------------------------------------------------------
# yosys "chparam -set IN_SIZE_0 $env(SEL_IN_SIZE_0) -set IN_SIZE_1 $env(SEL_IN_SIZE_1) baseline"

# -----------------------------------------------------------------------------
# Elaboration / hierarchy
# -----------------------------------------------------------------------------
yosys "hierarchy -check -top baseline"
# yosys "rename -top baseline"
yosys "check"

# -----------------------------------------------------------------------------
# Synthesis & optimizations
# -----------------------------------------------------------------------------
yosys "proc"
yosys "opt"
yosys "fsm"
yosys "opt"
yosys "memory"
yosys "opt"
yosys "techmap"
yosys "opt"

# -----------------------------------------------------------------------------
# Technology mapping
# -----------------------------------------------------------------------------
yosys "dfflibmap -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib"
yosys "opt"

yosys "abc \
  -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib \
  -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib \
  -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib \
  -script  $env(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/scripts/abc.tcl"

yosys "opt"
yosys "clean"

# -----------------------------------------------------------------------------
# Generate cells reports
# -----------------------------------------------------------------------------
yosys "tee -o $env(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/report/cell_SIMPLE.rpt stat \
  -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib"

# -----------------------------------------------------------------------------
# Flatten & optimize & clean
# -----------------------------------------------------------------------------
yosys "flatten"
yosys "opt_clean"
yosys "rename -hide"

yosys "tee -o $env(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/report/cell_SIMPLE_flat.rpt stat \
  -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib"

# -----------------------------------------------------------------------------
# Write synthesized netlist
# -----------------------------------------------------------------------------
yosys "write_verilog -noattr -noexpr -nodec $env(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/output/netlist.v"
