// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module baseline #(
    parameter int IN_SIZE_0  = 4,
    parameter int IN_SIZE_1  = 8,
    parameter int SIZE_ARRAY = 8
)(
    input  logic [             IN_SIZE_0-1:0]  in_0_i [0:SIZE_ARRAY-1],
    input  logic [             IN_SIZE_1-1:0]  in_1_i [0:SIZE_ARRAY-1],
    output logic [(IN_SIZE_0+IN_SIZE_1)+8-1:0] out_o  [0:1]
);

    localparam int SIZE_PARTIAL_PRODUCTS = IN_SIZE_0 + IN_SIZE_1;
    localparam int NUM_PARTIAL_PRODUCTS  = ((IN_SIZE_1 + 2) / 3) * SIZE_ARRAY;

    logic [SIZE_PARTIAL_PRODUCTS-1:0] m [0:NUM_PARTIAL_PRODUCTS-1];

    multsigned_array #(
        .IN_SIZE_0 (IN_SIZE_0),
        .IN_SIZE_1 (IN_SIZE_1),
        .SIZE_ARRAY(SIZE_ARRAY)
    ) multsigned_array_i (
        .in_0_i(in_0_i),
        .in_1_i(in_1_i),
        .out_o (m)
    );

    compressor_24_2 #(
        .IN_SIZE (SIZE_PARTIAL_PRODUCTS),
        .OUT_SIZE(SIZE_PARTIAL_PRODUCTS+8)
    ) compressor_24_2_i (
        .in_i (m),
        .out_o(out_o)
    );

endmodule
