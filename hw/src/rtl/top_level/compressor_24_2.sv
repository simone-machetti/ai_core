// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module compressor_24_2 #(
    parameter int IN_SIZE  = 12,
    parameter int OUT_SIZE = 16
)(
    input  logic [ IN_SIZE-1:0] in_i  [0:23],
    output logic [OUT_SIZE-1:0] out_o [ 0:1]
);

    localparam logic is_signed = 1'b1;

    localparam int STAGE_0_SIZE = IN_SIZE + 2;
    logic [STAGE_0_SIZE-1:0] s0[0:5];

    localparam int STAGE_1_SIZE = STAGE_0_SIZE + 1;
    logic [STAGE_1_SIZE-1:0] s1[0:3];

    // -------------------------------------------------------------------------
    // Stage 0
    // -------------------------------------------------------------------------
    compressor_8_2_n_bit #(
        .INPUT_WIDTH(IN_SIZE),
        .OUTPUT_WIDTH(STAGE_0_SIZE),
        .SHIFT_CARRY(1)
    ) compressor_8_2_stage_0_0_i (
        .inputs(in_i[0:7]),
        .is_signed(is_signed),
        .sum(s0[0]),
        .carry(s0[1])
    );

    compressor_8_2_n_bit #(
        .INPUT_WIDTH(IN_SIZE),
        .OUTPUT_WIDTH(STAGE_0_SIZE),
        .SHIFT_CARRY(1)
    ) compressor_8_2_stage_0_1_i (
        .inputs(in_i[8:15]),
        .is_signed(is_signed),
        .sum(s0[2]),
        .carry(s0[3])
    );

    compressor_8_2_n_bit #(
        .INPUT_WIDTH(IN_SIZE),
        .OUTPUT_WIDTH(STAGE_0_SIZE),
        .SHIFT_CARRY(1)
    ) compressor_8_2_stage_0_2_i (
        .inputs(in_i[16:23]),
        .is_signed(is_signed),
        .sum(s0[4]),
        .carry(s0[5])
    );

    // -------------------------------------------------------------------------
    // Stage 1
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .INPUT_WIDTH(STAGE_0_SIZE),
        .OUTPUT_WIDTH(STAGE_1_SIZE),
        .SHIFT_CARRY(1)
    ) compressor_4_2_stage_1_0_i (
        .inputs(s0[0:3]),
        .is_signed(is_signed),
        .sum(s1[0]),
        .carry(s1[1])
    );

    sign_extender #(
        .IN_WIDTH(STAGE_0_SIZE),
        .OUT_WIDTH(STAGE_1_SIZE)
    ) i_sign_extender_stage_1_0_i (
        .is_signed(is_signed),
        .data_in(s0[4]),
        .data_out(s1[2])
    );

    sign_extender #(
        .IN_WIDTH(STAGE_0_SIZE),
        .OUT_WIDTH(STAGE_1_SIZE)
    ) i_sign_extender_stage_1_1_i (
        .is_signed(is_signed),
        .data_in(s0[5]),
        .data_out(s1[3])
    );

    // -------------------------------------------------------------------------
    // Stage 2
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .INPUT_WIDTH(STAGE_1_SIZE),
        .OUTPUT_WIDTH(OUT_SIZE),
        .SHIFT_CARRY(1)
    ) compressor_4_2_stage_2_0_i (
        .inputs(s1),
        .is_signed(is_signed),
        .sum(out_o[0]),
        .carry(out_o[1])
    );

endmodule
