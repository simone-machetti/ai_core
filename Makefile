# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

IN_SIZE_0   ?= 4
IN_SIZE_1   ?= 8
TOP_LEVEL   ?= baseline
OUT_DIR     ?= no_name
NETLIST_DIR ?= no_name
VCD_DIR     ?= no_name

export SEL_IN_SIZE_0   :=$(IN_SIZE_0)
export SEL_IN_SIZE_1   :=$(IN_SIZE_1)
export SEL_TOP_LEVEL   :=$(TOP_LEVEL)
export SEL_OUT_DIR     :=$(OUT_DIR)
export SEL_NETLIST_DIR :=$(NETLIST_DIR)
export SEL_VCD_DIR     :=$(VCD_DIR)

.PHONY: init

init:
	mkdir -p $(CODE_HOME)/ai_core/sim
	mkdir -p $(CODE_HOME)/ai_core/imp

sim: clean-sim
	cd $(CODE_HOME)/ai_core/scripts/sim && \
	mkdir -p $(CODE_HOME)/ai_core/sim/$(OUT_DIR) && \
	mkdir -p $(CODE_HOME)/ai_core/sim/$(OUT_DIR)/build && \
	mkdir -p $(CODE_HOME)/ai_core/sim/$(OUT_DIR)/output && \
	./run.sh && \
	mv $(CODE_HOME)/ai_core/scripts/sim/activity.vcd $(CODE_HOME)/ai_core/sim/$(OUT_DIR)/output

syn: clean-imp
	cd $(CODE_HOME)/ai_core/scripts/syn && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR) && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/output && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/report && \
	yosys -l $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/output/yosys.log -c $(CODE_HOME)/ai_core/scripts/syn/run.tcl

post-syn-sta: clean-imp
	cd $(CODE_HOME)/ai_core/scripts/post-syn-sta && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR) && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/report && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/output && \
	sta -no_splash -exit $(CODE_HOME)/ai_core/scripts/post-syn-sta/run.tcl | tee $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/output/opensta.log

post-syn-sim: clean-sim
	cd $(CODE_HOME)/ai_core/scripts/post-syn-sim && \
	mkdir -p $(CODE_HOME)/ai_core/sim/$(OUT_DIR) && \
	mkdir -p $(CODE_HOME)/ai_core/sim/$(OUT_DIR)/build && \
	mkdir -p $(CODE_HOME)/ai_core/sim/$(OUT_DIR)/output && \
	./run.sh && \
	mv $(CODE_HOME)/ai_core/scripts/post-syn-sim/activity.vcd $(CODE_HOME)/ai_core/sim/$(OUT_DIR)/output

post-syn-dpa: clean-imp
	cd $(CODE_HOME)/ai_core/scripts/post-syn-dpa && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR) && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/report && \
	mkdir -p $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/output && \
	sta -no_splash -exit $(CODE_HOME)/ai_core/scripts/post-syn-dpa/run.tcl | tee $(CODE_HOME)/ai_core/imp/$(OUT_DIR)/output/opensta.log

clean-all:
	rm -rf $(CODE_HOME)/ai_core/sim
	rm -rf $(CODE_HOME)/ai_core/imp

clean-sim:
	rm -rf $(CODE_HOME)/ai_core/sim/$(OUT_DIR)

clean-imp:
	rm -rf $(CODE_HOME)/ai_core/imp/$(OUT_DIR)
