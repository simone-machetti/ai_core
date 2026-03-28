// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module booth_r4_cell #(
    parameter int IN_WIDTH = 16,

    localparam int OUT_WIDTH = IN_WIDTH + 2
)(
    input  logic [ IN_WIDTH-1:0] mult_i,
    input  logic [          2:0] sel_i,
    output logic [OUT_WIDTH-1:0] pp_o
);

    logic [OUT_WIDTH-1:0] m_ext;

    assign m_ext = { {2{mult_i[IN_WIDTH-1]}}, mult_i};

    always_comb begin
        unique case (sel_i)
            3'b000:  pp_o = '0;
            3'b111:  pp_o = '0;
            3'b001:  pp_o = m_ext;
            3'b010:  pp_o = m_ext;
            3'b011:  pp_o = m_ext <<< 1;
            3'b100:  pp_o = -(m_ext <<< 1);
            3'b101:  pp_o = -m_ext;
            3'b110:  pp_o = -m_ext;
            default: pp_o = '0;
        endcase
    end

endmodule
