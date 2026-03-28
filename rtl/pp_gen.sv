// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module pp_gen #(
    parameter int ARCH      = 0,
    parameter int MULT_TYPE = 0,

    localparam int IN_SIZE      = 64,
    localparam int IN_WIDTH_A   = 4,
    localparam int IN_WIDTH_B   = 8,
    localparam int NUM_LANES    = 8,
    localparam int PP_PER_MUL   = MULT_TYPE == 0 ? (IN_WIDTH_A + 1) / 2 : (IN_WIDTH_A + 2) / 3,
    localparam int PP_SIZE      = 2 * PP_PER_MUL * NUM_LANES,
    localparam int CPR_IN_SIZE  = IN_SIZE / NUM_LANES,
    localparam int CPR_IN_WIDTH = MULT_TYPE == 0 ? IN_WIDTH_B + 2 : IN_WIDTH_B + 3,
    localparam int PP_SHIFT     = MULT_TYPE == 0 ? 2 : 3,
    localparam int PP_WIDTH     = CPR_IN_WIDTH + $clog2(CPR_IN_SIZE) + 1 + PP_SHIFT
)(
    input  logic [IN_WIDTH_A-1:0] a_i  [0:IN_SIZE-1],
    input  logic [IN_WIDTH_B-1:0] b_i  [0:IN_SIZE-1],
    output logic [PP_WIDTH-1:0]   pp_o [0:PP_SIZE-1]
);

    localparam int BASELINE_4X8 = 0;

    generate

        case (ARCH)

            BASELINE_4X8: begin : gen_bas_4x8
                bas_4x8 #(
                    .MULT_TYPE(MULT_TYPE)
                ) bas_4x8_i (
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
