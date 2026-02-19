// -----------------------------------------------------------------------------
// Author: Jaime Joven Murillo
// -----------------------------------------------------------------------------

module compressor_8_2_n_bit #(
    parameter int INPUT_WIDTH  = 12,
    parameter int OUTPUT_WIDTH = 14,
    parameter bit SHIFT_CARRY  = 1
)(
    input  logic [ INPUT_WIDTH-1:0] inputs [8],
    input  logic                    is_signed,
    output logic [OUTPUT_WIDTH-1:0] sum,
    output logic [OUTPUT_WIDTH-1:0] carry
);

    localparam int MID_WIDTH = INPUT_WIDTH + 2;
    logic [MID_WIDTH-1:0] s_grp0, c_grp0, s_grp1, c_grp1;

    // -------------------------------------------------------------------------
    // Stage 1: 2x parallel compressor array (0..3 and 4..7)
    // -------------------------------------------------------------------------
    compressor_4_2_n_bit #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .OUTPUT_WIDTH(MID_WIDTH),
        .SHIFT_CARRY(SHIFT_CARRY)
    ) i_stage1_low (
        .inputs(inputs[0:3]),
        .is_signed(is_signed),
        .sum(s_grp0),
        .carry(c_grp0)
    );

    compressor_4_2_n_bit #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .OUTPUT_WIDTH(MID_WIDTH),
        .SHIFT_CARRY(SHIFT_CARRY)
    ) i_stage1_high (
        .inputs(inputs[4:7]),
        .is_signed(is_signed),
        .sum(s_grp1),
        .carry(c_grp1)
    );

    // -------------------------------------------------------------------------
    // Stage 2: Merge results
    // -------------------------------------------------------------------------
    logic [MID_WIDTH-1:0] stage2_in [4];

    assign stage2_in[0] = s_grp0;
    assign stage2_in[1] = c_grp0;
    assign stage2_in[2] = s_grp1;
    assign stage2_in[3] = c_grp1;

    compressor_4_2_n_bit #(
        .INPUT_WIDTH(MID_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .SHIFT_CARRY(SHIFT_CARRY)
    ) i_stage2_final (
        .inputs(stage2_in),
        .is_signed(is_signed),
        .sum(sum),
        .carry(carry)
    );

endmodule
