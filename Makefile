# -----------------------------------------------------------------------------
# Confidential and Proprietary Information
#
# This file contains confidential and proprietary information of
# Huawei Technologies Co., Ltd.
#
# Unauthorized copying, distribution, modification, or disclosure of this
# file, in whole or in part, is strictly prohibited without prior written
# permission from Huawei Technologies Co., Ltd.
#
# This material is provided for internal use only and must not be shared
# with third parties.
#
# Author: Simone Machetti
# -----------------------------------------------------------------------------

SIM_GUI   ?= 0
IN_SIZE_0 ?= 4
IN_SIZE_1 ?= 8

ifeq ($(SIM_GUI), 0)

sim_modelsim: clean-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	cd $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/build && \
	vsim -c -gIN_SIZE_0=$(IN_SIZE_0) -gIN_SIZE_1=$(IN_SIZE_0) -do $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/scripts/run.tcl

else

sim_modelsim: clean-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	cd $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/build && \
	vsim -gui -gIN_SIZE_0=$(IN_SIZE_0) -gIN_SIZE_1=$(IN_SIZE_0) -do $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/scripts/run.tcl

endif

sim_verilator: clean-sim_verilator
	cd $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_verilator && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_verilator/build && \
	./scripts/run.sh

syn_yosys: clean-syn_yosys
	cd $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/output && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/report && \
	yosys -l $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/yosys.log -s $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/scripts/run.tcl

post-syn-sta_opensta: clean-post-syn-sta_opensta
	cd $(HUAWEI_CODE)/ai_core/hw/imp/2_post-syn-sta_opensta && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/2_post-syn-sta_opensta/report && \
	sta -no_splash -exit $(HUAWEI_CODE)/ai_core/hw/imp/2_post-syn-sta_opensta/scripts/run.tcl | tee $(HUAWEI_CODE)/ai_core/hw/imp/2_post-syn-sta_opensta/opensta.log

ifeq ($(SIM_GUI), 0)

post-syn-sim_modelsim: clean-post-syn-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	cd $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/output && \
	vsim -c -gIN_SIZE_0=$(IN_SIZE_0) -gIN_SIZE_1=$(IN_SIZE_0) -do $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/scripts/run.tcl && \
	mv $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/activity.vcd $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/output

else

post-syn-sim_modelsim: clean-post-syn-sim_modelsim
	export SEL_SIM_GUI=$(SIM_GUI) && \
	cd $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/output && \
	vsim -gui -gIN_SIZE_0=$(IN_SIZE_0) -gIN_SIZE_1=$(IN_SIZE_0) -do $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/scripts/run.tcl && \
	mv $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/activity.vcd $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/output

endif

post-syn-sim_verilator: clean-post-syn-sim_verilator
	cd $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_verilator && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_verilator/build && \
	./scripts/run.sh

post-syn-dpa_opensta: clean-post-syn-dpa_opensta
	cd $(HUAWEI_CODE)/ai_core/hw/imp/4_post-syn-dpa_opensta && \
	mkdir -p $(HUAWEI_CODE)/ai_core/hw/imp/4_post-syn-dpa_opensta/report && \
	sta -no_splash -exit $(HUAWEI_CODE)/ai_core/hw/imp/4_post-syn-dpa_opensta/scripts/run.tcl | tee $(HUAWEI_CODE)/ai_core/hw/imp/4_post-syn-dpa_opensta/opensta.log

clean-all: clean-sim_modelsim clean-sim_verilator clean-syn_yosys clean-post-syn-sta_opensta clean-post-syn-sim_modelsim clean-post-syn-sim_verilator clean-post-syn-dpa_opensta

clean-sim_modelsim:
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/transcript
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/work
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/build
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_modelsim/activity.vcd

clean-sim_verilator:
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_verilator/build
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/0_sim_verilator/activity.vcd

clean-syn_yosys:
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/output
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/report
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/1_syn_yosys/yosys.log

clean-post-syn-sta_opensta:
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/2_post-syn-sta_opensta/report
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/2_post-syn-sta_opensta/opensta.log

clean-post-syn-sim_modelsim:
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/transcript
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/work
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/output
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_modelsim/build

clean-post-syn-sim_verilator:
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_verilator/build
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/3_post-syn-sim_verilator/activity.vcd

clean-post-syn-dpa_opensta:
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/4_post-syn-dpa_opensta/report
	rm -rf $(HUAWEI_CODE)/ai_core/hw/imp/4_post-syn-dpa_opensta/opensta.log
