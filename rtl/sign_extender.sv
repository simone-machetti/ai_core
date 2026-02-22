// -----------------------------------------------------------------------------
// Author: Jaime Joven Murillo
// -----------------------------------------------------------------------------

module sign_extender #(
    parameter int IN_SIZE  = 8,
    parameter int OUT_SIZE = 16
)(
    input  logic [ IN_SIZE-1:0] in_i,
    output logic [OUT_SIZE-1:0] out_o
);

    assign out_o = {{(OUT_SIZE-IN_SIZE){in_i[IN_SIZE-1]}}, in_i};

endmodule
