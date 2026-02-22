// -----------------------------------------------------------------------------
// Author: Jaime Joven Murillo
// -----------------------------------------------------------------------------

module compressor_8_2_n_bit #(
    parameter int IN_SIZE  = 12,
    parameter int OUT_SIZE = 16
)(
    input  logic [ IN_SIZE-1:0] in_i [8],
    output logic [OUT_SIZE-1:0] sum_o,
    output logic [OUT_SIZE-1:0] carry_o
);

    localparam int MID_SIZE = IN_SIZE + 2;

    logic [MID_SIZE-1:0] s0, c0, s1, c1;
    logic [MID_SIZE-1:0] stage1_in [4];

    // -------------------------------------------------------------------------
    // Stage 0
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .IN_SIZE (IN_SIZE),
        .OUT_SIZE(MID_SIZE)
    ) compressor_4_2_n_bit_stage_0_0_i (
        .in_i   (in_i[0:3]),
        .sum_o  (s0),
        .carry_o(c0)
    );

    compressor_4_2_n_bit #(
        .IN_SIZE (IN_SIZE),
        .OUT_SIZE(MID_SIZE)
    ) compressor_4_2_n_bit_stage_0_1_i (
        .in_i   (in_i[4:7]),
        .sum_o  (s1),
        .carry_o(c1)
    );

    // -------------------------------------------------------------------------
    // Stage 1
    // -------------------------------------------------------------------------
    assign stage1_in[0] = s0;
    assign stage1_in[1] = c0;
    assign stage1_in[2] = s1;
    assign stage1_in[3] = c1;

    compressor_4_2_n_bit #(
        .IN_SIZE (MID_SIZE),
        .OUT_SIZE(OUT_SIZE)
    ) compressor_4_2_n_bit_stage_1_i (
        .in_i   (stage1_in),
        .sum_o  (sum_o),
        .carry_o(carry_o)
    );

endmodule
