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

module testbench #(
    parameter int IN_SIZE_0 = 4,
    parameter int IN_SIZE_1 = 8
);

    // ---------------------------
    // Local parameters
    // ---------------------------
    localparam int OUT_SIZE = IN_SIZE_0 + IN_SIZE_1;

    // ---------------------------
    // DUT signals (signed)
    // ---------------------------
    logic signed [IN_SIZE_0-1:0] A_i;
    logic signed [IN_SIZE_1-1:0] B_i;
    logic signed [OUT_SIZE-1:0]  O_o;

    logic signed [OUT_SIZE-1:0]  tmp;

    // ---------------------------
    // DUT
    // ---------------------------
`ifdef POST_SYN_SIM

    multsigned multsigned_i (
        .in_0_i(A_i),
        .in_1_i(B_i),
        .out_o (O_o)
    );

`else

    multsigned #(
        .IN_SIZE_0(IN_SIZE_0),
        .IN_SIZE_1(IN_SIZE_1)
    ) multsigned_i (
        .in_0_i(A_i),
        .in_1_i(B_i),
        .out_o (O_o)
    );

`endif

    int i;
    initial begin
        $display("\nStarting random signed multiplication test... A=%0d bits, B=%0d bits\n", IN_SIZE_0, IN_SIZE_1);

`ifdef VCD

        $dumpfile("activity.vcd");
        $dumpvars(0, testbench.multsigned_i);

`endif

        for (i = 0; i < 1000; i++) begin

            A_i = $signed($urandom());
            B_i = $signed($urandom());

            tmp = $signed(A_i) * $signed(B_i);
            #1;

            if (O_o !== tmp) begin
                $error("Mismatch at iter %0d: A=%0d B=%0d | DUT=%0d REF=%0d",
                       i, $signed(A_i), $signed(B_i), $signed(O_o), $signed(tmp));
                $fatal;
            end
        end

`ifdef VCD

        $dumpoff;

`endif
        $display("All tests PASSED!\n");
        $finish;
    end

endmodule
