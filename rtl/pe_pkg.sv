// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

package pe_pkg;

    localparam int IN_WIDTH_A = 4;
    localparam int IN_WIDTH_B = 8;
    localparam int IN_SIZE    = 64;

    function automatic int calc_pp_per_mul(int mode);
        if (mode == 0)
            return (IN_WIDTH_B + 2) / 3;
        else
            return ((IN_WIDTH_B / 2) + 2) / 3;
    endfunction

    function automatic int calc_pp_size(int mode);
        int pp_per_mul = calc_pp_per_mul(mode);

        if (mode == 0)
            return pp_per_mul * IN_SIZE;
        else
            return pp_per_mul * (IN_SIZE * 2);
    endfunction

    function automatic int calc_pp_width(int mode);
        if (mode == 0)
            return IN_WIDTH_A + IN_WIDTH_B;
        else
            return IN_WIDTH_A + (IN_WIDTH_B / 2) + 4;
    endfunction

    function automatic int calc_out_width(int mode);
        int pp_width = calc_pp_width(mode);
        int pp_size  = calc_pp_size(mode);

        return pp_width + ((($clog2(pp_size) - 1) * 2) + 20 + 1);
    endfunction

endpackage
