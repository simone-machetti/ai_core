// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module booth_r4 #(
    parameter int IN_WIDTH_A = 4,
    parameter int IN_WIDTH_B = 8,
    parameter bit IS_SIGNED  = 1,

    localparam int PP_SIZE  = (IN_WIDTH_A + 1) / 2,
    localparam int PP_WIDTH = IN_WIDTH_B + 2
)(
    input  logic [IN_WIDTH_A-1:0] a_i,
    input  logic [IN_WIDTH_B-1:0] b_i,
    output logic [  PP_WIDTH-1:0] pp_o [0:PP_SIZE-1]
);

    logic [IN_WIDTH_A:0] mult_ext;

    assign mult_ext = {a_i, 1'b0};

    genvar i;
    generate

        for (i = 0; i < PP_SIZE; i++) begin : ben_booth

            logic [2:0] sel;

            assign sel = mult_ext[2*i +: 3];

            booth_r4_cell #(
                .IN_WIDTH (IN_WIDTH_B),
                .IS_SIGNED(IS_SIGNED)
            ) booth_r4_cell_i (
                .mult_i(b_i),
                .sel_i (sel),
                .pp_o  (pp_o[i])
            );

        end

    endgenerate

endmodule
