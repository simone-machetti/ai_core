// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module add_mult_array #(
    parameter int IN_SIZE_0 = 4,
    parameter int IN_SIZE_1 = 8
)(
    input  logic [        IN_SIZE_0-1:0] in_0_i [ 0:7],
    input  logic [        IN_SIZE_1-1:0] in_1_i [ 0:7],
    output logic [((IN_SIZE_1+1)*2)-1:0] out_o  [0:11]
);

    localparam int IN_MUL_SIZE = IN_SIZE_1 + 1;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 2) begin : gen_mul

            logic signed [8:0] sum_0;
            logic signed [8:0] sum_1;

            always_comb begin
                sum_0 = $signed(in_0_i[i+1]) + $signed(in_1_i[i]);
                sum_1 = $signed(in_0_i[i])   + $signed(in_1_i[i+1]);
            end

            multsigned #(
                .IN_SIZE_0(IN_MUL_SIZE),
                .IN_SIZE_1(IN_MUL_SIZE)
            ) multsigned_i (
                .in_0_i(sum_0),
                .in_1_i(sum_1),
                .out_o (out_o[(i/2)*3:(i/2)*3+2])
            );
        end
    endgenerate

endmodule
