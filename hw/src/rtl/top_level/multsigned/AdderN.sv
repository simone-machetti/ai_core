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

module AdderN #(
    parameter int SIZE = 18
)(
    input  logic [SIZE-1:0] in_0_i,
    input  logic [SIZE-1:0] in_1_i,
    output logic [SIZE-1:0] out_o
);

    assign out_o = in_0_i + in_1_i;

endmodule
