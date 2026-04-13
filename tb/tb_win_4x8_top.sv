// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off DECLFILENAME */

`timescale 1 ns/1 ps

module tb_win_4x8_top #(
    parameter int MULT_TYPE = 0
);
    localparam int IN_SIZE    = 64;
    localparam int IN_WIDTH_A = 4;
    localparam int IN_WIDTH_B = 8;
    localparam int ACC_SIZE   = 3;
    localparam int ACC_WIDTH  = 48;
    localparam int EXT_NUM    = 15;
    localparam int OUT_WIDTH  = ACC_WIDTH;

    real clk_p = `CLK_PERIOD_NS;

    logic                  clk;
    logic                  rst_n;
    logic [ ACC_WIDTH-1:0] acc       [0:ACC_SIZE-1];
    logic                  is_signed [ 0:EXT_NUM-1];
    logic                  is_shift  [ 0:EXT_NUM-1];
    logic [IN_WIDTH_A-1:0] a         [ 0:IN_SIZE-1];
    logic [IN_WIDTH_B-1:0] b         [ 0:IN_SIZE-1];
    logic [ OUT_WIDTH-1:0] out;

    logic [ ACC_WIDTH-1:0] exp;
    logic [IN_WIDTH_A-1:0] max_pos_0;
    logic [IN_WIDTH_A-1:0] min_neg_0;
    logic [IN_WIDTH_B-1:0] max_pos_1;
    logic [IN_WIDTH_B-1:0] min_neg_1;

    win_4x8_top #(
        .MULT_TYPE(MULT_TYPE)
    ) win_4x8_top_i (
        .clk_i      (clk),
        .rst_ni     (rst_n),
        .acc_i      (acc),
        .is_signed_i(is_signed),
        .is_shift_i (is_shift),
        .a_i        (a),
        .b_i        (b),
        .out_o      (out)
    );

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
    // Generate the clock
    // -------------------------------------------------------------------------
    initial clk = 1'b0;

    always begin
        clk = 1'b0;
        #(clk_p/2);
        clk = 1'b1;
        #(clk_p/2);
    end

    // -------------------------------------------------------------------------
    // Verification tasks
    // -------------------------------------------------------------------------
    task automatic run_and_check(
        input bit                           use_random,
        input logic signed [IN_WIDTH_A-1:0] a0_fixed,
        input logic signed [IN_WIDTH_B-1:0] b0_fixed,
        input logic signed [IN_WIDTH_A-1:0] a1_fixed,
        input logic signed [IN_WIDTH_B-1:0] b1_fixed
    );
        logic signed [OUT_WIDTH-1:0] s0, s1, prod;
        begin
            exp    = '0;
            acc[0] = ACC_WIDTH'($urandom_range(0, (1 << ACC_WIDTH) - 1));
            acc[1] = ACC_WIDTH'($urandom_range(0, (1 << ACC_WIDTH) - 1));
            acc[2] = ACC_WIDTH'($urandom_range(0, (1 << ACC_WIDTH) - 1));

            for (int k = 0; k < EXT_NUM; k ++) begin
                is_signed[k] = 1'b1;
                is_shift[k]  = 1'b0;
            end

            for (int i = 0; i < IN_SIZE; i = i + 2) begin
                if (use_random) begin
                    a[i]   = IN_WIDTH_A'($urandom_range(0, (1 << IN_WIDTH_A) - 1));
                    b[i]   = IN_WIDTH_B'($urandom_range(0, (1 << IN_WIDTH_B) - 1));
                    a[i+1] = IN_WIDTH_A'($urandom_range(0, (1 << IN_WIDTH_A) - 1));
                    b[i+1] = IN_WIDTH_B'($urandom_range(0, (1 << IN_WIDTH_B) - 1));
                end else begin
                    a[i]   = a0_fixed;
                    b[i]   = b0_fixed;
                    a[i+1] = a1_fixed;
                    b[i+1] = b1_fixed;
                end

                s0   = OUT_WIDTH'($signed(a[i+1])) + OUT_WIDTH'($signed(b[i]));
                s1   = OUT_WIDTH'($signed(a[i]))   + OUT_WIDTH'($signed(b[i+1]));
                prod = s0 * s1;
                exp  = exp + prod;
            end

            repeat(3) @(posedge clk);

            if (out !== OUT_WIDTH'($signed(exp) + $signed(acc[0]) + $signed(acc[1]) + $signed(acc[2]))) begin
                $error("Error!\n");
                $fatal;
            end
        end
    endtask

    task automatic verify_with_random;
        begin
            for (int i = 0; i < 1000; i++) begin
                run_and_check(1'b1, '0, '0, '0, '0);
            end
        end
    endtask

    task automatic verify_with_corner;
        begin
            max_pos_0 = (1 <<< (IN_WIDTH_A - 1)) - 1;
            min_neg_0 =  1 <<< (IN_WIDTH_A - 1);
            max_pos_1 = (1 <<< (IN_WIDTH_B - 1)) - 1;
            min_neg_1 =  1 <<< (IN_WIDTH_B - 1);

            run_and_check(1'b0, max_pos_0, max_pos_1, max_pos_0, max_pos_1);
            run_and_check(1'b0, min_neg_0, min_neg_1, min_neg_0, min_neg_1);
            run_and_check(1'b0, max_pos_0, min_neg_1, max_pos_0, min_neg_1);
            run_and_check(1'b0, min_neg_0, max_pos_1, min_neg_0, max_pos_1);
            run_and_check(1'b0,        '0,        '0,        '0,        '0);
        end
    endtask

    // -------------------------------------------------------------------------
    // Main control code
    // -------------------------------------------------------------------------
    initial begin
        $display("\nStarting verification...\n");

        $dumpfile("activity.vcd");
        $dumpvars(0, tb_win_4x8_top.win_4x8_top_i);

        reset_dut;

        verify_with_random;
        verify_with_corner;

        $dumpoff;

        $display("All tests PASSED!\n");
        $finish;
    end

endmodule
