// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */

`timescale 1 ns/1 ps

module multsigned #(
    parameter int IN_SIZE_0 = 4,
    parameter int IN_SIZE_1 = 8,

    // Internal usage only
    parameter int PP_NUM  = ((IN_SIZE_1 + 2) / 3),
    parameter int PP_SIZE = (IN_SIZE_0 + IN_SIZE_1)
)(
    input  logic [IN_SIZE_0-1:0] in_0_i,
    input  logic [IN_SIZE_1-1:0] in_1_i,
    output logic [  PP_SIZE-1:0] out_o [0:PP_NUM-1]
);

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    logic [        3:0] m  [0:PP_NUM-1];
    logic [PP_SIZE-1:0] e;
    logic [PP_SIZE-1:0] s0 [0:PP_NUM-1];
    logic [PP_SIZE-1:0] s1 [0:PP_NUM-1];
    logic [PP_SIZE-1:0] s2 [0:PP_NUM-1];
    logic [PP_SIZE-1:0] s3 [0:PP_NUM-1];

    // -------------------------------------------------------------------------
    // Safe access to multiplier bits
    // -------------------------------------------------------------------------
    function automatic logic bbit(input int idx);
        if (idx < 0) begin
            bbit = 1'b0;
        end else if (idx >= IN_SIZE_1) begin
            bbit = in_1_i[IN_SIZE_1-1];
        end else begin
            bbit = in_1_i[idx];
        end
    endfunction

    // -------------------------------------------------------------------------
    // Encoder generation (radix-8)
    // window i: {B[3i+2], B[3i+1], B[3i], B[3i-1]}
    // -------------------------------------------------------------------------
    genvar i;
    generate
      for (i = 0; i < PP_NUM; i++) begin : gen_enc
        logic [3:0] win;

        always_comb begin
          win = {bbit(3*i+2), bbit(3*i+1), bbit(3*i), bbit(3*i-1)};
        end

        encoder encoder_i (
          .in_i  (win),
          .out_o (m[i])
        );
      end
    endgenerate

    // -------------------------------------------------------------------------
    // Extender + first multiple generator
    // -------------------------------------------------------------------------
    sign_extender #(
        .IN_SIZE (IN_SIZE_0),
        .OUT_SIZE(PP_SIZE)
    ) extender_i (
        .in_i (in_0_i),
        .out_o(e)
    );

    shifter_1 #(
        .SIZE(PP_SIZE)
    ) shifter_1_i (
        .in_i   (e),
        .out_0_o(s0[0]),
        .out_1_o(s1[0]),
        .out_2_o(s2[0]),
        .out_3_o(s3[0])
    );

    // -------------------------------------------------------------------------
    // Shifter chain + muxes
    // -------------------------------------------------------------------------
    genvar j;
    generate
        for (j = 0; j < PP_NUM-1; j++) begin : gen_stage
            shifter_2 #(
                .SIZE(PP_SIZE)
            ) shifter_2_i (
                .in_0_i (s0[j]),
                .in_1_i (s1[j]),
                .in_2_i (s2[j]),
                .in_3_i (s3[j]),
                .out_0_o(s0[j+1]),
                .out_1_o(s1[j+1]),
                .out_2_o(s2[j+1]),
                .out_3_o(s3[j+1])
            );

            mux_9_1 #(
                .SIZE(PP_SIZE)
            ) mux_9_1_i (
                .in_0_i(s0[j]),
                .in_1_i(s1[j]),
                .in_2_i(s2[j]),
                .in_3_i(s3[j]),
                .sel_i (m[j]),
                .out_o (out_o[j])
            );
        end
    endgenerate

    mux_9_1 #(
        .SIZE(PP_SIZE)
    ) mux_9_1_last_i (
        .in_0_i(s0[PP_NUM-1]),
        .in_1_i(s1[PP_NUM-1]),
        .in_2_i(s2[PP_NUM-1]),
        .in_3_i(s3[PP_NUM-1]),
        .sel_i (m[PP_NUM-1]),
        .out_o (out_o[PP_NUM-1])
    );

endmodule
