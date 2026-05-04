// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */
/* verilator lint_off UNUSEDPARAM */

`timescale 1 ns/1 ps

module sqr_4x8_sc_alpha_top #(
    parameter bit IS_PIPELINED = 1,
    parameter bit IS_SQUARE    = 0,

    localparam int IN_SIZE      = 32,
    localparam int IN_WIDTH_A   = 4,
    localparam int EXT_NUM      = 15,
    localparam int PP_SIZE      = IN_SIZE,
    localparam int PP_WIDTH     = IS_SQUARE ? (2 * IN_WIDTH_A) : IN_WIDTH_A,
    localparam int CPR_EXT_BITS = 4,
    localparam int OUT_WIDTH    = PP_WIDTH + CPR_EXT_BITS + 20
)(
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  logic                  is_signed_i [ 0:EXT_NUM-1],
    input  logic                  is_shift_i  [ 0:EXT_NUM-1],
    input  logic [IN_WIDTH_A-1:0] a_i         [ 0:IN_SIZE-1],
    output logic [ OUT_WIDTH-1:0] out_o
);

    logic [IN_WIDTH_A-1:0] a  [0:IN_SIZE-1];
    logic [  PP_WIDTH-1:0] pp [0:PP_SIZE-1];
    logic [ OUT_WIDTH-1:0] out;

    // -------------------------------------------------------------------------
    // Input registers
    // -------------------------------------------------------------------------
    ff_n #(
        .WIDTH(IN_WIDTH_A),
        .SIZE (IN_SIZE)
    ) ff_n_a_i (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .d_i   (a_i),
        .q_o   (a)
    );

    // -------------------------------------------------------------------------
    // Partial product generator
    // -------------------------------------------------------------------------
    sqr_alpha_array #(
        .IN_SIZE  (IN_SIZE),
        .IS_SQUARE(IS_SQUARE)
    ) sqr_alpha_array_i (
        .a_i (a),
        .pp_o(pp)
    );

    // -------------------------------------------------------------------------
    // Compression tree
    // -------------------------------------------------------------------------
    cpr_tree_alpha #(
        .IS_PIPELINE(IS_PIPELINED),
        .PP_SIZE    (PP_SIZE),
        .PP_WIDTH   (PP_WIDTH)
    ) cpr_tree_alpha_i (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .is_signed_i(is_signed_i),
        .is_shift_i (is_shift_i),
        .pp_i       (pp),
        .out_o      (out)
    );

    // -------------------------------------------------------------------------
    // Output register
    // -------------------------------------------------------------------------
    ff #(
        .WIDTH(OUT_WIDTH)
    ) ff_out_i (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .d_i   (out),
        .q_o   (out_o)
    );

endmodule
