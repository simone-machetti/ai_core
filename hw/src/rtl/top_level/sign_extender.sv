// -----------------------------------------------------------------------------
// Author: Jaime Joven Murillo
// -----------------------------------------------------------------------------

module sign_extender #(
    parameter int IN_WIDTH  = 8,
    parameter int OUT_WIDTH = 16
)(
    input  logic                 is_signed,
    input  logic [ IN_WIDTH-1:0] data_in,
    output logic [OUT_WIDTH-1:0] data_out
);
    logic extended_bit;

    // If signed, repeat the MSB; if unsigned, pad with 0
    assign extended_bit = is_signed ? data_in[IN_WIDTH-1] : 1'b0;
    assign data_out     = {{(OUT_WIDTH-IN_WIDTH){extended_bit}}, data_in};

endmodule
