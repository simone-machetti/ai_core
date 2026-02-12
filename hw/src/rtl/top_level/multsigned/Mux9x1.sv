// -----------------------------------------------------------------------------
// Confidential and Proprietary Information
//
// This file contains confidential and proprietary information of
// Huawei Technologies Co., Ltd.
//
// Unauthorized copying, distribution, modification, or disclosure of this
// file, in whole or in part, is strictly prohibited without prior written
// permission from Huawei Technologies Co., Ltd.
//
// This material is provided for internal use only and must not be shared
// with third parties.
//
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module Mux9x1 #(
    parameter SIZE = 18
)(
    input  logic [SIZE-1:0] in_0_i, in_1_i, in_2_i, in_3_i,
    input  logic [     3:0] sel_i,
    output logic [SIZE-1:0] out_o
);

    logic            neg;
    logic [     2:0] mag;
    logic [SIZE-1:0] pos_val;

    always_comb begin
        neg = sel_i[  3];
        mag = sel_i[2:0];

        // Select magnitude (positive)
        unique case (mag)
            3'd0: pos_val = {SIZE{1'b0}};    // 0
            3'd1: pos_val = in_0_i;          // +A
            3'd2: pos_val = in_1_i;          // +2A
            3'd3: pos_val = in_2_i;          // +3A
            3'd4: pos_val = in_3_i;          // +4A
            default: pos_val = {SIZE{1'b0}}; // 0
        endcase

        // Apply sign (two's complement if neg)
        if (neg)
            out_o = (~pos_val) + {{(SIZE-1){1'b0}}, 1'b1};
        else
            out_o = pos_val;
    end

endmodule
