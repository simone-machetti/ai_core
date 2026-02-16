// -----------------------------------------------------------------------------
// Author: Jaime Joven Murillo
// -----------------------------------------------------------------------------

// ------------------------------------------------------------------------------------
// Example with 8 bits input and 10 bits output
// Weight:    9  8  7  6  5  4  3  2  1  0
// ---------------------------------------
// Sum:             S7 S6 S5 S4 S3 S2 S1 S0
// Carry:        C7 C6 C5 C4 C3 C2 C1 C0  0   <-- Shifted Left
// Extra:        cn                           <-- The cout from the MSB
// ---------------------------------------
// RESULT:    R9 R8 R7 R6 R5 R4 R3 R2 R1 R0   (The 10-bit Final Sum, not part of this block)
// ------------------------------------------------------------------------------------
// Imprtant notes:
// ------------------------------------------------------------------------------------
// In many tree designs, cout_chain[INTERNAL_WIDTH] is actually ignored or
// handled by sign-extending the inputs beforehand.
// To ensure your signed 2's complement math never overflows, the bit-width INPUT_WIDTH must
// grow as the tree gets deeper.
// General rule is NEXT_WIDTH_INPUT = INPUT_WIDTH + log2(N_INPUTS)
// For 4:2 tree INPUT_WIDTH+2
// For 8:2 tree INPUT_WIDTH+3
// For 16:2 tree INPUT_WIDTH+4
// ------------------------------------------------------------------------------------
// Example bit level (4 bit word):
// ------------------------------------------------------------------------------------
// Imagine all inputs are 3 4'b0011. We expect a sum of 3 x 4 = 12 (4'b1100)
// Bit Position 2^3 2^2 2^1 2^0
// x1             0   0   1   1
// x2             0   0   1   1
// x3             0   0   1   1
// x4             0   0   1   1
// sum            0   0   0   0
// carry          0   1   1   0
// ------------------------------------------------------------------------------------
// Result         1   1   0   0
// Result = S + (carry << 1)
// ------------------------------------------------------------------------------------

module compressor_4_2_n_bit #(
    parameter int INPUT_WIDTH  = 12,
    parameter int OUTPUT_WIDTH = 14,
    parameter bit SHIFT_CARRY  = 1
)(
    input  logic [ INPUT_WIDTH-1:0] inputs [4],
    input  logic                    is_signed,
    output logic [OUTPUT_WIDTH-1:0] sum,
    output logic [OUTPUT_WIDTH-1:0] carry
);
    logic [OUTPUT_WIDTH-1:0] extended_inputs [4];

    generate
        for (genvar i = 0; i < 4; i++) begin : gen_extenders
            sign_extender #(
                .IN_WIDTH(INPUT_WIDTH),
                .OUT_WIDTH(OUTPUT_WIDTH)
            ) i_sign_extender (
                .is_signed(is_signed),
                .data_in(inputs[i]),
                .data_out(extended_inputs[i])
            );
        end
    endgenerate

    logic [OUTPUT_WIDTH:0]   cout_chain;
    logic [OUTPUT_WIDTH-1:0] s_internal, c_internal;

    assign cout_chain[0] = 1'b0;

    generate
        for (genvar i = 0; i < OUTPUT_WIDTH; i++) begin : gen_compressor_4_2_cell
            compressor_4_2_cell i_4_2_cell (
                .x1(extended_inputs[0][i]),
                .x2(extended_inputs[1][i]),
                .x3(extended_inputs[2][i]),
                .x4(extended_inputs[3][i]),
                .cin(cout_chain[i]),
                .cout(cout_chain[i+1]),
                .sum(s_internal[i]),
                .carry(c_internal[i])
            );
        end
    endgenerate

    generate
        if (SHIFT_CARRY) begin : gen_shifted
            assign carry = {c_internal[OUTPUT_WIDTH-2:0], 1'b0};
        end else begin : gen_no_shift
            assign carry = c_internal;
        end
    endgenerate

    assign sum = s_internal;

endmodule
