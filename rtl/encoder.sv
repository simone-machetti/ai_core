// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module encoder (
    input  logic [3:0] in_i,
    output logic [3:0] out_o
);

    always_comb begin
        unique case (in_i)

            4'b0000: out_o = 4'b0000; //  0
            4'b0001: out_o = 4'b0001; // +1
            4'b0010: out_o = 4'b0001; // +1
            4'b0011: out_o = 4'b0010; // +2
            4'b0100: out_o = 4'b0010; // +2
            4'b0101: out_o = 4'b0011; // +3
            4'b0110: out_o = 4'b0011; // +3
            4'b0111: out_o = 4'b0100; // +4

            4'b1000: out_o = 4'b1100; // -4
            4'b1001: out_o = 4'b1011; // -3
            4'b1010: out_o = 4'b1011; // -3
            4'b1011: out_o = 4'b1010; // -2
            4'b1100: out_o = 4'b1010; // -2
            4'b1101: out_o = 4'b1001; // -1
            4'b1110: out_o = 4'b1001; // -1
            4'b1111: out_o = 4'b0000; //  0

            default: out_o = 4'b0000;
        endcase
    end

endmodule
