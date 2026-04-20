// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module pp_gen
    import pp_gen_pkg::*;
#(
    parameter int ARCH       = 0,
    parameter int IN_SIZE    = 64,
    parameter int IN_WIDTH_A = 4,
    parameter int IN_WIDTH_B = 8,
    parameter int MULT_TYPE  = 0,

    localparam int PP_SIZE  = pp_gen_pkg::get_pp_size_arch(ARCH, MULT_TYPE, IN_WIDTH_A, IN_WIDTH_B, IN_SIZE),
    localparam int PP_WIDTH = pp_gen_pkg::get_pp_width_arch(ARCH, MULT_TYPE, IN_WIDTH_B)
)(
    input  logic [IN_WIDTH_A-1:0] a_i  [0:IN_SIZE-1],
    input  logic [IN_WIDTH_B-1:0] b_i  [0:IN_SIZE-1],
    output logic [PP_WIDTH-1:0]   pp_o [0:PP_SIZE-1]
);

    generate

        case (ARCH)

            BASELINE: begin : gen_baseline
                mult_array #(
                    .IN_SIZE   (IN_SIZE),
                    .IN_WIDTH_A(IN_WIDTH_A),
                    .IN_WIDTH_B(IN_WIDTH_B),
                    .MULT_TYPE (MULT_TYPE),
                    .IS_SIGNED (1)
                ) mult_array_i (
                    .a_i (a_i),
                    .b_i (b_i),
                    .pp_o(pp_o)
                );
            end

            WINOGRAD: begin : gen_winograd
                add_mult_array #(
                    .IN_SIZE   (IN_SIZE),
                    .IN_WIDTH_A(IN_WIDTH_A),
                    .IN_WIDTH_B(IN_WIDTH_B),
                    .MULT_TYPE (MULT_TYPE),
                    .IS_SIGNED (1)
                ) add_mult_array_i (
                    .a_i (a_i),
                    .b_i (b_i),
                    .pp_o(pp_o)
                );
            end

            default: begin : gen_others
                initial $fatal(1, "pp_gen: Unsupported ARCH=%0d", ARCH);
            end

        endcase

    endgenerate

endmodule
