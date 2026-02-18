// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module compressor_12_2 #(
    parameter int IN_SIZE  = 18,
    parameter int OUT_SIZE = 24
)(
    input  logic [ IN_SIZE-1:0] in_i  [0:11],
    output logic [OUT_SIZE-1:0] out_o [0:1]
);

    localparam logic is_signed = 1'b1;

    logic [(IN_SIZE+2)-1:0] s0[0:1];

    logic [(IN_SIZE+2+2)-1:0] s1[0:3];

    // -------------------------------------------------------------------------
    // Stage 0
    // -------------------------------------------------------------------------
    compressor_8_2_n_bit #(
        .INPUT_WIDTH(IN_SIZE),
        .OUTPUT_WIDTH(IN_SIZE+4),
        .SHIFT_CARRY(1)
    ) compressor_8_2_stage_0_i (
        .inputs(in_i[0:7]),
        .is_signed(is_signed),
        .sum(s1[0]),
        .carry(s1[1])
    );

    compressor_4_2_n_bit #(
        .INPUT_WIDTH(IN_SIZE),
        .OUTPUT_WIDTH(IN_SIZE+2),
        .SHIFT_CARRY(1)
    ) compressor_4_2_stage_0_i (
        .inputs(in_i[8:11]),
        .is_signed(is_signed),
        .sum(s0[0]),
        .carry(s0[1])
    );

    sign_extender #(
        .IN_WIDTH(IN_SIZE+2),
        .OUT_WIDTH(IN_SIZE+2+2)
    ) i_sign_extender_stage_0_0_i (
        .is_signed(is_signed),
        .data_in(s0[0]),
        .data_out(s1[2])
    );

    sign_extender #(
        .IN_WIDTH(IN_SIZE+2),
        .OUT_WIDTH(IN_SIZE+2+2)
    ) i_sign_extender_stage_0_1_i (
        .is_signed(is_signed),
        .data_in(s0[1]),
        .data_out(s1[3])
    );

    // -------------------------------------------------------------------------
    // Stage 1
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .INPUT_WIDTH(IN_SIZE+2+2),
        .OUTPUT_WIDTH(IN_SIZE+2+2+2),
        .SHIFT_CARRY(1)
    ) compressor_4_2_stage_1_i (
        .inputs(s1),
        .is_signed(is_signed),
        .sum(out_o[0]),
        .carry(out_o[1])
    );

endmodule
