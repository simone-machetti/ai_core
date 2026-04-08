# -----------------------------------------------------------------------------
# Author: Simone Machetti
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Reset the design
# -----------------------------------------------------------------------------
yosys "design -reset"

# -----------------------------------------------------------------------------
# Import Yosys Slang plugin
# -----------------------------------------------------------------------------
yosys "plugin -i $env(YOSYS_SLANG_HOME)/bin/slang.so"

# -----------------------------------------------------------------------------
# Read libraries to Yosys database
# -----------------------------------------------------------------------------
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SEQ_RVT_TT_nldm_220123.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_SIMPLE_RVT_TT_nldm_211120.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_INVBUF_RVT_TT_nldm_220122.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_AO_RVT_TT_nldm_211120.lib"
yosys "read_liberty -lib $env(TOOLS_HOME)/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/asap7sc7p5t_OA_RVT_TT_nldm_211120.lib"

# -----------------------------------------------------------------------------
# Read SystemVerilog sources
# -----------------------------------------------------------------------------
set rtl_files [list \
    $env(CODE_HOME)/ai-core/rtl/ha.sv \
    $env(CODE_HOME)/ai-core/rtl/fa.sv \
    $env(CODE_HOME)/ai-core/rtl/ff.sv \
    $env(CODE_HOME)/ai-core/rtl/ff_n.sv \
    $env(CODE_HOME)/ai-core/rtl/sign_ext.sv \
    $env(CODE_HOME)/ai-core/rtl/ext_n.sv \
    $env(CODE_HOME)/ai-core/rtl/shifter_n.sv \
    $env(CODE_HOME)/ai-core/rtl/add_n.sv \
    $env(CODE_HOME)/ai-core/rtl/adder_n.sv \
    $env(CODE_HOME)/ai-core/rtl/booth_r4_cell.sv \
    $env(CODE_HOME)/ai-core/rtl/booth_r8_cell.sv \
    $env(CODE_HOME)/ai-core/rtl/cpr_4_2_bit.sv \
    $env(CODE_HOME)/ai-core/rtl/cpr_4_2.sv \
    $env(CODE_HOME)/ai-core/rtl/cpr_n_2.sv \
    $env(CODE_HOME)/ai-core/rtl/booth_r4.sv \
    $env(CODE_HOME)/ai-core/rtl/booth_r8.sv \
    $env(CODE_HOME)/ai-core/rtl/sqr_4_bit.sv \
    $env(CODE_HOME)/ai-core/rtl/sqr_5_bit.sv \
    $env(CODE_HOME)/ai-core/rtl/add_mult_array.sv \
    $env(CODE_HOME)/ai-core/rtl/mult_array.sv \
    $env(CODE_HOME)/ai-core/rtl/add_sqr_array.sv \
    $env(CODE_HOME)/ai-core/rtl/cpr_tree.sv \
    $env(CODE_HOME)/ai-core/rtl/bas_4x4.sv \
    $env(CODE_HOME)/ai-core/rtl/bas_4x8.sv \
    $env(CODE_HOME)/ai-core/rtl/win_4x4.sv \
    $env(CODE_HOME)/ai-core/rtl/win_4x8.sv \
    $env(CODE_HOME)/ai-core/rtl/sqr_4x4.sv \
]

set top_file "$env(CODE_HOME)/ai-core/rtl/$env(SEL_TOP_LEVEL).sv"

if {[lsearch $rtl_files $top_file] == -1} {
    lappend rtl_files $top_file
}

set g_flags ""
if {$env(SEL_PARAMS) ne "none"} {
    foreach param [split $env(SEL_PARAMS)] {
        append g_flags " -G $param"
    }
}

yosys "read_slang [join $rtl_files]$g_flags"
