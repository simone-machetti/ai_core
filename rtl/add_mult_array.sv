// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module add_mult_array #(
    parameter int IN_SIZE_0  = 4,
    parameter int IN_SIZE_1  = 8,
    parameter int ARRAY_SIZE = 8,

    // Internal usage only
    parameter int IN_MUL_SIZE  = (IN_SIZE_0 > IN_SIZE_1) ? (IN_SIZE_0 + 1) : (IN_SIZE_1 + 1),
    parameter int PP_PER_MUL   = ((IN_MUL_SIZE + 2) / 3),
    parameter int PP_PER_ARRAY = (PP_PER_MUL * ARRAY_SIZE / 2),
    parameter int PP_SIZE      = (IN_MUL_SIZE * 2)
)(
    input  logic [IN_SIZE_0-1:0] in_0_i [  0:ARRAY_SIZE-1],
    input  logic [IN_SIZE_1-1:0] in_1_i [  0:ARRAY_SIZE-1],
    output logic [  PP_SIZE-1:0] out_o  [0:PP_PER_ARRAY-1]
);

    genvar i;
    generate
        for (i = 0; i < ARRAY_SIZE; i = i + 2) begin : gen_mul

            logic signed [IN_MUL_SIZE-1:0] sum_0;
            logic signed [IN_MUL_SIZE-1:0] sum_1;

            always_comb begin
                sum_0 = IN_MUL_SIZE'($signed(in_0_i[i+1])) + IN_MUL_SIZE'($signed(in_1_i[i]));
                sum_1 = IN_MUL_SIZE'($signed(in_0_i[i]))   + IN_MUL_SIZE'($signed(in_1_i[i+1]));
            end

            multsigned #(
                .IN_SIZE_0(IN_MUL_SIZE),
                .IN_SIZE_1(IN_MUL_SIZE)
            ) multsigned_i (
                .in_0_i(sum_0),
                .in_1_i(sum_1),
                .out_o (out_o[(i/2)*PP_PER_MUL:((i/2)*PP_PER_MUL)+(PP_PER_MUL-1)])
            );
        end
    endgenerate

endmodule
