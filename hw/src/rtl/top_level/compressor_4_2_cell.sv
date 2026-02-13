// -----------------------------------------------------------------------------
// Author: Jaime Joven Murillo
// -----------------------------------------------------------------------------

module compressor_4_2_cell (
    input  logic x1, x2, x3, x4,
    input  logic cin,
    output logic cout,
    output logic sum,
    output logic carry
);
    logic s_int;

    full_adder i_fa1 (
        .a(x1),
        .b(x2),
        .cin(x3),
        .sum(s_int),
        .cout(cout)
    );

    full_adder i_fa2 (
        .a(s_int),
        .b(x4),
        .cin(cin),
        .sum(sum),
        .cout(carry)
    );

endmodule
