# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

SIM_GUI   ?= 0
IN_SIZE_0 ?= 4
IN_SIZE_1 ?= 8

ifeq ($(SIM_GUI), 0)

sim_modelsim: clean-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/output && \
	vsim -c -do $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/scripts/run.tcl && \
	mv $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/transcript $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/output

sim_verilator: clean-sim_verilator
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/build && \
	./scripts/run.sh

post-syn-sim_modelsim: clean-post-syn-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/output && \
	vsim -c -gIN_SIZE_0=$(IN_SIZE_0) -gIN_SIZE_1=$(IN_SIZE_0) -do $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/scripts/run.tcl && \
	mv $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/activity.vcd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/output && \
	mv $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/transcript $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/output

post-syn-sim_verilator: clean-post-syn-sim_verilator
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/build && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/output && \
	./scripts/run.sh && \
	mv $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/activity.vcd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/output

else

sim_modelsim: clean-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/output && \
	vsim -gui -do $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/scripts/run.tcl && \
	mv $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/transcript $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/output

sim_verilator: clean-sim_verilator
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/build && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/output && \
	./scripts/run.sh && \
	mv $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/activity.vcd $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/output && \
	gtkwave $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/output/activity.vcd

post-syn-sim_modelsim: clean-post-syn-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/output && \
	vsim -gui -gIN_SIZE_0=$(IN_SIZE_0) -gIN_SIZE_1=$(IN_SIZE_0) -do $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/scripts/run.tcl && \
	mv $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/activity.vcd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/output && \
	mv $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/transcript $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/output

post-syn-sim_verilator: clean-post-syn-sim_verilator
	export SEL_SIM_GUI=$(SIM_GUI) && \
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/build && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/output && \
	./scripts/run.sh && \
	mv $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/activity.vcd $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/output && \
	gtkwave $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/output/activity.vcd

endif

syn_yosys: clean-syn_yosys
	export SEL_IN_SIZE_0=$(IN_SIZE_0) && \
	export SEL_IN_SIZE_1=$(IN_SIZE_1) && \
	cd $(CODE_HOME)/ai_core/hw/imp/1_syn_yosys && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/output && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/report && \
	yosys -l $(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/output/yosys.log -c $(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/scripts/run.tcl

post-syn-sta_opensta: clean-post-syn-sta_opensta
	cd $(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta/report && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta/output && \
	sta -no_splash -exit $(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta/scripts/run.tcl | tee $(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta/output/opensta.log

post-syn-dpa_opensta: clean-post-syn-dpa_opensta
	cd $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/report && \
	mkdir -p $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/output && \
	sta -no_splash -exit $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/scripts/run.tcl | tee $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/opensta.log && \
	mv $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/opensta.log $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/output

clean-all: clean-sim_modelsim clean-sim_verilator clean-syn_yosys clean-post-syn-sta_opensta clean-post-syn-sim_modelsim clean-post-syn-sim_verilator clean-post-syn-dpa_opensta

clean-sim_modelsim:
	rm -rf $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/work
	rm -rf $(CODE_HOME)/ai_core/hw/imp/0_sim_modelsim/output

clean-sim_verilator:
	rm -rf $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/build
	rm -rf $(CODE_HOME)/ai_core/hw/imp/0_sim_verilator/output

clean-syn_yosys:
	rm -rf $(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/report
	rm -rf $(CODE_HOME)/ai_core/hw/imp/1_syn_yosys/output

clean-post-syn-sta_opensta:
	rm -rf $(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta/report
	rm -rf $(CODE_HOME)/ai_core/hw/imp/2_post-syn-sta_opensta/output

clean-post-syn-sim_modelsim:
	rm -rf $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/work
	rm -rf $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_modelsim/output

clean-post-syn-sim_verilator:
	rm -rf $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/build
	rm -rf $(CODE_HOME)/ai_core/hw/imp/3_post-syn-sim_verilator/output

clean-post-syn-dpa_opensta:
	rm -rf $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/report
	rm -rf $(CODE_HOME)/ai_core/hw/imp/4_post-syn-dpa_opensta/output
