# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Reset the design
# -----------------------------------------------------------------------------
yosys "design -reset"

# -----------------------------------------------------------------------------
# Import Yosys Slang plugin
# -----------------------------------------------------------------------------
yosys "plugin -i $env(YOSYS_SLANG_HOME)/bin/slang.so"

# -----------------------------------------------------------------------------
# Read libraries to Yosys database
# -----------------------------------------------------------------------------
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_OA_RVT_TT_nldm_211120.lib"

# -----------------------------------------------------------------------------
# Read SystemVerilog sources
# -----------------------------------------------------------------------------
yosys "read_slang \
    $env(CODE_HOME)/ai_core/rtl/fa.sv \
    $env(CODE_HOME)/ai_core/rtl/ff.sv \
    $env(CODE_HOME)/ai_core/rtl/ff_n.sv \
    $env(CODE_HOME)/ai_core/rtl/sign_ext.sv \
    $env(CODE_HOME)/ai_core/rtl/ext_n.sv \
    $env(CODE_HOME)/ai_core/rtl/shifter_n.sv \
    $env(CODE_HOME)/ai_core/rtl/add_n.sv \
    $env(CODE_HOME)/ai_core/rtl/adder_n.sv \
    $env(CODE_HOME)/ai_core/rtl/booth_r4_cell.sv \
    $env(CODE_HOME)/ai_core/rtl/booth_r8_cell.sv \
    $env(CODE_HOME)/ai_core/rtl/cpr_4_2_bit.sv \
    $env(CODE_HOME)/ai_core/rtl/cpr_4_2.sv \
    $env(CODE_HOME)/ai_core/rtl/cpr_n_2.sv \
    $env(CODE_HOME)/ai_core/rtl/booth_r4.sv \
    $env(CODE_HOME)/ai_core/rtl/booth_r8.sv \
    $env(CODE_HOME)/ai_core/rtl/add_mult_array.sv \
    $env(CODE_HOME)/ai_core/rtl/mult_array.sv \
    $env(CODE_HOME)/ai_core/rtl/cpr_tree.sv \
    $env(CODE_HOME)/ai_core/rtl/bas_4x4.sv \
    $env(CODE_HOME)/ai_core/rtl/bas_4x8.sv \
    $env(CODE_HOME)/ai_core/rtl/win_4x4.sv \
    $env(CODE_HOME)/ai_core/rtl/win_4x8.sv \
    $env(CODE_HOME)/ai_core/rtl/$env(SEL_TOP_LEVEL).sv \
    -G MULT_TYPE=$env(SEL_MULT_TYPE)"

# Add --keep-hierarchy option to preserve internal instances
