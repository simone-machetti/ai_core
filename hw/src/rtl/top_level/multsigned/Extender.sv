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

module Extender #(
    parameter int IN_SIZE  = 4,
    parameter int OUT_SIZE = 8
)(
    input  logic [ IN_SIZE-1:0] in_i,
    output logic [OUT_SIZE-1:0] out_o
);

    assign out_o = {{(OUT_SIZE-IN_SIZE){in_i[IN_SIZE-1]}}, in_i};

endmodule
