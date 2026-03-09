// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module pe_top #(
    parameter int MODE = 0,

    localparam int IN_WIDTH_A = 4,
    localparam int IN_WIDTH_B = 8,
    localparam int IN_SIZE    = 64,
    localparam int PP_PER_MUL = (MODE == 0) ? ((IN_WIDTH_B + 2) / 3)    : (((IN_WIDTH_B / 2) + 2) / 3),
    localparam int PP_SIZE    = (MODE == 0) ? (PP_PER_MUL * IN_SIZE)    : (PP_PER_MUL * (IN_SIZE * 2)),
    localparam int PP_WIDTH   = (MODE == 0) ? (IN_WIDTH_A + IN_WIDTH_B) : (IN_WIDTH_A + (IN_WIDTH_B / 2) + 4),
    localparam int OUT_WIDTH  = (PP_WIDTH + ((($clog2(PP_SIZE) - 1) * 2) + 20 + 1))
)(
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  logic [IN_WIDTH_A-1:0] a_i [0:IN_SIZE-1],
    input  logic [IN_WIDTH_B-1:0] b_i [0:IN_SIZE-1],
    output logic [ OUT_WIDTH-1:0] out_o
);

    logic [IN_WIDTH_A-1:0] a  [0:IN_SIZE-1];
    logic [IN_WIDTH_B-1:0] b  [0:IN_SIZE-1];
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

    ff_n #(
        .WIDTH(IN_WIDTH_B),
        .SIZE (IN_SIZE)
    ) ff_n_b_i (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .d_i   (b_i),
        .q_o   (b)
    );

    // -------------------------------------------------------------------------
    // Partial product generator
    // -------------------------------------------------------------------------
    pp_gen #(
        .MODE(MODE)
    ) pp_gen_i (
        .a_i (a),
        .b_i (b),
        .pp_o(pp)
    );

    // -------------------------------------------------------------------------
    // Compression tree
    // -------------------------------------------------------------------------
    cpr_tree #(
        .MODE(MODE),
        .IN_WIDTH_A(IN_WIDTH_A),
        .IN_WIDTH_B(IN_WIDTH_B),
        .IN_SIZE   (IN_SIZE)
    ) cpr_tree_i (
        .pp_i (pp),
        .out_o(out)
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
