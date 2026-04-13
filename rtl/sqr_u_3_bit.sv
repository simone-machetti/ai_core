// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

module sqr_u_3_bit (
    input  logic [2:0] in_i,
    output logic [5:0] out_o
);

    assign out_o[0] = in_i[0];
    assign out_o[1] = 1'b0;
    assign out_o[2] = in_i[1] & (~in_i[0]);
    assign out_o[3] = in_i[0] & (in_i[2] ^ in_i[1]);
    assign out_o[4] = (in_i[2] & (~in_i[1])) | (in_i[2] & in_i[0]);
    assign out_o[5] = in_i[2] & in_i[1];

endmodule
