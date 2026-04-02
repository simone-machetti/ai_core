// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module sqr_4x4 #(
    localparam int IN_SIZE       = 64,
    localparam int IN_WIDTH_A    = 4,
    localparam int IN_WIDTH_B    = 8,
    localparam int NUM_LANES     = 8,
    localparam int NUM_SUB_LANES = 2,
    localparam int PP_SIZE       = 2 * NUM_SUB_LANES * NUM_LANES,
    localparam int CPR_IN_SIZE   = IN_SIZE / NUM_LANES,
    localparam int CPR_IN_WIDTH  = (IN_WIDTH_A + 2) * 2,
    localparam int PP_SUB_SHIFT  = 4,
    localparam int PP_WIDTH      = CPR_IN_WIDTH + $clog2(CPR_IN_SIZE) + 1 + PP_SUB_SHIFT
)(
    input  logic [IN_WIDTH_A-1:0] a_i  [0:IN_SIZE-1],
    input  logic [IN_WIDTH_B-1:0] b_i  [0:IN_SIZE-1],
    output logic [  PP_WIDTH-1:0] pp_o [0:PP_SIZE-1]
);

    genvar lane, sub_lane, i;
    generate

        localparam int ADD_SQR_ARRAY_IN_SIZE      = IN_SIZE / NUM_LANES;
        localparam int ADD_SQR_ARRAY_IN_WIDTH_A   = IN_WIDTH_A;
        localparam int ADD_SQR_ARRAY_IN_WIDTH_B   = IN_WIDTH_B / 2;
        localparam int ADD_SQR_ARRAY_IN_SQR_WIDTH = ADD_SQR_ARRAY_IN_WIDTH_A + 2;
        localparam int ADD_SQR_ARRAY_PP_SIZE      = ADD_SQR_ARRAY_IN_SIZE;
        localparam int ADD_SQR_ARRAY_PP_WIDTH     = ADD_SQR_ARRAY_IN_SQR_WIDTH * 2;

        for (lane = 0; lane < NUM_LANES; lane++) begin : gen_lane

            localparam int ADD_SQR_ARRAY_IN_SIZE_BASE = lane * ADD_SQR_ARRAY_IN_SIZE;

            for (sub_lane = 0; sub_lane < NUM_SUB_LANES; sub_lane++) begin : gen_sub_lane

                localparam int ADD_SQR_ARRAY_IN_WIDTH_BASE = sub_lane * ADD_SQR_ARRAY_IN_WIDTH_B;
                localparam int ADD_SQR_ARRAY_IS_SIGNED     = sub_lane == 0 ? 0 : 1;

                logic [ADD_SQR_ARRAY_IN_WIDTH_A-1:0] a  [0:ADD_SQR_ARRAY_IN_SIZE-1];
                logic [ADD_SQR_ARRAY_IN_WIDTH_B-1:0] b  [0:ADD_SQR_ARRAY_IN_SIZE-1];
                logic [  ADD_SQR_ARRAY_PP_WIDTH-1:0] pp [0:ADD_SQR_ARRAY_PP_SIZE-1];

                for (i = 0; i < ADD_SQR_ARRAY_IN_SIZE; i++) begin
                    assign a[i] = a_i[ADD_SQR_ARRAY_IN_SIZE_BASE+i];
                    assign b[i] = b_i[ADD_SQR_ARRAY_IN_SIZE_BASE+i][ADD_SQR_ARRAY_IN_WIDTH_BASE+:ADD_SQR_ARRAY_IN_WIDTH_B];
                end

                add_sqr_array #(
                    .IN_SIZE  (ADD_SQR_ARRAY_IN_SIZE),
                    .IS_SIGNED(ADD_SQR_ARRAY_IS_SIGNED)
                ) add_sqr_array_i (
                    .a_i (a),
                    .b_i (b),
                    .pp_o(pp)
                );

                localparam int CPR_N_2_IN_SIZE      = ADD_SQR_ARRAY_PP_SIZE;
                localparam int CPR_N_2_IN_WIDTH     = ADD_SQR_ARRAY_PP_WIDTH;
                localparam int CPR_N_2_MAX_EXT_BITS = -1;
                localparam int CPR_N_2_PP_OUT_WIDTH = CPR_N_2_IN_WIDTH + $clog2(CPR_N_2_IN_SIZE) + 1;

                localparam int CPR_N_2_OUT_OFFSET = (lane * NUM_SUB_LANES * 2) + (sub_lane * 2);
                localparam int CPR_N_2_OUT_SHIFT  = sub_lane * PP_SUB_SHIFT;
                localparam int CPR_N_2_OUT_MARG   = PP_WIDTH - CPR_N_2_PP_OUT_WIDTH - CPR_N_2_OUT_SHIFT;
                localparam int CPR_N_2_OUT_CUT    = CPR_N_2_PP_OUT_WIDTH + CPR_N_2_OUT_MARG;

                logic [CPR_N_2_PP_OUT_WIDTH-1:0] pp_out [0:1];

                cpr_n_2 #(
                    .IN_SIZE     (CPR_N_2_IN_SIZE),
                    .IN_WIDTH    (CPR_N_2_IN_WIDTH),
                    .MAX_EXT_BITS(CPR_N_2_MAX_EXT_BITS)
                ) cpr_n_2_i (
                    .in_i   (pp),
                    .sum_o  (pp_out[0]),
                    .carry_o(pp_out[1])
                );

                if (CPR_N_2_OUT_MARG > 0) begin

                    assign pp_o[CPR_N_2_OUT_OFFSET+0] = {{CPR_N_2_OUT_MARG{pp_out[0][CPR_N_2_PP_OUT_WIDTH-1]}}, pp_out[0], {CPR_N_2_OUT_SHIFT{1'b0}}};
                    assign pp_o[CPR_N_2_OUT_OFFSET+1] = {{CPR_N_2_OUT_MARG{pp_out[1][CPR_N_2_PP_OUT_WIDTH-1]}}, pp_out[1], {CPR_N_2_OUT_SHIFT{1'b0}}};

                end else begin

                    assign pp_o[CPR_N_2_OUT_OFFSET+0] = {pp_out[0][CPR_N_2_OUT_CUT-1:0], {CPR_N_2_OUT_SHIFT{1'b0}}};
                    assign pp_o[CPR_N_2_OUT_OFFSET+1] = {pp_out[1][CPR_N_2_OUT_CUT-1:0], {CPR_N_2_OUT_SHIFT{1'b0}}};

                end

            end

        end

    endgenerate

endmodule
