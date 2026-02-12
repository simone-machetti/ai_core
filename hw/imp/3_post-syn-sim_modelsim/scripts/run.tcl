# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

source $env(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/scripts/compile.tcl

vlog -work work $env(CODE_HOME)/ai_core/hw/src/tb/testbench.sv -define POST_SYN_SIM

vsim -gui -wlf $env(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/work/build.wlf work.testbench -voptargs="+acc"

if {!$env(SEL_SIM_GUI)} {
run -all
exit
}
