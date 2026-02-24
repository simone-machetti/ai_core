// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module baseline #(
    parameter int IN_SIZE_0  = 4,
    parameter int IN_SIZE_1  = 8,
    parameter int ARRAY_SIZE = 8
)(
    input  logic                                                                          clk_i,
    input  logic                                                                          rst_ni,
    input  logic [                                                         IN_SIZE_0-1:0] in_0_i [0:ARRAY_SIZE-1],
    input  logic [                                                         IN_SIZE_1-1:0] in_1_i [0:ARRAY_SIZE-1],
    output logic [(IN_SIZE_0+IN_SIZE_1+(($clog2(((IN_SIZE_1+2)/3)*ARRAY_SIZE)-1)*2))-1:0] out_o  [           0:1]
);

    localparam int SIZE_PARTIAL_PRODUCTS = IN_SIZE_0 + IN_SIZE_1;
    localparam int NUM_PARTIAL_PRODUCTS  = ((IN_SIZE_1 + 2) / 3) * ARRAY_SIZE;
    localparam int OUT_SIZE              = SIZE_PARTIAL_PRODUCTS + (($clog2(NUM_PARTIAL_PRODUCTS) - 1) * 2);

    logic [            IN_SIZE_0-1:0] in_0_q [          0:ARRAY_SIZE-1];
    logic [            IN_SIZE_1-1:0] in_1_q [          0:ARRAY_SIZE-1];
    logic [SIZE_PARTIAL_PRODUCTS-1:0] m      [0:NUM_PARTIAL_PRODUCTS-1];
    logic [             OUT_SIZE-1:0] out_d  [                     0:1];

    // -------------------------------------------------------------------------
    // Input registers
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < ARRAY_SIZE; i++) begin
                in_0_q[i] <= '0;
                in_1_q[i] <= '0;
            end
        end else begin
            in_0_q <= in_0_i;
            in_1_q <= in_1_i;
        end
    end

    // -------------------------------------------------------------------------
    // Multiplier array
    // -------------------------------------------------------------------------
    multsigned_array #(
        .IN_SIZE_0 (IN_SIZE_0),
        .IN_SIZE_1 (IN_SIZE_1),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) multsigned_array_i (
        .in_0_i(in_0_q),
        .in_1_i(in_1_q),
        .out_o (m)
    );

    // -------------------------------------------------------------------------
    // Compressor
    // -------------------------------------------------------------------------
    compressor_n_2 #(
        .IN_NUM (NUM_PARTIAL_PRODUCTS),
        .IN_SIZE(SIZE_PARTIAL_PRODUCTS)
    ) compressor_n_2_i (
        .in_i   (m),
        .sum_o  (out_d[0]),
        .carry_o(out_d[1])
    );

    // -------------------------------------------------------------------------
    // Output registers
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < 2; i++) begin
                out_o[i] <= '0;
            end
        end else begin
            out_o <= out_d;
        end
    end

endmodule
