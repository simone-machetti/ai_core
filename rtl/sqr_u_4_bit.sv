// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

module sqr_u_4_bit (
    input  logic [3:0] in_i,
    output logic [7:0] out_o
);

    logic [4:0] tmp;

    assign out_o[0] = in_i[0];
    assign out_o[1] = 1'b0;
    assign out_o[2] = in_i[1] & (~in_i[0]);

    ha ha_0_i (
        .in_i  (in_i[1] & in_i[0]),
        .cin_i (in_i[2] & in_i[0]),
        .sum_o (out_o[3]),
        .cout_o(tmp[0])
    );

    fa fa_0_i (
        .in_0_i(in_i[3] & in_i[0]),
        .in_1_i(in_i[2] & (~in_i[1])),
        .cin_i (tmp[0]),
        .sum_o (out_o[4]),
        .cout_o(tmp[1])
    );

    fa fa_1_i (
        .in_0_i(in_i[2] & in_i[1]),
        .in_1_i(in_i[3] & in_i[1]),
        .cin_i (tmp[1]),
        .sum_o (out_o[5]),
        .cout_o(tmp[2])
    );

    ha ha_1_i (
        .in_i  (in_i[3] & (~in_i[2])),
        .cin_i (tmp[2]),
        .sum_o (out_o[6]),
        .cout_o(tmp[3])
    );

    ha ha_2_i (
        .in_i  (in_i[3] & in_i[2]),
        .cin_i (tmp[3]),
        .sum_o (out_o[7]),
        .cout_o(tmp[4])
    );

endmodule
