# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Reset the design
# -----------------------------------------------------------------------------
yosys "design -reset"

# -----------------------------------------------------------------------------
# Read SystemVerilog sources
# -----------------------------------------------------------------------------
yosys "read_verilog -sv $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/AdderN.sv"
yosys "read_verilog -sv $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Encoder.sv"
yosys "read_verilog -sv $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Extender.sv"
yosys "read_verilog -sv $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Mux9x1.sv"
yosys "read_verilog -sv $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Shifter1.sv"
yosys "read_verilog -sv $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Shifter2.sv"

yosys "read_verilog -sv $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned.sv"
