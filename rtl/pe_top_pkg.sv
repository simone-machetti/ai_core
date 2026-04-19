// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNUSEDPARAM */

`timescale 1 ns/1 ps

package pe_top_pkg;

    import pp_gen_pkg::*;

    localparam int CPR_TREE_OUT_SIZE = 2;

    function automatic int get_pp_gen_pp_size(input int arch, input int mult_type, input int in_width_a, input int in_size);
        return pp_gen_pkg::get_pp_size(mult_type, in_width_a, in_size);
    endfunction

    function automatic int get_pp_gen_pp_width(input int arch, input int mult_type, input int in_width_b);
        return pp_gen_pkg::get_pp_width(mult_type, in_width_b);
    endfunction

    function automatic int get_cpr_tree_pp_group(input int arch, input int mult_type, input int in_width_a);
        return pp_gen_pkg::get_pp_group(mult_type, in_width_a);
    endfunction

    function automatic int get_cpr_tree_pp_shift(input int arch, input int mult_type);
        return pp_gen_pkg::get_pp_shift(mult_type);
    endfunction

    function automatic int get_cpr_tree_out_width(input int arch, input int mult_type, input int in_width_a, input int in_width_b, input int in_size);
        return get_pp_gen_pp_width(arch, mult_type, in_width_b)
             + $clog2(get_pp_gen_pp_size(arch, mult_type, in_width_a, in_size) / get_cpr_tree_pp_group(arch, mult_type, in_width_a))
             + 1
             + (get_cpr_tree_pp_shift(arch, mult_type) * (get_cpr_tree_pp_group(arch, mult_type, in_width_a) - 1));
    endfunction

    function automatic int get_acc_tree_out_width(input int arch, input int mult_type, input int in_width_a, input int in_width_b, input int in_size, input int acc_size, input int acc_width);
        return acc_size > 0 ? acc_width : get_cpr_tree_out_width(arch, mult_type, in_width_a, in_width_b, in_size);
    endfunction

    function automatic int get_out_width(input int arch, input int mult_type, input int in_width_a, input int in_width_b, input int in_size, input int acc_size, input int acc_width);
        return acc_size > 0 ? acc_width : get_cpr_tree_out_width(arch, mult_type, in_width_a, in_width_b, in_size);
    endfunction

endpackage
