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
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/AdderN.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Encoder.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Extender.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Mux9x1.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Shifter1.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Shifter2.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/full_adder.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/sign_extender.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_4_2_cell.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_4_2_n_bit.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_8_2_n_bit.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_24_2.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_12_2.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned_array.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/add_mult_array.sv \
    $env(CODE_HOME)/ai_core/hw/src/rtl/baseline.sv -G IN_SIZE_0=$env(SEL_IN_SIZE_0) -G IN_SIZE_1=$env(SEL_IN_SIZE_1) \
    $env(CODE_HOME)/ai_core/hw/src/rtl/winograd.sv -G IN_SIZE_0=$env(SEL_IN_SIZE_0) -G IN_SIZE_1=$env(SEL_IN_SIZE_1)"
