// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module testbench #(
    parameter int IN_SIZE_0 = 8,
    parameter int IN_SIZE_1 = 8
);

    localparam int OUT_SIZE = ((IN_SIZE_1 + 1) * 2) + 3;

    real clk_period = 10;

    logic clk, rst_n;

    logic [IN_SIZE_0-1:0] max_pos_0, min_neg_0;
    logic [IN_SIZE_1-1:0] max_pos_1, min_neg_1;

`ifdef POST_SYN_SIM
    logic [7:0][IN_SIZE_0-1:0] in_0;
    logic [7:0][IN_SIZE_1-1:0] in_1;
    logic [1:0][ OUT_SIZE-1:0] out;
    logic      [ OUT_SIZE-1:0] acc;

    winograd winograd_i (
        .clk_i (clk),
        .rst_ni(rst_n),
        .in_0_i(in_0),
        .in_1_i(in_1),
        .out_o (out)
    );
`else
    logic [IN_SIZE_0-1:0] in_0 [0:7];
    logic [IN_SIZE_1-1:0] in_1 [0:7];
    logic [ OUT_SIZE-1:0] out  [0:1];
    logic [ OUT_SIZE-1:0] acc;

    winograd #(
        .IN_SIZE_0 (IN_SIZE_0),
        .IN_SIZE_1 (IN_SIZE_1)
    ) winograd_i (
        .clk_i (clk),
        .rst_ni(rst_n),
        .in_0_i(in_0),
        .in_1_i(in_1),
        .out_o (out)
    );
`endif

    // -------------------------------------------------------------------------
    // Manage VCD generation
    // -------------------------------------------------------------------------
    task automatic init_vcd;
    begin
`ifdef VCD
        $dumpfile("activity.vcd");
`endif
    end
    endtask

    task automatic start_vcd;
    begin
`ifdef VCD
        $dumpvars(0, testbench.winograd_i);
`endif
    end
    endtask

    task automatic stop_vcd;
    begin
`ifdef VCD
        $dumpoff;
`endif
    end
    endtask

    // -------------------------------------------------------------------------
    // Reset DUT
    // -------------------------------------------------------------------------
    task automatic reset_dut;
    begin
        rst_n = 1'b0;
        repeat(5) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
    end
    endtask

    // -------------------------------------------------------------------------
    // Run and check
    // -------------------------------------------------------------------------
    task automatic run_and_check(
        input bit                          use_random,
        input logic signed [IN_SIZE_0-1:0] a0_fixed,
        input logic signed [IN_SIZE_1-1:0] b0_fixed,
        input logic signed [IN_SIZE_0-1:0] a1_fixed,
        input logic signed [IN_SIZE_1-1:0] b1_fixed
    );
        begin
            acc = '0;
            for (int i = 0; i < 8; i = i + 2) begin
                if (use_random) begin
                    in_0[i]   = $signed($urandom());
                    in_1[i]   = $signed($urandom());
                    in_0[i+1] = $signed($urandom());
                    in_1[i+1] = $signed($urandom());
                end else begin
                    in_0[i]   = a0_fixed;
                    in_1[i]   = b0_fixed;
                    in_0[i+1] = a1_fixed;
                    in_1[i+1] = b1_fixed;
                end

                acc = $signed(acc) + (($signed(in_0[i+1]) + $signed(in_1[i])) * ($signed(in_0[i]) + $signed(in_1[i+1])));
            end

            repeat(3) @(posedge clk);

            if (($signed(out[0]) + $signed(out[1])) !== $signed(acc)) begin
                $error("Error!\n");
                $fatal;
            end

            @(posedge clk);
        end
    endtask

    // -------------------------------------------------------------------------
    // Verify DUT with random numbers
    // -------------------------------------------------------------------------
    task automatic verify_with_random;
        begin
            for (int i = 0; i < 100; i++) begin
                run_and_check(1'b1, '0, '0, '0, '0);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Verify DUT with corner cases
    // -------------------------------------------------------------------------
    task automatic verify_with_corner;
        begin
            max_pos_0 = (1 <<< (IN_SIZE_0 - 1)) - 1;
            min_neg_0 =  1 <<< (IN_SIZE_0 - 1);
            max_pos_1 = (1 <<< (IN_SIZE_1 - 1)) - 1;
            min_neg_1 =  1 <<< (IN_SIZE_1 - 1);

            run_and_check(1'b0, max_pos_0, max_pos_1, max_pos_0, max_pos_1);
            run_and_check(1'b0, min_neg_0, min_neg_1, min_neg_0, min_neg_1);
            run_and_check(1'b0, max_pos_0, min_neg_1, max_pos_0, min_neg_1);
            run_and_check(1'b0, min_neg_0, max_pos_1, min_neg_0, max_pos_1);
            run_and_check(1'b0,        '0,        '0,        '0,        '0);
        end
    endtask

    // -------------------------------------------------------------------------
    // Generate the clock
    // -------------------------------------------------------------------------
    initial clk = 1'b0;

    always begin
        clk = 1'b0;
        #(clk_period/2);
        clk = 1'b1;
        #(clk_period/2);
    end

    // -------------------------------------------------------------------------
    // Verify the DUT
    // -------------------------------------------------------------------------
    initial begin
        $display("\nStarting verification...\n");

        init_vcd;
        reset_dut;
        start_vcd;

        verify_with_random;
        verify_with_corner;

        stop_vcd;

        $display("All tests PASSED!\n");
        $finish;
    end

endmodule
