// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNUSEDPARAM */

`timescale 1 ns/1 ps

package pp_gen_pkg;

    localparam int BASELINE = 0;
    localparam int WINOGRAD = 1;

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

    function automatic int get_pp_group_winograd(input int mult_type, input int in_width_b);
        return (mult_type == RADIX_4) ? (in_width_b + 3) / 2 : (in_width_b + 4) / 3;
    endfunction

    function automatic int get_pp_size_winograd(input int mult_type, input int in_width_b, input int in_size);
        return get_pp_group_winograd(mult_type, in_width_b) * in_size / 2;
    endfunction

    function automatic int get_pp_width_winograd(input int mult_type, input int in_width_b);
        return (mult_type == RADIX_4) ? in_width_b + 4 : in_width_b + 5;
    endfunction

    function automatic int get_pp_size_arch(input int arch, input int mult_type, input int in_width_a, input int in_width_b, input int in_size);
        return (arch == WINOGRAD) ? get_pp_size_winograd(mult_type, in_width_b, in_size)
                                  : get_pp_size_baseline(mult_type, in_width_a, in_size);
    endfunction

    function automatic int get_pp_width_arch(input int arch, input int mult_type, input int in_width_b);
        return (arch == WINOGRAD) ? get_pp_width_winograd(mult_type, in_width_b)
                                  : get_pp_width(mult_type, in_width_b);
    endfunction

endpackage
