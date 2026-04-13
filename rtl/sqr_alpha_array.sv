// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module sqr_alpha_array #(
    parameter int IN_SIZE   = 8,
    parameter bit IS_SQUARE = 0,

    localparam int IN_WIDTH = 4,
    localparam int PP_SIZE  = IN_SIZE,
    localparam int PP_WIDTH = IS_SQUARE ? (2 * IN_WIDTH) : IN_WIDTH
)(
    input  logic [IN_WIDTH-1:0] a_i  [0:IN_SIZE-1],
    output logic [PP_WIDTH-1:0] pp_o [0:PP_SIZE-1]
);

    genvar i;
    generate

        for (i = 0; i < IN_SIZE; i++) begin : gen_loop

            if (IS_SQUARE) begin : gen_sqr

                sqr_s_4_bit sqr_s_4_bit_i (
                    .in_i (a_i[i]),
                    .out_o(pp_o[i])
                );

            end else begin : gen_prop

                assign pp_o[i] = a_i[i];

            end

        end

    endgenerate

endmodule
