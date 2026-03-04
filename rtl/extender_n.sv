// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module extender_n #(
    parameter int IN_NUM    = 2,
    parameter int IN_SIZE   = 8,
    parameter bit IS_SIGNED = 1,
    parameter int EXTEND    = 4,
    parameter bit IS_SHIFT  = 0
)(
    input  logic [       IN_SIZE-1:0] in_i  [0:IN_NUM-1],
    output logic [IN_SIZE+EXTEND-1:0] out_o [0:IN_NUM-1]
);

    logic [IN_SIZE+EXTEND-1:0] tmp [0:IN_NUM-1];

    genvar i;
    generate
        for (i = 0; i < IN_NUM; i++) begin : gen_extend
            if (IS_SIGNED) begin
                assign tmp[i] = {{EXTEND{in_i[i][IN_SIZE-1]}}, in_i[i]};
            end else begin
                assign tmp[i] = {{EXTEND{1'b0}}, in_i[i]};
            end
        end
    endgenerate

    generate
        for (i = 0; i < IN_NUM; i++) begin : gen_shift
            if (IS_SHIFT) begin
                assign out_o[i] = {tmp[i][IN_SIZE-1:0], {EXTEND{1'b0}}};
            end else begin
                assign out_o[i] = tmp[i];
            end
        end
    endgenerate

endmodule
