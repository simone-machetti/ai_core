// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module sqr_5_bit (
    input  logic [4:0] in_i,
    output logic [9:0] out_o
);

    logic [11:0] tmp;

    assign out_o[0] = in_i[0];
    assign out_o[1] = 1'b0;

    ha ha_0_i (
        .in_i  (in_i[1]),
        .cin_i (in_i[1] & in_i[0]),
        .sum_o (out_o[2]),
        .cout_o(tmp[0])
    );

    ha ha_1_i (
        .in_i  (in_i[2] & in_i[0]),
        .cin_i (tmp[0]),
        .sum_o (out_o[3]),
        .cout_o(tmp[1])
    );

    fa fa_0_i (
        .in_0_i(in_i[2]),
        .in_1_i(in_i[3] & in_i[0]),
        .cin_i (in_i[2] & in_i[1]),
        .sum_o (tmp[2]),
        .cout_o(tmp[3])
    );

    ha ha_2_i (
        .in_i  (tmp[2]),
        .cin_i (tmp[1]),
        .sum_o (out_o[4]),
        .cout_o(tmp[4])
    );

    fa fa_1_i (
        .in_0_i(in_i[4] & in_i[0]),
        .in_1_i(in_i[3] & in_i[1]),
        .cin_i (tmp[3]),
        .sum_o (tmp[5]),
        .cout_o(tmp[6])
    );

    ha ha_3_i (
        .in_i  (tmp[5]),
        .cin_i (tmp[4]),
        .sum_o (out_o[5]),
        .cout_o(tmp[7])
    );

    fa fa_2_i (
        .in_0_i(in_i[3]),
        .in_1_i(in_i[4] & in_i[1]),
        .cin_i (in_i[3] & in_i[2]),
        .sum_o (tmp[8]),
        .cout_o(tmp[9])
    );

    fa fa_3_i (
        .in_0_i(tmp[8]),
        .in_1_i(tmp[6]),
        .cin_i (tmp[7]),
        .sum_o (out_o[6]),
        .cout_o(tmp[10])
    );

    fa fa_4_i (
        .in_0_i(in_i[4] & in_i[2]),
        .in_1_i(tmp[9]),
        .cin_i (tmp[10]),
        .sum_o (out_o[7]),
        .cout_o(tmp[11])
    );

    fa fa_5_i (
        .in_0_i(in_i[4]),
        .in_1_i(in_i[4] & in_i[3]),
        .cin_i (tmp[11]),
        .sum_o (out_o[8]),
        .cout_o(out_o[9])
    );

endmodule
