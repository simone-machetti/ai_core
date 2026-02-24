// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module multsigned_array #(
    parameter int IN_SIZE_0  = 4,
    parameter int IN_SIZE_1  = 8,
    parameter int ARRAY_SIZE = 8,

    // Internal usage only
    parameter int PP_PER_MUL   = ((IN_SIZE_1 + 2) / 3),
    parameter int PP_PER_ARRAY = (PP_PER_MUL * ARRAY_SIZE),
    parameter int PP_SIZE      = (IN_SIZE_0 + IN_SIZE_1)
)(
    input  logic [IN_SIZE_0-1:0] in_0_i [  0:ARRAY_SIZE-1],
    input  logic [IN_SIZE_1-1:0] in_1_i [  0:ARRAY_SIZE-1],
    output logic [  PP_SIZE-1:0] out_o  [0:PP_PER_ARRAY-1]
);

    genvar i;
    generate
        for (i = 0; i < ARRAY_SIZE; i++) begin
            multsigned #(
                .IN_SIZE_0(IN_SIZE_0),
                .IN_SIZE_1(IN_SIZE_1)
            ) multsigned_i (
                .in_0_i(in_0_i[i]),
                .in_1_i(in_1_i[i]),
                .out_o (out_o[i*PP_PER_MUL:(i*PP_PER_MUL)+PP_PER_MUL-1])
            );
        end
    endgenerate

endmodule
