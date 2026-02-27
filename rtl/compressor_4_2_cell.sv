// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module compressor_4_2_cell (
    input  logic in_0_i,
    input  logic in_1_i,
    input  logic in_2_i,
    input  logic in_3_i,
    input  logic cin_i,
    output logic cout_o,
    output logic sum_o,
    output logic carry_o
);
    logic s;

    full_adder full_adder_0_i (
        .in_0_i(in_0_i),
        .in_1_i(in_1_i),
        .cin_i (in_2_i),
        .sum_o (s),
        .cout_o(cout_o)
    );

    full_adder full_adder_1_i (
        .in_0_i(s),
        .in_1_i(in_3_i),
        .cin_i (cin_i),
        .sum_o (sum_o),
        .cout_o(carry_o)
    );

endmodule
