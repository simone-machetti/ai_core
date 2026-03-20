// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module cpr_4_2 #(
    parameter int IN_WIDTH = 12,
    parameter int EXT_BITS = 2,

    localparam int OUT_WIDTH = IN_WIDTH + EXT_BITS
)(
    input  logic [ IN_WIDTH-1:0] in_i [4],
    output logic [OUT_WIDTH-1:0] sum_o,
    output logic [OUT_WIDTH-1:0] carry_o
);
    localparam int EXT_WIDTH = OUT_WIDTH + 1;

    logic [EXT_WIDTH-1:0] ext_in [4];
    logic [EXT_WIDTH-1:0] s, c;
    logic [  EXT_WIDTH:0] cout;

    generate
        for (genvar i = 0; i < 4; i++) begin : gen_extenders
            sign_ext #(
                .IN_WIDTH (IN_WIDTH),
                .OUT_WIDTH(EXT_WIDTH)
            ) sign_ext_i (
                .in_i (in_i[i]),
                .out_o(ext_in[i])
            );
        end
    endgenerate

    assign cout[0] = 1'b0;

    generate
        for (genvar i = 0; i < EXT_WIDTH; i++) begin : gen_compressor_4_2_cell_i
            cpr_4_2_bit cpr_4_2_bit_i (
                .in_0_i (ext_in[0][i]),
                .in_1_i (ext_in[1][i]),
                .in_2_i (ext_in[2][i]),
                .in_3_i (ext_in[3][i]),
                .cin_i  (cout[i]),
                .cout_o (cout[i+1]),
                .sum_o  (s[i]),
                .carry_o(c[i])
            );
        end
    endgenerate

    assign sum_o   = s[OUT_WIDTH-1:0];
    assign carry_o = {c[OUT_WIDTH-2:0], 1'b0};

endmodule
