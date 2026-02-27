// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module shifter_n #(
    parameter int IN_NUM  = 2,
    parameter int IN_SIZE = 8,
    parameter int IS_LEFT = 1,
    parameter int SHIFT   = 4
)(
    input  logic [IN_SIZE-1:0] in_i  [0:IN_NUM-1],
    output logic [IN_SIZE-1:0] out_o [0:IN_NUM-1]
);

    genvar i;
    generate
        for (i = 0; i < IN_NUM; i++) begin : gen_shift
            if (IS_LEFT) begin
                assign out_o[i] = {in_i[i][IN_SIZE-SHIFT-1:0], {SHIFT{1'b0}}};
            end else begin
                assign out_o[i] = {{SHIFT{in_i[i][IN_SIZE-1]}}, in_i[i][IN_SIZE-1:SHIFT]};
            end
        end
    endgenerate

endmodule
