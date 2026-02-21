// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

module compressor_4_2_n_bit #(
    parameter int IN_SIZE  = 14,
    parameter int OUT_SIZE = 16
)(
    input  logic [ IN_SIZE-1:0] in_i [4],
    output logic [OUT_SIZE-1:0] sum_o,
    output logic [OUT_SIZE-1:0] carry_o
);
    logic [OUT_SIZE-2:0] ext_in [4];
    logic [OUT_SIZE-1:0] cout;
    logic [OUT_SIZE-2:0] s, c;

    generate
        for (genvar i = 0; i < 4; i++) begin : gen_extenders
            sign_extender #(
                .IN_SIZE(IN_SIZE),
                .OUT_SIZE(OUT_SIZE-1)
            ) sign_extender_i (
                .in_i (in_i[i]),
                .out_o(ext_in[i])
            );
        end
    endgenerate

    assign cout[0] = 1'b0;

    generate
        for (genvar i = 0; i < OUT_SIZE-1; i++) begin : gen_compressor_4_2_cell_i
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
    assign sum_o   = {s[OUT_SIZE-2], s};

endmodule
