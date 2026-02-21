// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module baseline #(
    parameter int IN_SIZE_0 = 4,
    parameter int IN_SIZE_1 = 8
)(
    input  logic                               clk_i,
    input  logic                               rst_ni,
    input  logic [              IN_SIZE_0-1:0] in_0_i [0:7],
    input  logic [              IN_SIZE_1-1:0] in_1_i [0:7],
    output logic [(IN_SIZE_0+IN_SIZE_1)+8-1:0] out_o  [0:1]
);

    localparam int SIZE_PARTIAL_PRODUCTS = IN_SIZE_0 + IN_SIZE_1;
    localparam int NUM_PARTIAL_PRODUCTS  = ((IN_SIZE_1 + 2) / 3) * 8;

    logic [                IN_SIZE_0-1:0] in_0_q [                     0:7];
    logic [                IN_SIZE_1-1:0] in_1_q [                     0:7];
    logic [    SIZE_PARTIAL_PRODUCTS-1:0] m      [0:NUM_PARTIAL_PRODUCTS-1];
    logic [(SIZE_PARTIAL_PRODUCTS+8)-1:0] out_d  [                     0:1];

    // -------------------------------------------------------------------------
    // Input registers
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < 8; i++) begin
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
        .SIZE_ARRAY(8)
    ) multsigned_array_i (
        .in_0_i(in_0_q),
        .in_1_i(in_1_q),
        .out_o (m)
    );

    // -------------------------------------------------------------------------
    // Compressor
    // -------------------------------------------------------------------------
    compressor_24_2 #(
        .IN_SIZE (SIZE_PARTIAL_PRODUCTS),
        .OUT_SIZE(SIZE_PARTIAL_PRODUCTS+8)
    ) compressor_24_2_i (
        .in_i (m),
        .out_o(out_d)
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
