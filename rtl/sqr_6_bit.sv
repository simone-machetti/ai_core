// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module sqr_6_bit (
    input  logic [ 5:0] in_i,
    output logic [10:0] out_o
);

    logic [4:0] xor_gates;
    logic       sign;
    logic [4:0] carry;
    logic [4:0] sum;

    assign sign         = in_i[5];
    assign xor_gates[0] = in_i[0] ^ sign;
    assign xor_gates[1] = in_i[1] ^ sign;
    assign xor_gates[2] = in_i[2] ^ sign;
    assign xor_gates[3] = in_i[3] ^ sign;
    assign xor_gates[4] = in_i[4] ^ sign;

    ha ha_0_i (
        .in_i  (xor_gates[0]),
        .cin_i (sign),
        .sum_o (sum[0]),
        .cout_o(carry[0])
    );

    ha ha_1_i (
        .in_i  (xor_gates[1]),
        .cin_i (carry[0]),
        .sum_o (sum[1]),
        .cout_o(carry[1])
    );

    ha ha_2_i (
        .in_i  (xor_gates[2]),
        .cin_i (carry[1]),
        .sum_o (sum[2]),
        .cout_o(carry[2])
    );

    ha ha_3_i (
        .in_i  (xor_gates[3]),
        .cin_i (carry[2]),
        .sum_o (sum[3]),
        .cout_o(carry[3])
    );

    ha ha_4_i (
        .in_i  (xor_gates[4]),
        .cin_i (carry[3]),
        .sum_o (sum[4]),
        .cout_o(carry[4])
    );

    sqr_5_bit sqr_5_bit_i (
        .in_i (sum),
        .out_o(out_o[9:0])
    );

    assign out_o[10] = carry[4];

endmodule
