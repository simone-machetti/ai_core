// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module add_n #(
    parameter int IN_WIDTH = 8,

    localparam int OUT_WIDTH = IN_WIDTH + 1
)(
    input  logic [ IN_WIDTH-1:0] in_0_i,
    input  logic [ IN_WIDTH-1:0] in_1_i,
    output logic [OUT_WIDTH-1:0] out_o
);

    assign out_o = OUT_WIDTH'($signed(in_0_i) + $signed(in_1_i));

endmodule
