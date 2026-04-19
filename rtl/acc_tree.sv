// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module acc_tree #(
    parameter int IN_WIDTH  = 10,
    parameter int ACC_SIZE  = 1,
    parameter int ACC_WIDTH = 40,

    localparam int OUT_WIDTH = ACC_SIZE > 0 ? ACC_WIDTH : IN_WIDTH
)(
    input  logic [ IN_WIDTH-1:0] in_i  [         0:1],
    input  logic [ACC_WIDTH-1:0] acc_i [0:ACC_SIZE-1],
    output logic [OUT_WIDTH-1:0] out_o [         0:1]
);

    genvar i;
    generate 

        if (ACC_SIZE > 0) begin

            // -------------------------------------------------------------------------
            // Extender
            // -------------------------------------------------------------------------
            localparam int EXT_N_EXTEND = ACC_WIDTH - IN_WIDTH;

            logic [ACC_WIDTH-1:0] ext_n_out [0:1];

            ext_n #(
                .IN_SIZE  (2),
                .IN_WIDTH (IN_WIDTH),
                .EXTEND   (EXT_N_EXTEND),
                .IS_SIGNED(1)
            ) ext_n_i (
                .in_i (in_i),
                .out_o(ext_n_out)
            );

            // -------------------------------------------------------------------------
            // Compressor
            // -------------------------------------------------------------------------
            localparam CPR_N_2_IN_SIZE = 2 + ACC_SIZE;

            logic [ACC_WIDTH-1:0] cpr_n_in [0:CPR_N_2_IN_SIZE-1];

            assign cpr_n_in[0] = ext_n_out[0];
            assign cpr_n_in[1] = ext_n_out[1];

            for (i = 0; i < ACC_SIZE; i++) begin
                assign cpr_n_in[2+i] = acc_i[i];
            end

            cpr_n_2 #(
                .IN_SIZE     (CPR_N_2_IN_SIZE),
                .IN_WIDTH    (ACC_WIDTH),
                .MAX_EXT_BITS(0)
            ) cpr_n_2_i (
                .in_i   (cpr_n_in),
                .sum_o  (out_o[0]),
                .carry_o(out_o[1])
            );
    
        end else begin

            assign out_o = in_i;

        end

    endgenerate

endmodule
