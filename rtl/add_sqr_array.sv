// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module add_sqr_array #(
    parameter int IN_SIZE   = 8,
    parameter bit IS_SIGNED = 1,

    localparam int IN_WIDTH      = 4,
    localparam int IN_SQR_WIDTH  = 6,
    localparam int OUT_SQR_WIDTH = 11,
    localparam int PP_SIZE       = IN_SIZE,
    localparam int PP_WIDTH      = OUT_SQR_WIDTH + 1
)(
    input  logic [IN_WIDTH-1:0] a_i  [0:IN_SIZE-1],
    input  logic [IN_WIDTH-1:0] b_i  [0:IN_SIZE-1],
    output logic [PP_WIDTH-1:0] pp_o [0:PP_SIZE-1]
);

    genvar i;
    generate

        for (i = 0; i < IN_SIZE; i++) begin : gen_sqr

            logic signed [ IN_SQR_WIDTH-1:0] sum;
            logic        [OUT_SQR_WIDTH-1:0] pp;

            if (IS_SIGNED == 0) begin
                assign sum = IN_SQR_WIDTH'($signed(a_i[i])) + IN_SQR_WIDTH'($unsigned(b_i[i]));
            end else begin
                assign sum = IN_SQR_WIDTH'($signed(a_i[i])) + IN_SQR_WIDTH'($signed(b_i[i]));
            end

            sqr_6_bit sqr_6_bit_i (
                .in_i (sum),
                .out_o(pp)
            );

            assign pp_o[i] = {1'b0, pp};

        end

    endgenerate

endmodule
