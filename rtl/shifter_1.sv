// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

module shifter_1 #(
    parameter int SIZE = 18
)(
    input  logic [SIZE-1:0] in_i,
    output logic [SIZE-1:0] out_0_o, out_1_o, out_2_o, out_3_o
);

    // +A
    assign out_0_o = in_i;

    // +2A (left shift by 1)
    assign out_1_o = {in_i[SIZE-2:0], 1'b0};

    // +4A (left shift by 2)
    assign out_3_o = {in_i[SIZE-3:0], 2'b00};

    // +3A = A + 2A
    assign out_2_o = out_0_o + out_1_o;

endmodule
