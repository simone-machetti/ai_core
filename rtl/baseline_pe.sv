// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module baseline_pe #(
    // Internal usage only
    parameter int IN_SIZE_0  = 4,
    parameter int IN_SIZE_1  = 8,
    parameter int ARRAY_SIZE = 64,
    parameter int OUT_SIZE   = 47
)(
    input  logic                 clk_i,
    input  logic                 rst_ni,
    input  logic [IN_SIZE_0-1:0] in_0_i [0:ARRAY_SIZE-1],
    input  logic [IN_SIZE_1-1:0] in_1_i [0:ARRAY_SIZE-1],
    output logic [ OUT_SIZE-1:0] out_o
);

    logic [OUT_SIZE-2:0] pp_level_7 [0:1];
    logic [OUT_SIZE-1:0] out_d;

    // -------------------------------------------------------------------------
    // Input registers
    // -------------------------------------------------------------------------
    logic [IN_SIZE_0-1:0] in_0_q [0:ARRAY_SIZE-1];
    logic [IN_SIZE_1-1:0] in_1_q [0:ARRAY_SIZE-1];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int j = 0; j < ARRAY_SIZE; j++) begin
                in_0_q[j] <= '0;
                in_1_q[j] <= '0;
            end
        end else begin
            in_0_q <= in_0_i;
            in_1_q <= in_1_i;
        end
    end

    genvar i;
    generate

        // -------------------------------------------------------------------------
        // Initial multiplication
        // -------------------------------------------------------------------------
        localparam int PP_PER_MUL      = ((IN_SIZE_1 + 2) / 3);
        localparam int PP_PER_ARRAY    = (PP_PER_MUL * ARRAY_SIZE);
        localparam int PP_WIDTH        = (IN_SIZE_0 + IN_SIZE_1);
        localparam int CPR_LEVEL_0_NUM = (ARRAY_SIZE / 8);

        logic [PP_WIDTH-1:0] pp_level_0 [0:PP_PER_ARRAY-1];

        for (i = 0; i < ARRAY_SIZE; i++) begin
            multsigned #(
                .IN_SIZE_0(IN_SIZE_0),
                .IN_SIZE_1(IN_SIZE_1)
            ) multsigned_i (
                .in_0_i(in_0_q[i]),
                .in_1_i(in_1_q[i]),
                .out_o (pp_level_0[i*PP_PER_MUL+:PP_PER_MUL])
            );
        end

        // -------------------------------------------------------------------------
        // Level 0: Compression
        // -------------------------------------------------------------------------
        localparam int PP_LEVEL_1_SIZE  = (CPR_LEVEL_0_NUM * 2);
        localparam int PP_LEVEL_1_WIDTH = (PP_WIDTH + 8);
        localparam int EXT_LEVEL_1_NUM  = (PP_LEVEL_1_SIZE / 4);

        logic [PP_LEVEL_1_WIDTH-1:0] pp_level_1 [0:PP_LEVEL_1_SIZE-1];

        for (i = 0; i < CPR_LEVEL_0_NUM; i++) begin
            compressor_n_2 #(
                .IN_NUM (24),
                .IN_SIZE(PP_WIDTH)
            ) compressor_n_2_level_0_i (
                .in_i   (pp_level_0[i*24+:24]),
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
        localparam int CPR_LEVEL_6_NUM  = (PP_LEVEL_5_SIZE / 4);

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
        // Level 6: Compression
        // -------------------------------------------------------------------------
        for (i = 0; i < CPR_LEVEL_6_NUM; i++) begin
            compressor_n_2 #(
                .IN_NUM (4),
                .IN_SIZE(PP_LEVEL_6_WIDTH)
            ) compressor_n_2_level_6_i (
                .in_i   (pp_level_6[i*4+:4]),
                .sum_o  (pp_level_7[i*2]),
                .carry_o(pp_level_7[i*2+1])
            );
        end

    endgenerate

    adder_n #(
        .SIZE(PP_LEVEL_6_WIDTH+2)
    ) adder_n_i (
        .in_0_i(pp_level_7[0]),
        .in_1_i(pp_level_7[1]),
        .out_o(out_d)
    );

    // -------------------------------------------------------------------------
    // Output registers
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            out_o <= '0;
        end else begin
            out_o <= out_d;
        end
    end

endmodule
