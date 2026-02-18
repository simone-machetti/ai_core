# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

source $env(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/scripts/compile.tcl

vlog -work work $env(CODE_HOME)/ai_core/hw/src/tb/testbench_$env(SEL_TOP_LEVEL).sv -define POST_SYN_SIM -define VCD

vsim -gui -wlf $env(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/work/build.wlf -gIN_SIZE_0=$env(SEL_IN_SIZE_0) -gIN_SIZE_1=$env(SEL_IN_SIZE_1) work.testbench -voptargs="+acc"

if {!$env(SEL_SIM_GUI)} {
    run -all
exit
}
