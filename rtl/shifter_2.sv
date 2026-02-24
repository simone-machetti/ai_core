// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

module shifter_2 #(
    parameter int SIZE = 18
)(
    input  logic [SIZE-1:0] in_0_i, in_1_i, in_2_i, in_3_i,
    output logic [SIZE-1:0] out_0_o, out_1_o, out_2_o, out_3_o
);

    // Shift left by 3 bits (radix-8)
    assign out_0_o = {in_0_i[SIZE-4:0], 3'b000};
    assign out_1_o = {in_1_i[SIZE-4:0], 3'b000};
    assign out_2_o = {in_2_i[SIZE-4:0], 3'b000};
    assign out_3_o = {in_3_i[SIZE-4:0], 3'b000};

endmodule
