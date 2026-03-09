// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module pp_gen
    import pe_pkg::*;
#(
    parameter pe_mode_e MODE = BASELINE_4_8,

    localparam int PP_SIZE  = calc_pp_size(MODE),
    localparam int PP_WIDTH = calc_pp_width(MODE)
)(
    input  logic [IN_WIDTH_A-1:0] a_i  [0:IN_SIZE-1],
    input  logic [IN_WIDTH_B-1:0] b_i  [0:IN_SIZE-1],
    output logic [  PP_WIDTH-1:0] pp_o [0:PP_SIZE-1]
);

    genvar i;
    generate

        if (MODE == BASELINE_4_8) begin : gen_baseline_4x8

            multsigned_array #(
                .IN_SIZE_0 (IN_WIDTH_A),
                .IN_SIZE_1 (IN_WIDTH_B),
                .ARRAY_SIZE(IN_SIZE)
            ) multsigned_array_i (
                .in_0_i(a_i),
                .in_1_i(b_i),
                .out_o (pp_o)
            );

        end else if (MODE == BASELINE_4_4) begin : gen_baseline_4x4

            logic [IN_WIDTH_A-1:0] b_low  [0:IN_SIZE-1];
            logic [IN_WIDTH_A-1:0] b_high [0:IN_SIZE-1];

            logic [(PP_WIDTH-4)-1:0] pp_low  [0:(PP_SIZE/2)-1];
            logic [(PP_WIDTH-4)-1:0] pp_high [0:(PP_SIZE/2)-1];

            for (i = 0; i < IN_SIZE; i++) begin
                assign b_low[i]  = b_i[i][IN_WIDTH_A-1:0];
                assign b_high[i] = b_i[i][IN_WIDTH_B-1:IN_WIDTH_A];
            end

            multsigned_array #(
                .IN_SIZE_0  (IN_WIDTH_A),
                .IN_SIZE_1  (IN_WIDTH_A),
                .ARRAY_SIZE (IN_SIZE),
                .IS_SIGNED_1(0)
            ) multsigned_array_low_i (
                .in_0_i(a_i),
                .in_1_i(b_low),
                .out_o (pp_low)
            );

            multsigned_array #(
                .IN_SIZE_0 (IN_WIDTH_A),
                .IN_SIZE_1 (IN_WIDTH_A),
                .ARRAY_SIZE(IN_SIZE),
                .IS_SIGNED_1(1)
            ) multsigned_array_high_i (
                .in_0_i(a_i),
                .in_1_i(b_high),
                .out_o (pp_high)
            );

            extender_n #(
                .IN_NUM   (PP_SIZE/2),
                .IN_SIZE  (PP_WIDTH-4),
                .IS_SIGNED(1),
                .EXTEND   (4),
                .IS_SHIFT (0)
            ) extender_n_low_i (
                .in_i (pp_low),
                .out_o(pp_o[0:(PP_SIZE/2)-1])
            );

            extender_n #(
                .IN_NUM   (PP_SIZE/2),
                .IN_SIZE  (PP_WIDTH-4),
                .IS_SIGNED(1),
                .EXTEND   (4),
                .IS_SHIFT (1)
            ) extender_n_high_i (
                .in_i (pp_high),
                .out_o(pp_o[(PP_SIZE/2):PP_SIZE-1])
            );

        end else if (MODE == WINOGRAD_4_8) begin : gen_winograd_4x8

            add_mult_array #(
                .IN_SIZE_0 (IN_WIDTH_A),
                .IN_SIZE_1 (IN_WIDTH_B),
                .ARRAY_SIZE(IN_SIZE)
            ) add_mult_array_i (
                .in_0_i(a_i),
                .in_1_i(b_i),
                .out_o (pp_o)
            );

        end else if (MODE == WINOGRAD_4_4) begin : gen_winograd_4x4

            logic [IN_WIDTH_A-1:0] b_low  [0:IN_SIZE-1];
            logic [IN_WIDTH_A-1:0] b_high [0:IN_SIZE-1];

            logic [(PP_WIDTH-8)-1:0] pp_low  [0:(PP_SIZE/2)-1];
            logic [(PP_WIDTH-8)-1:0] pp_high [0:(PP_SIZE/2)-1];

            for (i = 0; i < IN_SIZE; i++) begin
                assign b_low[i]  = b_i[i][IN_WIDTH_A-1:0];
                assign b_high[i] = b_i[i][IN_WIDTH_B-1:IN_WIDTH_A];
            end

            add_mult_array #(
                .IN_SIZE_0 (IN_WIDTH_A),
                .IN_SIZE_1 (IN_WIDTH_A),
                .ARRAY_SIZE(IN_SIZE),
                .IS_SIGNED_1(0)
            ) add_mult_array_low_i (
                .in_0_i(a_i),
                .in_1_i(b_low),
                .out_o (pp_low)
            );

            add_mult_array #(
                .IN_SIZE_0 (IN_WIDTH_A),
                .IN_SIZE_1 (IN_WIDTH_A),
                .ARRAY_SIZE(IN_SIZE),
                .IS_SIGNED_1(1)
            ) add_mult_array_high_i (
                .in_0_i(a_i),
                .in_1_i(b_high),
                .out_o (pp_high)
            );

            extender_n #(
                .IN_NUM   (PP_SIZE/2),
                .IN_SIZE  (PP_WIDTH-8),
                .IS_SIGNED(1),
                .EXTEND   (8),
                .IS_SHIFT (0)
            ) extender_n_low_i (
                .in_i (pp_low),
                .out_o(pp_o[0:(PP_SIZE/2)-1])
            );

            extender_n #(
                .IN_NUM   (PP_SIZE/2),
                .IN_SIZE  (PP_WIDTH-8),
                .IS_SIGNED(1),
                .EXTEND   (8),
                .IS_SHIFT (1)
            ) extender_n_high_i (
                .in_i (pp_high),
                .out_o(pp_o[(PP_SIZE/2):PP_SIZE-1])
            );

        end else begin : gen_default_baseline_4x8

            multsigned_array #(
                .IN_SIZE_0 (IN_WIDTH_A),
                .IN_SIZE_1 (IN_WIDTH_B),
                .ARRAY_SIZE(IN_SIZE)
            ) multsigned_array_i (
                .in_0_i(a_i),
                .in_1_i(b_i),
                .out_o (pp_o)
            );

        end

    endgenerate

endmodule
