# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

SIM_GUI   ?= 0
IN_SIZE_0 ?= 4
IN_SIZE_1 ?= 8
TOP_LEVEL ?= baseline

export SEL_SIM_GUI   :=$(SIM_GUI)
export SEL_IN_SIZE_0 :=$(IN_SIZE_0)
export SEL_IN_SIZE_1 :=$(IN_SIZE_1)
export SEL_TOP_LEVEL :=$(TOP_LEVEL)

ifeq ($(SIM_GUI), 0)

sim: clean-sim
	cd $(CODE_HOME)/ai_core/scripts/sim && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/sim/build && \
	./run.sh

post-syn-sim: clean-post-syn-sim
	cd $(CODE_HOME)/ai_core/scripts/post-syn-sim && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-sim/build && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-sim/output && \
	./run.sh && \
	mv $(CODE_HOME)/ai_core/scripts/post-syn-sim/activity.vcd $(CODE_HOME)/ai_core/scripts/post-syn-sim/output

else

sim: clean-sim
	cd $(CODE_HOME)/ai_core/scripts/sim && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/sim/build && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/sim/output && \
	./run.sh && \
	mv $(CODE_HOME)/ai_core/scripts/sim/activity.vcd $(CODE_HOME)/ai_core/scripts/sim/output && \
	gtkwave $(CODE_HOME)/ai_core/scripts/sim/output/activity.vcd

post-syn-sim: clean-post-syn-sim
	cd $(CODE_HOME)/ai_core/scripts/post-syn-sim && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-sim/build && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-sim/output && \
	./run.sh && \
	mv $(CODE_HOME)/ai_core/scripts/post-syn-sim/activity.vcd $(CODE_HOME)/ai_core/scripts/post-syn-sim/output && \
	gtkwave $(CODE_HOME)/ai_core/scripts/post-syn-sim/output/activity.vcd

endif

syn: clean-syn
	cd $(CODE_HOME)/ai_core/scripts/syn && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/syn/output && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/syn/report && \
	yosys -l $(CODE_HOME)/ai_core/scripts/syn/output/yosys.log -c $(CODE_HOME)/ai_core/scripts/syn/run.tcl

post-syn-sta: clean-post-syn-sta
	cd $(CODE_HOME)/ai_core/scripts/post-syn-sta && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-sta/report && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-sta/output && \
	sta -no_splash -exit $(CODE_HOME)/ai_core/scripts/post-syn-sta/run.tcl | tee $(CODE_HOME)/ai_core/scripts/post-syn-sta/output/opensta.log

post-syn-dpa: clean-post-syn-dpa
	cd $(CODE_HOME)/ai_core/scripts/post-syn-dpa && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-dpa/report && \
	mkdir -p $(CODE_HOME)/ai_core/scripts/post-syn-dpa/output && \
	sta -no_splash -exit $(CODE_HOME)/ai_core/scripts/post-syn-dpa/run.tcl | tee $(CODE_HOME)/ai_core/scripts/post-syn-dpa/opensta.log && \
	mv $(CODE_HOME)/ai_core/scripts/post-syn-dpa/opensta.log $(CODE_HOME)/ai_core/scripts/post-syn-dpa/output

clean-all: clean-sim clean-syn clean-post-syn-sta clean-post-syn-sim clean-post-syn-dpa

clean-sim:
	rm -rf $(CODE_HOME)/ai_core/scripts/sim/build
	rm -rf $(CODE_HOME)/ai_core/scripts/sim/output

clean-syn:
	rm -rf $(CODE_HOME)/ai_core/scripts/syn/report
	rm -rf $(CODE_HOME)/ai_core/scripts/syn/output

clean-post-syn-sta:
	rm -rf $(CODE_HOME)/ai_core/scripts/post-syn-sta/report
	rm -rf $(CODE_HOME)/ai_core/scripts/post-syn-sta/output

clean-post-syn-sim:
	rm -rf $(CODE_HOME)/ai_core/scripts/post-syn-sim/build
	rm -rf $(CODE_HOME)/ai_core/scripts/post-syn-sim/output

clean-post-syn-dpa:
	rm -rf $(CODE_HOME)/ai_core/scripts/post-syn-dpa/report
	rm -rf $(CODE_HOME)/ai_core/scripts/post-syn-dpa/output
