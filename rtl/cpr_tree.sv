// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module cpr_tree
    import pe_pkg::*;
#(
    parameter pe_mode_e MODE = BASELINE_4_8,

    localparam int PP_SIZE  = calc_pp_size(MODE),
    localparam int PP_WIDTH = calc_pp_width(MODE)
)(
    input  logic [ACC_WIDTH-1:0] acc_i,
    input  logic [ACC_WIDTH-1:0] alpha_i,
    input  logic [ACC_WIDTH-1:0] beta_i,
    input  logic [ PP_WIDTH-1:0] pp_i [0:PP_SIZE-1],
    output logic [OUT_WIDTH-1:0] out_o
);

    genvar i;
    generate

        localparam int CPR_LEVEL_0_NUM  = 8;
        localparam int CPR_LEVEL_0_SIZE = PP_SIZE / CPR_LEVEL_0_NUM;

        // -------------------------------------------------------------------------
        // Level 0: Compression
        // -------------------------------------------------------------------------
        localparam int PP_LEVEL_1_SIZE  = (CPR_LEVEL_0_NUM * 2);
        localparam int PP_LEVEL_1_WIDTH = (PP_WIDTH + (($clog2(CPR_LEVEL_0_SIZE) - 1) * 2));
        localparam int EXT_LEVEL_1_NUM  = (PP_LEVEL_1_SIZE / 4);

        logic [PP_LEVEL_1_WIDTH-1:0] pp_level_1 [0:PP_LEVEL_1_SIZE-1];

        for (i = 0; i < CPR_LEVEL_0_NUM; i++) begin
            compressor_n_2 #(
                .IN_NUM (CPR_LEVEL_0_SIZE),
                .IN_SIZE(PP_WIDTH)
            ) compressor_n_2_level_0_i (
                .in_i   (pp_i[i*CPR_LEVEL_0_SIZE+:CPR_LEVEL_0_SIZE]),
                .sum_o  (pp_level_1[i*2]),
                .carry_o(pp_level_1[i*2+1])
            );
        end

        // -------------------------------------------------------------------------
        // Level 1: Shifting and Extension
        // -------------------------------------------------------------------------
        localparam int PP_LEVEL_2_SIZE  = PP_LEVEL_1_SIZE;
        localparam int PP_LEVEL_2_WIDTH = (PP_LEVEL_1_WIDTH + 4);
        localparam int CPR_LEVEL_2_NUM  = (PP_LEVEL_2_SIZE / 4);

        logic [PP_LEVEL_2_WIDTH-1:0] pp_level_2 [0:PP_LEVEL_2_SIZE-1];

        for (i = 0; i < EXT_LEVEL_1_NUM; i++) begin
            extender_n #(
                .IN_NUM   (2),
                .IN_SIZE  (PP_LEVEL_1_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (4),
                .IS_SHIFT (0)
            ) shifter_n_level_1_i (
                .in_i (pp_level_1[i*4+:2]),
                .out_o(pp_level_2[i*4+:2])
            );

            extender_n #(
                .IN_NUM   (2),
                .IN_SIZE  (PP_LEVEL_1_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (4),
                .IS_SHIFT (0)
            ) extender_n_level_1_i (
                .in_i (pp_level_1[i*4+2+:2]),
                .out_o(pp_level_2[i*4+2+:2])
            );
        end

        // -------------------------------------------------------------------------
        // Level 2: Compression
        // -------------------------------------------------------------------------
        localparam int PP_LEVEL_3_SIZE  = (CPR_LEVEL_2_NUM * 2);
        localparam int PP_LEVEL_3_WIDTH = (PP_LEVEL_2_WIDTH + 2);
        localparam int EXT_LEVEL_3_NUM  = (PP_LEVEL_3_SIZE / 4);

        logic [PP_LEVEL_3_WIDTH-1:0] pp_level_3 [0:PP_LEVEL_3_SIZE-1];

        for (i = 0; i < CPR_LEVEL_2_NUM; i++) begin
            compressor_n_2 #(
                .IN_NUM (4),
                .IN_SIZE(PP_LEVEL_2_WIDTH)
            ) compressor_n_2_level_2_i (
                .in_i   (pp_level_2[i*4+:4]),
                .sum_o  (pp_level_3[i*2]),
                .carry_o(pp_level_3[i*2+1])
            );
        end

        // -------------------------------------------------------------------------
        // Level 3: Shifting and Extension
        // -------------------------------------------------------------------------
        localparam int PP_LEVEL_4_SIZE  = PP_LEVEL_3_SIZE;
        localparam int PP_LEVEL_4_WIDTH = (PP_LEVEL_3_WIDTH + 8);
        localparam int CPR_LEVEL_4_NUM  = (PP_LEVEL_4_SIZE / 4);

        logic [PP_LEVEL_4_WIDTH-1:0] pp_level_4 [0:PP_LEVEL_4_SIZE-1];

        for (i = 0; i < EXT_LEVEL_3_NUM; i++) begin
            extender_n #(
                .IN_NUM   (2),
                .IN_SIZE  (PP_LEVEL_3_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (8),
                .IS_SHIFT (0)
            ) shifter_n_level_3_i (
                .in_i (pp_level_3[i*4+:2]),
                .out_o(pp_level_4[i*4+:2])
            );

            extender_n #(
                .IN_NUM   (2),
                .IN_SIZE  (PP_LEVEL_3_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (8),
                .IS_SHIFT (0)
            ) extender_n_level_3_i (
                .in_i (pp_level_3[i*4+2+:2]),
                .out_o(pp_level_4[i*4+2+:2])
            );
        end

        // -------------------------------------------------------------------------
        // Level 4: Compression
        // -------------------------------------------------------------------------
        localparam int PP_LEVEL_5_SIZE  = (CPR_LEVEL_4_NUM * 2);
        localparam int PP_LEVEL_5_WIDTH = (PP_LEVEL_4_WIDTH + 2);
        localparam int EXT_LEVEL_5_NUM  = (PP_LEVEL_5_SIZE / 4);

        logic [PP_LEVEL_5_WIDTH-1:0] pp_level_5 [0:PP_LEVEL_5_SIZE-1];

        for (i = 0; i < CPR_LEVEL_4_NUM; i++) begin
            compressor_n_2 #(
                .IN_NUM (4),
                .IN_SIZE(PP_LEVEL_4_WIDTH)
            ) compressor_n_2_level_4_i (
                .in_i   (pp_level_4[i*4+:4]),
                .sum_o  (pp_level_5[i*2]),
                .carry_o(pp_level_5[i*2+1])
            );
        end

        // -------------------------------------------------------------------------
        // Level 5: Shifting and Extension
        // -------------------------------------------------------------------------
        localparam int PP_LEVEL_6_SIZE  = PP_LEVEL_5_SIZE;
        localparam int PP_LEVEL_6_WIDTH = (PP_LEVEL_5_WIDTH + 8);

        logic [PP_LEVEL_6_WIDTH-1:0] pp_level_6 [0:PP_LEVEL_6_SIZE-1];

        for (i = 0; i < EXT_LEVEL_5_NUM; i++) begin
            extender_n #(
                .IN_NUM   (2),
                .IN_SIZE  (PP_LEVEL_5_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (8),
                .IS_SHIFT (0)
            ) shifter_n_level_5_i (
                .in_i (pp_level_5[i*4+:2]),
                .out_o(pp_level_6[i*4+:2])
            );

            extender_n #(
                .IN_NUM   (2),
                .IN_SIZE  (PP_LEVEL_5_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (8),
                .IS_SHIFT (0)
            ) extender_n_level_5_i (
                .in_i (pp_level_5[i*4+2+:2]),
                .out_o(pp_level_6[i*4+2+:2])
            );
        end

        // -------------------------------------------------------------------------
        // Level 6: Extension
        // -------------------------------------------------------------------------

        if (MODE == BASELINE_4_8) begin

            localparam int PP_LEVEL_7_SIZE  = 5;
            localparam int PP_LEVEL_7_WIDTH = ACC_WIDTH;

            logic [PP_LEVEL_7_WIDTH-1:0] pp_level_7 [0:PP_LEVEL_7_SIZE-1];

            extender_n #(
                .IN_NUM   (4),
                .IN_SIZE  (PP_LEVEL_6_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (ACC_WIDTH-PP_LEVEL_6_WIDTH),
                .IS_SHIFT (0)
            ) extender_n_level_6_i (
                .in_i (pp_level_6),
                .out_o(pp_level_7[0:3])
            );

            assign pp_level_7[4] = acc_i;

            // -------------------------------------------------------------------------
            // Level 7: Compressor
            // -------------------------------------------------------------------------
            localparam int PP_LEVEL_8_SIZE  = 2;
            localparam int PP_LEVEL_8_WIDTH = ACC_WIDTH + 4;

            logic [PP_LEVEL_8_WIDTH-1:0] pp_level_8 [0:PP_LEVEL_8_SIZE-1];

            compressor_n_2 #(
                .IN_NUM (5),
                .IN_SIZE(ACC_WIDTH)
            ) compressor_n_2_level_7_i (
                .in_i   (pp_level_7),
                .sum_o  (pp_level_8[0]),
                .carry_o(pp_level_8[1])
            );

            // -------------------------------------------------------------------------
            // Level 8: Final adder
            // -------------------------------------------------------------------------
            adder_n #(
                .SIZE(PP_LEVEL_8_WIDTH)
            ) adder_n_i (
                .in_0_i(pp_level_8[0]),
                .in_1_i(pp_level_8[1]),
                .out_o (out_o)
            );

        end else if (MODE == WINOGRAD_4_4) begin

            localparam int PP_LEVEL_7_SIZE  = 8;
            localparam int PP_LEVEL_7_WIDTH = ACC_WIDTH;

            logic [PP_LEVEL_7_WIDTH-1:0] pp_level_7 [0:PP_LEVEL_7_SIZE-1];

            extender_n #(
                .IN_NUM   (4),
                .IN_SIZE  (PP_LEVEL_6_WIDTH),
                .IS_SIGNED(1),
                .EXTEND   (ACC_WIDTH-PP_LEVEL_6_WIDTH),
                .IS_SHIFT (0)
            ) extender_n_level_6_i (
                .in_i (pp_level_6),
                .out_o(pp_level_7[0:3])
            );

            assign pp_level_7[4] = acc_i;
            assign pp_level_7[5] = alpha_i;
            assign pp_level_7[6] = beta_i;
            assign pp_level_7[7] = '0;

            // -------------------------------------------------------------------------
            // Level 7: Compressor
            // -------------------------------------------------------------------------
            localparam int PP_LEVEL_8_SIZE  = 2;
            localparam int PP_LEVEL_8_WIDTH = ACC_WIDTH + 4;

            logic [PP_LEVEL_8_WIDTH-1:0] pp_level_8 [0:PP_LEVEL_8_SIZE-1];

            compressor_n_2 #(
                .IN_NUM (8),
                .IN_SIZE(ACC_WIDTH)
            ) compressor_n_2_level_7_i (
                .in_i   (pp_level_7),
                .sum_o  (pp_level_8[0]),
                .carry_o(pp_level_8[1])
            );

            // -------------------------------------------------------------------------
            // Level 8: Final adder
            // -------------------------------------------------------------------------
            adder_n #(
                .SIZE(PP_LEVEL_8_WIDTH)
            ) adder_n_i (
                .in_0_i(pp_level_8[0]),
                .in_1_i(pp_level_8[1]),
                .out_o (out_o)
            );

        end else begin

            // todo

        end;

    endgenerate

endmodule
