// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module multsigned #(
    parameter int IN_SIZE_0 = 4,
    parameter int IN_SIZE_1 = 8
)(
    input  logic [            IN_SIZE_0-1:0] in_0_i,
    input  logic [            IN_SIZE_1-1:0] in_1_i,
    output logic [(IN_SIZE_0+IN_SIZE_1)-1:0] out_o [0:((IN_SIZE_1+2)/3)-1]
);

    localparam int OUT_SIZE             = IN_SIZE_0 + IN_SIZE_1;
    localparam int NUM_PARTIAL_PRODUCTS = (IN_SIZE_1 + 2) / 3;

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    logic [         3:0] m  [0:NUM_PARTIAL_PRODUCTS-1];
    logic [OUT_SIZE-1:0] e;
    logic [OUT_SIZE-1:0] s0 [0:NUM_PARTIAL_PRODUCTS-1];
    logic [OUT_SIZE-1:0] s1 [0:NUM_PARTIAL_PRODUCTS-1];
    logic [OUT_SIZE-1:0] s2 [0:NUM_PARTIAL_PRODUCTS-1];
    logic [OUT_SIZE-1:0] s3 [0:NUM_PARTIAL_PRODUCTS-1];

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
      for (i = 0; i < NUM_PARTIAL_PRODUCTS; i++) begin : gen_enc
        logic [3:0] win;

        always_comb begin
          win = { bbit(3*i+2), bbit(3*i+1), bbit(3*i), bbit(3*i-1) };
        end

        Encoder encoder_i (
          .in_i  (win),
          .out_o (m[i])
        );
      end
    endgenerate

    // -------------------------------------------------------------------------
    // Extender + first multiple generator
    // -------------------------------------------------------------------------
    Extender #(
        .IN_SIZE(IN_SIZE_0),
        .OUT_SIZE(OUT_SIZE)
    ) extender_i (
        .in_i (in_0_i),
        .out_o(e)
    );

    Shifter1 #(
        .SIZE(OUT_SIZE)
    ) shifter1_i (
        .in_i   (e),
        .out_0_o(s0[0]),
        .out_1_o(s1[0]),
        .out_2_o(s2[0]),
        .out_3_o(s3[0])
    );

    // -------------------------------------------------------------------------
    // Shifter2 chain + muxes
    // -------------------------------------------------------------------------
    genvar j;
    generate
        for (j = 0; j < NUM_PARTIAL_PRODUCTS-1; j++) begin : gen_stage
            Shifter2 #(
                .SIZE(OUT_SIZE)
            ) shifter2_i (
                .in_0_i (s0[j]),
                .in_1_i (s1[j]),
                .in_2_i (s2[j]),
                .in_3_i (s3[j]),
                .out_0_o(s0[j+1]),
                .out_1_o(s1[j+1]),
                .out_2_o(s2[j+1]),
                .out_3_o(s3[j+1])
            );

            Mux9x1 #(
                .SIZE(OUT_SIZE)
            ) mux9x1_i (
                .in_0_i (s0[j]),
                .in_1_i (s1[j]),
                .in_2_i (s2[j]),
                .in_3_i (s3[j]),
                .sel_i  (m[j]),
                .out_o  (out_o[j])
            );
        end
    endgenerate

    // Last mux
    Mux9x1 #(
        .SIZE(OUT_SIZE)
    ) mux9x1_last_i (
        .in_0_i (s0[NUM_PARTIAL_PRODUCTS-1]),
        .in_1_i (s1[NUM_PARTIAL_PRODUCTS-1]),
        .in_2_i (s2[NUM_PARTIAL_PRODUCTS-1]),
        .in_3_i (s3[NUM_PARTIAL_PRODUCTS-1]),
        .sel_i  (m[NUM_PARTIAL_PRODUCTS-1]),
        .out_o  (out_o[NUM_PARTIAL_PRODUCTS-1])
    );

endmodule
