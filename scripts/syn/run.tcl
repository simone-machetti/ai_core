# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Load RTL & technology
# -----------------------------------------------------------------------------
source $env(CODE_HOME)/ai_core/scripts/syn/compile.tcl

# -----------------------------------------------------------------------------
# Override top parameters
# -----------------------------------------------------------------------------
# yosys "chparam -set IN_SIZE_0 $env(SEL_IN_SIZE_0) -set IN_SIZE_1 $env(SEL_IN_SIZE_1) $env(SEL_TOP_LEVEL)"
# yosys "rename -top $env(SEL_TOP_LEVEL)"

# -----------------------------------------------------------------------------
# Elaboration / hierarchy
# -----------------------------------------------------------------------------
yosys "hierarchy -check -top $env(SEL_TOP_LEVEL)"
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
# yosys "extract_fa"
# yosys "techmap -map $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/yoSys/cells_adders_R.v"
yosys "techmap"
yosys "opt"

# -----------------------------------------------------------------------------
# Visualize netlist
# -----------------------------------------------------------------------------
# yosys "write_json $env(CODE_HOME)/ai_core/scripts/syn/output/graph.json"
# exec netlistsvg $env(CODE_HOME)/ai_core/scripts/syn/output/graph.json -o $env(CODE_HOME)/ai_core/scripts/syn/output/graph.svg

# -----------------------------------------------------------------------------
# Technology mapping
# -----------------------------------------------------------------------------
yosys "dfflibmap -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib"
yosys "opt"

yosys "abc \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_OA_RVT_TT_nldm_211120.lib \
    -script  $env(CODE_HOME)/ai_core/scripts/syn/abc.tcl"

yosys "opt"
yosys "clean"

# -----------------------------------------------------------------------------
# Generate cells reports
# -----------------------------------------------------------------------------
yosys "tee -o $env(CODE_HOME)/ai_core/imp/$env(SEL_OUT_DIR)/report/cell.rpt stat -hierarchy \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib \
    -liberty $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_OA_RVT_TT_nldm_211120.lib"

# -----------------------------------------------------------------------------
# Flatten & optimize & clean
# -----------------------------------------------------------------------------
yosys "flatten"
yosys "opt_clean"
yosys "rename -hide"

# -----------------------------------------------------------------------------
# Write synthesized netlist
# -----------------------------------------------------------------------------
yosys "write_verilog -noattr -noexpr -nodec $env(CODE_HOME)/ai_core/imp/$env(SEL_OUT_DIR)/output/netlist.v"
