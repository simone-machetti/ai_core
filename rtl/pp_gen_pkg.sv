// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNUSEDPARAM */

`timescale 1 ns/1 ps

package pp_gen_pkg;

    localparam int BASELINE = 0;

    localparam int RADIX_4 = 0;
    localparam int RADIX_8 = 1;

    function automatic int get_pp_group(input int mult_type, input int in_width_a);
        return (mult_type == RADIX_4) ? (in_width_a + 1) / 2 : (in_width_a + 2) / 3;
    endfunction

    function automatic int get_pp_shift(input int mult_type);
        return (mult_type == RADIX_4) ? 2 : 3;
    endfunction

    function automatic int get_pp_size(input int mult_type, input int in_width_a, input int in_size);
        return get_pp_group(mult_type, in_width_a) * in_size;
    endfunction

    function automatic int get_pp_width(input int mult_type, input int in_width_b);
        return (mult_type == RADIX_4) ? in_width_b + 2 : in_width_b + 3;
    endfunction

endpackage
