// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

package pe_pkg;

    localparam int IN_WIDTH_A = 4;
    localparam int IN_WIDTH_B = 8;
    localparam int IN_SIZE    = 64;
    localparam int ACC_WIDTH  = 48;
    localparam int OUT_WIDTH  = 53;

    typedef enum int {
        BASELINE_4_8 = 0,
        BASELINE_4_4 = 1,
        WINOGRAD_4_8 = 2,
        WINOGRAD_4_4 = 3
    } pe_mode_e;

    function automatic int calc_pp_per_mul(pe_mode_e mode);
        case (mode)
            BASELINE_4_8: return (IN_WIDTH_B + 2) / 3;
            BASELINE_4_4: return ((IN_WIDTH_B / 2) + 2) / 3;
            WINOGRAD_4_8: return ((IN_WIDTH_B + 1) + 2) / 3;
            WINOGRAD_4_4: return (((IN_WIDTH_B / 2) + 1) + 2) / 3;
            default:      return (IN_WIDTH_B + 2) / 3;
        endcase
    endfunction

    function automatic int calc_pp_size(pe_mode_e mode);
        int pp_per_mul = calc_pp_per_mul(mode);

        case (mode)
            BASELINE_4_8: return pp_per_mul * IN_SIZE;
            BASELINE_4_4: return pp_per_mul * (IN_SIZE * 2);
            WINOGRAD_4_8: return pp_per_mul * IN_SIZE / 2;
            WINOGRAD_4_4: return pp_per_mul * IN_SIZE;
            default:      return pp_per_mul * IN_SIZE;
        endcase
    endfunction

    function automatic int calc_pp_width(pe_mode_e mode);
        case (mode)
            BASELINE_4_8: return IN_WIDTH_A + IN_WIDTH_B;
            BASELINE_4_4: return IN_WIDTH_A + (IN_WIDTH_B / 2) + 4;
            WINOGRAD_4_8: return (IN_WIDTH_B + 1) * 2;
            WINOGRAD_4_4: return (((IN_WIDTH_B / 2) + 1) * 2) + 4;
            default:      return IN_WIDTH_A + IN_WIDTH_B;
        endcase
    endfunction

endpackage
