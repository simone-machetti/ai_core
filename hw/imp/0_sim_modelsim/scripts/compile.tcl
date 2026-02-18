# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

vlib work

vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/AdderN.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Encoder.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Extender.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Mux9x1.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Shifter1.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned/Shifter2.sv

vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/full_adder.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/sign_extender.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_4_2_cell.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_4_2_n_bit.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_8_2_n_bit.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_24_2.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/compressor_12_2.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned_array.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/add_mult_array.sv

vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/baseline.sv
vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/winograd.sv
