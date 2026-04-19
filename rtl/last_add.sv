// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module last_add #(
    parameter int IN_WIDTH = 8,

    localparam int OUT_WIDTH = IN_WIDTH + 1
)(
    input  logic [ IN_WIDTH-1:0] a_i,
    input  logic [ IN_WIDTH-1:0] b_i,
    output logic [OUT_WIDTH-1:0] out_o
);

    add_n #(
        .IN_WIDTH(IN_WIDTH)
    ) add_n_i (
        .in_0_i(a_i),
        .in_1_i(b_i),
        .out_o (out_o)
    );

endmodule
