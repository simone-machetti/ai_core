// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */

`timescale 1 ns/1 ps

module ext_n #(
    parameter int IN_SIZE   = 2,
    parameter int IN_WIDTH  = 8,
    parameter int EXTEND    = 4,
    parameter bit IS_SIGNED = 1,

    localparam int OUT_WIDTH = IN_WIDTH + EXTEND,
    localparam int OUT_SIZE  = IN_SIZE
)(
    input  logic [ IN_WIDTH-1:0] in_i  [ 0:IN_SIZE-1],
    output logic [OUT_WIDTH-1:0] out_o [0:OUT_SIZE-1]
);

    genvar i;
    generate
        for (i = 0; i < IN_SIZE; i++) begin
            assign out_o[i] = IS_SIGNED ? {{EXTEND{in_i[i][IN_WIDTH-1]}}, in_i[i]} : {{EXTEND{1'b0}}, in_i[i]};
        end
    endgenerate

endmodule
