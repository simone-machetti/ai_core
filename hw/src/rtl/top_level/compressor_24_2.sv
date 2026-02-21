// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module compressor_24_2 #(
    parameter int IN_SIZE  = 12,
    parameter int OUT_SIZE = 20
)(
    input  logic [ IN_SIZE-1:0] in_i  [0:23],
    output logic [OUT_SIZE-1:0] out_o [ 0:1]
);

    localparam int STAGE_0_SIZE = IN_SIZE + 4;
    localparam int STAGE_1_SIZE = STAGE_0_SIZE + 2;

    logic [STAGE_0_SIZE-1:0] s0 [0:5];
    logic [STAGE_1_SIZE-1:0] s1 [0:3];

    // -------------------------------------------------------------------------
    // Stage 0
    // -------------------------------------------------------------------------
    compressor_8_2_n_bit #(
        .IN_SIZE (IN_SIZE),
        .OUT_SIZE(STAGE_0_SIZE)
    ) compressor_8_2_n_bit_stage_0_0_i (
        .in_i   (in_i[0:7]),
        .sum_o  (s0[0]),
        .carry_o(s0[1])
    );

    compressor_8_2_n_bit #(
        .IN_SIZE (IN_SIZE),
        .OUT_SIZE(STAGE_0_SIZE)
    ) compressor_8_2_n_bit_stage_0_1_i (
        .in_i   (in_i[8:15]),
        .sum_o  (s0[2]),
        .carry_o(s0[3])
    );

    compressor_8_2_n_bit #(
        .IN_SIZE (IN_SIZE),
        .OUT_SIZE(STAGE_0_SIZE)
    ) compressor_8_2_n_bit_stage_0_2_i (
        .in_i   (in_i[16:23]),
        .sum_o  (s0[4]),
        .carry_o(s0[5])
    );

    // -------------------------------------------------------------------------
    // Stage 1
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .IN_SIZE (STAGE_0_SIZE),
        .OUT_SIZE(STAGE_1_SIZE)
    ) compressor_4_2_n_bit_stage_1_i (
        .in_i   (s0[0:3]),
        .sum_o  (s1[0]),
        .carry_o(s1[1])
    );

    sign_extender #(
        .IN_SIZE (STAGE_0_SIZE),
        .OUT_SIZE(STAGE_1_SIZE)
    ) i_sign_extender_stage_1_0_i (
        .in_i (s0[4]),
        .out_o(s1[2])
    );

    sign_extender #(
        .IN_SIZE (STAGE_0_SIZE),
        .OUT_SIZE(STAGE_1_SIZE)
    ) i_sign_extender_stage_1_1_i (
        .in_i (s0[5]),
        .out_o(s1[3])
    );

    // -------------------------------------------------------------------------
    // Stage 2
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .IN_SIZE (STAGE_1_SIZE),
        .OUT_SIZE(OUT_SIZE)
    ) compressor_4_2_n_bit_stage_2_0_i (
        .in_i   (s1),
        .sum_o  (out_o[0]),
        .carry_o(out_o[1])
    );

endmodule
