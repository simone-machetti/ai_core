# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

design -reset

# -----------------------------------------------------------------------------
# Read SystemVerilog sources
# -----------------------------------------------------------------------------
read_verilog -sv /home/simone/my_code/ai_core/hw/src/rtl/top_level/multsigned/AdderN.sv
read_verilog -sv /home/simone/my_code/ai_core/hw/src/rtl/top_level/multsigned/Encoder.sv
read_verilog -sv /home/simone/my_code/ai_core/hw/src/rtl/top_level/multsigned/Extender.sv
read_verilog -sv /home/simone/my_code/ai_core/hw/src/rtl/top_level/multsigned/Mux9x1.sv
read_verilog -sv /home/simone/my_code/ai_core/hw/src/rtl/top_level/multsigned/Shifter1.sv
read_verilog -sv /home/simone/my_code/ai_core/hw/src/rtl/top_level/multsigned/Shifter2.sv

read_verilog -sv /home/simone/my_code/ai_core/hw/src/rtl/top_level/multsigned.sv
