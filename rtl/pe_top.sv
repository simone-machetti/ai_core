// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */
/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

module pe_top
    import pp_gen_pkg::*;
    import pe_top_pkg::*;
 #(
    parameter int ARCH       = 0,
    parameter int IN_SIZE    = 64,
    parameter int IN_WIDTH_A = 4,
    parameter int IN_WIDTH_B = 8,
    parameter int MULT_TYPE  = 0,
    parameter int ACC_SIZE   = 1,
    parameter int ACC_WIDTH  = 40,

    localparam int OUT_WIDTH = pe_top_pkg::get_out_width(ARCH, MULT_TYPE, IN_WIDTH_A, IN_WIDTH_B, IN_SIZE, ACC_SIZE, ACC_WIDTH)
)(
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  logic [IN_WIDTH_A-1:0] a_i   [ 0:IN_SIZE-1],
    input  logic [IN_WIDTH_B-1:0] b_i   [ 0:IN_SIZE-1],
    input  logic [ ACC_WIDTH-1:0] acc_i [0:ACC_SIZE-1],
    output logic [ OUT_WIDTH-1:0] out_o
);

    // -------------------------------------------------------------------------
    // Input registers
    // -------------------------------------------------------------------------
    logic [IN_WIDTH_A-1:0] a [0:IN_SIZE-1];
    logic [IN_WIDTH_B-1:0] b [0:IN_SIZE-1];

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
    localparam int PP_GEN_PP_SIZE  = pe_top_pkg::get_pp_gen_pp_size(ARCH, MULT_TYPE, IN_WIDTH_A, IN_WIDTH_B, IN_SIZE);
    localparam int PP_GEN_PP_WIDTH = pe_top_pkg::get_pp_gen_pp_width(ARCH, MULT_TYPE, IN_WIDTH_B);

    logic [PP_GEN_PP_WIDTH-1:0] pp_gen_out [0:PP_GEN_PP_SIZE-1];

    pp_gen #(
        .ARCH      (ARCH),
        .IN_SIZE   (IN_SIZE),
        .IN_WIDTH_A(IN_WIDTH_A),
        .IN_WIDTH_B(IN_WIDTH_B),
        .MULT_TYPE (MULT_TYPE)
    ) pp_gen_i (
        .a_i (a),
        .b_i (b),
        .pp_o(pp_gen_out)
    );

    // -------------------------------------------------------------------------
    // Compression tree
    // -------------------------------------------------------------------------
    localparam int CPR_TREE_PP_GROUP  = pe_top_pkg::get_cpr_tree_pp_group(ARCH, MULT_TYPE, IN_WIDTH_A, IN_WIDTH_B);
    localparam int CPR_TREE_PP_SHIFT  = pe_top_pkg::get_cpr_tree_pp_shift(ARCH, MULT_TYPE);
    localparam int CPR_TREE_OUT_WIDTH = pe_top_pkg::get_cpr_tree_out_width(ARCH, MULT_TYPE, IN_WIDTH_A, IN_WIDTH_B, IN_SIZE);

    logic [CPR_TREE_OUT_WIDTH-1:0] cpr_tree_out [0:CPR_TREE_OUT_SIZE-1];

    cpr_tree #(
        .PP_SIZE (PP_GEN_PP_SIZE),
        .PP_WIDTH(PP_GEN_PP_WIDTH),
        .PP_GROUP(CPR_TREE_PP_GROUP),
        .PP_SHIFT(CPR_TREE_PP_SHIFT)
    ) cpr_tree_i (
        .pp_i (pp_gen_out),
        .out_o(cpr_tree_out)
    );

    // -------------------------------------------------------------------------
    // Accumulation tree
    // -------------------------------------------------------------------------
    localparam int ACC_TREE_OUT_WIDTH = pe_top_pkg::get_acc_tree_out_width(ARCH, MULT_TYPE, IN_WIDTH_A, IN_WIDTH_B, IN_SIZE, ACC_SIZE, ACC_WIDTH);

    logic [ACC_TREE_OUT_WIDTH-1:0] acc_tree_out [0:1];

    acc_tree #(
        .IN_WIDTH (CPR_TREE_OUT_WIDTH),
        .ACC_SIZE (ACC_SIZE),
        .ACC_WIDTH(ACC_WIDTH)
    ) acc_tree_i (
        .in_i (cpr_tree_out),
        .acc_i(acc_i),
        .out_o(acc_tree_out)
    );

    // -------------------------------------------------------------------------
    // Last adder
    // -------------------------------------------------------------------------
    logic [ACC_TREE_OUT_WIDTH:0] last_add_out;

    last_add #(
        .IN_WIDTH(ACC_TREE_OUT_WIDTH)
    ) last_add_i (
        .a_i  (acc_tree_out[0]),
        .b_i  (acc_tree_out[1]),
        .out_o(last_add_out)
    );

    // -------------------------------------------------------------------------
    // Output register
    // -------------------------------------------------------------------------
    ff #(
        .WIDTH(OUT_WIDTH)
    ) ff_out_i (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .d_i   (last_add_out[OUT_WIDTH-1:0]),
        .q_o   (out_o)
    );

endmodule
