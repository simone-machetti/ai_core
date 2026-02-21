// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module compressor_12_2 #(
    parameter int IN_SIZE  = 18,
    parameter int OUT_SIZE = 21
)(
    input  logic [ IN_SIZE-1:0] in_i  [0:11],
    output logic [OUT_SIZE-1:0] out_o [ 0:1]
);

    logic [(IN_SIZE+2)-1:0] s0 [2];
    logic [(IN_SIZE+4)-1:0] s1 [4];

    // -------------------------------------------------------------------------
    // Stage 0
    // -------------------------------------------------------------------------
    compressor_8_2_n_bit #(
        .IN_SIZE (IN_SIZE),
        .OUT_SIZE(IN_SIZE+4)
    ) compressor_8_2_n_bit_stage_0_i (
        .in_i   (in_i[0:7]),
        .sum_o  (s1[0]),
        .carry_o(s1[1])
    );

    compressor_4_2_n_bit #(
        .IN_SIZE (IN_SIZE),
        .OUT_SIZE(IN_SIZE+2)
    ) compressor_4_2_n_bit_stage_0_i (
        .in_i   (in_i[8:11]),
        .sum_o  (s0[0]),
        .carry_o(s0[1])
    );

    sign_extender #(
        .IN_SIZE (IN_SIZE+2),
        .OUT_SIZE(IN_SIZE+4)
    ) sign_extender_stage_0_0_i (
        .in_i (s0[0]),
        .out_o(s1[2])
    );

    sign_extender #(
        .IN_SIZE (IN_SIZE+2),
        .OUT_SIZE(IN_SIZE+4)
    ) sign_extender_stage_0_1_i (
        .in_i (s0[1]),
        .out_o(s1[3])
    );

    // -------------------------------------------------------------------------
    // Stage 1
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .IN_SIZE (IN_SIZE+4),
        .OUT_SIZE(IN_SIZE+6)
    ) compressor_4_2_n_bit_stage_1_i (
        .in_i   (s1),
        .sum_o  (out_o[0]),
        .carry_o(out_o[1])
    );

endmodule
