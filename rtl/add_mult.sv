// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module add_mult #(
    parameter int IN_SIZE_0 = 4,
    parameter int IN_SIZE_1 = 8,

    // Internal usage only
    parameter int IN_MUL_SIZE = (IN_SIZE_0 > IN_SIZE_1) ? (IN_SIZE_0 + 1) : (IN_SIZE_1 + 1),
    parameter int PP_PER_MUL  = ((IN_MUL_SIZE + 2) / 3),
    parameter int PP_SIZE     = (IN_MUL_SIZE * 2)
)(
    input  logic [IN_SIZE_0-1:0] in_0_i [           0:1],
    input  logic [IN_SIZE_1-1:0] in_1_i [           0:1],
    output logic [  PP_SIZE-1:0] out_o  [0:PP_PER_MUL-1]
);

    logic signed [IN_MUL_SIZE-1:0] sum_0;
    logic signed [IN_MUL_SIZE-1:0] sum_1;

    always_comb begin
        sum_0 = IN_MUL_SIZE'($signed(in_0_i[1])) + IN_MUL_SIZE'($signed(in_1_i[0]));
        sum_1 = IN_MUL_SIZE'($signed(in_0_i[0])) + IN_MUL_SIZE'($signed(in_1_i[1]));
    end

    multsigned #(
        .IN_SIZE_0(IN_MUL_SIZE),
        .IN_SIZE_1(IN_MUL_SIZE)
    ) multsigned_i (
        .in_0_i(sum_0),
        .in_1_i(sum_1),
        .out_o (out_o)
    );

endmodule
