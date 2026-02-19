// -----------------------------------------------------------------------------
// Author: Jaime Joven Murillo
// -----------------------------------------------------------------------------

module compressor_4_2_n_bit #(
    parameter int INPUT_WIDTH  = 14,
    parameter int OUTPUT_WIDTH = 15,
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
