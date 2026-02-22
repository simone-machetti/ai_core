// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module AdderN #(
    parameter int SIZE = 18
)(
    input  logic [SIZE-1:0] in_0_i,
    input  logic [SIZE-1:0] in_1_i,
    output logic [SIZE-1:0] out_o
);

    assign out_o = in_0_i + in_1_i;

endmodule
