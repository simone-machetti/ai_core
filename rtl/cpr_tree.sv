// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module cpr_tree #(
    parameter int PP_SIZE  = 64,
    parameter int PP_WIDTH = 10,
    parameter int PP_GROUP = 2,
    parameter int PP_SHIFT = 2,

    localparam int OUT_WIDTH = PP_WIDTH + $clog2(PP_SIZE) + 1 + (PP_SHIFT * (PP_GROUP - 1))
)(
    input  logic [ PP_WIDTH-1:0] pp_i  [0:PP_SIZE-1],
    output logic [OUT_WIDTH-1:0] out_o [        0:1]
);

    genvar cpr, i;
    generate

        localparam int CPR_N_2_IN_SIZE       = PP_SIZE / PP_GROUP;
        localparam int CPR_N_2_OUT_WIDTH     = PP_WIDTH + $clog2(CPR_N_2_IN_SIZE) + 1;
        localparam int CPR_N_2_LAST_IN_SIZE  = PP_GROUP * 2;
        localparam int CPR_N_2_LAST_IN_WIDTH = CPR_N_2_OUT_WIDTH + (PP_SHIFT * (PP_GROUP - 1));

        logic [CPR_N_2_LAST_IN_WIDTH-1:0] cpr_n_2_last_in [0:CPR_N_2_LAST_IN_SIZE-1];

        for (cpr = 0; cpr < PP_GROUP; cpr++) begin

            logic [         PP_WIDTH-1:0] cpr_n_2_in  [0:CPR_N_2_IN_SIZE-1];
            logic [CPR_N_2_OUT_WIDTH-1:0] cpr_n_2_out [                0:1];

            for (i = 0; i < CPR_N_2_IN_SIZE; i++) begin
                assign cpr_n_2_in[i] = pp_i[i*PP_GROUP+cpr];
            end

            cpr_n_2 #(
                .IN_SIZE     (CPR_N_2_IN_SIZE),
                .IN_WIDTH    (PP_WIDTH),
                .MAX_EXT_BITS(-1)
            ) cpr_n_2_i (
                .in_i   (cpr_n_2_in),
                .sum_o  (cpr_n_2_out[0]),
                .carry_o(cpr_n_2_out[1])
            );

            localparam int CPR_N_2_OUT_OFFSET = cpr * 2;
            localparam int CPR_N_2_OUT_SHIFT  = cpr * PP_SHIFT;
            localparam int CPR_N_2_OUT_MARG   = CPR_N_2_LAST_IN_WIDTH - CPR_N_2_OUT_WIDTH - CPR_N_2_OUT_SHIFT;
            localparam int CPR_N_2_OUT_CUT    = CPR_N_2_OUT_WIDTH + CPR_N_2_OUT_MARG;

            if (CPR_N_2_OUT_MARG > 0) begin

                assign cpr_n_2_last_in[CPR_N_2_OUT_OFFSET+0] = {{CPR_N_2_OUT_MARG{cpr_n_2_out[0][CPR_N_2_OUT_WIDTH-1]}}, cpr_n_2_out[0], {CPR_N_2_OUT_SHIFT{1'b0}}};
                assign cpr_n_2_last_in[CPR_N_2_OUT_OFFSET+1] = {{CPR_N_2_OUT_MARG{cpr_n_2_out[1][CPR_N_2_OUT_WIDTH-1]}}, cpr_n_2_out[1], {CPR_N_2_OUT_SHIFT{1'b0}}};

            end else begin

                assign cpr_n_2_last_in[CPR_N_2_OUT_OFFSET+0] = {cpr_n_2_out[0][CPR_N_2_OUT_CUT-1:0], {CPR_N_2_OUT_SHIFT{1'b0}}};
                assign cpr_n_2_last_in[CPR_N_2_OUT_OFFSET+1] = {cpr_n_2_out[1][CPR_N_2_OUT_CUT-1:0], {CPR_N_2_OUT_SHIFT{1'b0}}};

            end

        end

        cpr_n_2 #(
            .IN_SIZE     (CPR_N_2_LAST_IN_SIZE),
            .IN_WIDTH    (CPR_N_2_LAST_IN_WIDTH),
            .MAX_EXT_BITS(0)
        ) cpr_n_2_last_i (
            .in_i   (cpr_n_2_last_in),
            .sum_o  (out_o[0]),
            .carry_o(out_o[1])
        );

    endgenerate

endmodule
