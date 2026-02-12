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

vlog -work work $env(CODE_HOME)/ai_core/hw/src/rtl/top_level/multsigned.sv
