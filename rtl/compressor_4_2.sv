// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNOPTFLAT */

`timescale 1 ns/1 ps

module compressor_4_2 #(
    parameter int IN_SIZE    = 14,
    parameter int EXTRA_BITS = 2, // Use only 1 or 2

    localparam int OUT_SIZE = IN_SIZE + EXTRA_BITS
)(
    input  logic [ IN_SIZE-1:0] in_i [4],
    output logic [OUT_SIZE-1:0] sum_o,
    output logic [OUT_SIZE-1:0] carry_o
);

    localparam EXT_SIZE = OUT_SIZE - 1;

    logic [EXT_SIZE-1:0] ext_in [4];
    logic [EXT_SIZE-1:0] s, c;
    logic [OUT_SIZE-1:0] cout;

    generate
        for (genvar i = 0; i < 4; i++) begin : gen_extenders
            sign_extender #(
                .IN_SIZE (IN_SIZE),
                .OUT_SIZE(EXT_SIZE)
            ) sign_extender_i (
                .in_i (in_i[i]),
                .out_o(ext_in[i])
            );
        end
    endgenerate

    assign cout[0] = 1'b0;

    generate
        for (genvar i = 0; i < EXT_SIZE; i++) begin : gen_compressor_4_2_cell_i
            compressor_4_2_cell compressor_4_2_cell_i (
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

    assign carry_o = {c, 1'b0};
    assign sum_o   = {s[EXT_SIZE-1], s};

endmodule
