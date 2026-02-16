// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module multsigned_array #(
    parameter int IN_SIZE_0  = 4,
    parameter int IN_SIZE_1  = 8,
    parameter int SIZE_ARRAY = 8
)(
    input  logic [            IN_SIZE_0-1:0] in_0_i [                    0:SIZE_ARRAY-1],
    input  logic [            IN_SIZE_1-1:0] in_1_i [                    0:SIZE_ARRAY-1],
    output logic [(IN_SIZE_0+IN_SIZE_1)-1:0] out_o  [0:(((IN_SIZE_1+2)/3)*SIZE_ARRAY)-1]
);

    localparam int NUM_PARTIAL_PRODUCTS = (IN_SIZE_1 + 2) / 3;

    genvar i;
    generate
        for (i = 0; i < SIZE_ARRAY; i++) begin
            multsigned #(
                .IN_SIZE_0(IN_SIZE_0),
                .IN_SIZE_1(IN_SIZE_1)
            ) multsigned_i (
                .in_0_i(in_0_i[i]),
                .in_1_i(in_1_i[i]),
                .out_o (out_o[i*NUM_PARTIAL_PRODUCTS:(i*NUM_PARTIAL_PRODUCTS)+NUM_PARTIAL_PRODUCTS-1])
            );
        end
    endgenerate

endmodule
