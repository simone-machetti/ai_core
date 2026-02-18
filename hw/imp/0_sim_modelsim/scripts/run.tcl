# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

source $env(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/scripts/compile.tcl

vlog -work work $env(CODE_HOME)/ai_core/hw/src/tb/testbench_$env(SEL_TOP_LEVEL).sv

vsim -wlf $env(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/work/build.wlf -gIN_SIZE_0=$env(SEL_IN_SIZE_0) -gIN_SIZE_1=$env(SEL_IN_SIZE_1) work.testbench -voptargs="+acc"

if {!$env(SEL_SIM_GUI)} {
    run -all
exit
}
