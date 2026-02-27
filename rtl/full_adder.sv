// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNOPTFLAT */

`timescale 1 ns/1 ps

module full_adder (
    input  logic in_0_i,
    input  logic in_1_i,
    input  logic cin_i,
    output logic sum_o,
    output logic cout_o
);

    assign sum_o  = in_0_i ^ in_1_i ^ cin_i;
    assign cout_o = (in_0_i & in_1_i) | (cin_i & in_0_i) | (cin_i & in_1_i);

endmodule
