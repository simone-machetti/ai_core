# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Load RTL + technology
# -----------------------------------------------------------------------------
script /home/simone/my_code/ai_core/hw/imp/1_syn_yosys/scripts/compile.tcl

# -----------------------------------------------------------------------------
# Elaboration / hierarchy
# -----------------------------------------------------------------------------
hierarchy -check -top multsigned
check

# -----------------------------------------------------------------------------
# Synthesis & optimizations
# -----------------------------------------------------------------------------
proc
opt
fsm
opt
memory
opt
techmap
opt

# -----------------------------------------------------------------------------
# Technology mapping
# -----------------------------------------------------------------------------
dfflibmap -liberty \
    /home/simone/my_tools/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib
opt
abc -liberty /home/simone/my_tools/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib \
    -liberty /home/simone/my_tools/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib \
    -liberty /home/simone/my_tools/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib \
    -script  /home/simone/my_code/ai_core/hw/imp/1_syn_yosys/scripts/abc.tcl
opt
clean

# -----------------------------------------------------------------------------
# Generate cells reports
# -----------------------------------------------------------------------------
tee -o /home/simone/my_code/ai_core/hw/imp/1_syn_yosys/report/cell_SIMPLE.rpt stat \
    -liberty /home/simone/my_tools/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib

# -----------------------------------------------------------------------------
# Flatten & optimize & clean
# -----------------------------------------------------------------------------
flatten
opt_clean
rename -hide

tee -o /home/simone/my_code/ai_core/hw/imp/1_syn_yosys/report/cell_SIMPLE.rpt stat \
    -liberty /home/simone/my_tools/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib

# -----------------------------------------------------------------------------
# Write synthesized netlist
# -----------------------------------------------------------------------------
write_verilog -noattr -noexpr -nodec /home/simone/my_code/ai_core/hw/imp/1_syn_yosys/output/netlist.v
