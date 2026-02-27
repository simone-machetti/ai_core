// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module extender_n #(
    parameter int IN_NUM    = 2,
    parameter int IN_SIZE   = 8,
    parameter int IS_SIGNED = 1,
    parameter int EXTEND    = 4
)(
    input  logic [       IN_SIZE-1:0] in_i  [0:IN_NUM-1],
    output logic [IN_SIZE+EXTEND-1:0] out_o [0:IN_NUM-1]
);

    genvar i;
    generate
        for (i = 0; i < IN_NUM; i++) begin : gen_extend
            if (IS_SIGNED) begin
                assign out_o[i] = {{EXTEND{in_i[i][IN_SIZE-1]}}, in_i[i]};
            end else begin
                assign out_o[i] = {{EXTEND{1'b0}}, in_i[i]};
            end
        end
    endgenerate

endmodule
