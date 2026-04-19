// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off DECLFILENAME */

`timescale 1 ns/1 ps

module tb_pe_top
    import pp_gen_pkg::*;
    import pe_top_pkg::*;
 #(
    parameter int ARCH       = 0,
    parameter int IN_SIZE    = 64,
    parameter int IN_WIDTH_A = 4,
    parameter int IN_WIDTH_B = 8,
    parameter int MULT_TYPE  = 0,
    parameter int ACC_SIZE   = 1,
    parameter int ACC_WIDTH  = 40
);

    localparam int OUT_WIDTH = pe_top_pkg::get_out_width(ARCH, MULT_TYPE, IN_WIDTH_A, IN_WIDTH_B, IN_SIZE, ACC_SIZE, ACC_WIDTH);

    real clk_p = `CLK_PERIOD_NS;

    logic                  clk;
    logic                  rst_n;
    logic [IN_WIDTH_A-1:0] a   [ 0:IN_SIZE-1];
    logic [IN_WIDTH_B-1:0] b   [ 0:IN_SIZE-1];
    logic [ ACC_WIDTH-1:0] acc [0:ACC_SIZE-1];
    logic [ OUT_WIDTH-1:0] out;

    logic [ OUT_WIDTH-1:0] exp;
    logic [IN_WIDTH_A-1:0] max_pos_0;
    logic [IN_WIDTH_A-1:0] min_neg_0;
    logic [IN_WIDTH_B-1:0] max_pos_1;
    logic [IN_WIDTH_B-1:0] min_neg_1;

    pe_top #(
        .ARCH      (ARCH),
        .IN_SIZE   (IN_SIZE),
        .IN_WIDTH_A(IN_WIDTH_A),
        .IN_WIDTH_B(IN_WIDTH_B),
        .MULT_TYPE (MULT_TYPE),
        .ACC_SIZE  (ACC_SIZE),
        .ACC_WIDTH (ACC_WIDTH)
    ) pe_top_i (
        .clk_i (clk),
        .rst_ni(rst_n),
        .a_i   (a),
        .b_i   (b),
        .acc_i (acc),
        .out_o (out)
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
        input logic signed [IN_WIDTH_A-1:0] a_fixed,
        input logic signed [IN_WIDTH_B-1:0] b_fixed
    );
        begin
            exp = '0;
            if (ACC_SIZE > 0)
                acc[0] = ACC_WIDTH'($urandom_range(0, (1 << ACC_WIDTH) - 1));

            for (int i = 0; i < IN_SIZE; i++) begin
                if (use_random) begin
                    a[i] = IN_WIDTH_A'($urandom_range(0, (1 << IN_WIDTH_A) - 1));
                    b[i] = IN_WIDTH_B'($urandom_range(0, (1 << IN_WIDTH_B) - 1));
                end else begin
                    a[i] = a_fixed;
                    b[i] = b_fixed;
                end

                exp = OUT_WIDTH'($signed(exp) + OUT_WIDTH'($signed(a[i]) * $signed(b[i])));
            end

            repeat(2) @(posedge clk);

            if (out !== OUT_WIDTH'($signed(exp) + (ACC_SIZE > 0 ? $signed(acc[0]) : 0))) begin
                $dumpoff;
                $error("Error!\n");
                $fatal;
            end
        end
    endtask

    task automatic verify_with_random;
        begin
            for (int i = 0; i < 1000; i++) begin
                run_and_check(1'b1, '0, '0);
            end
        end
    endtask

    task automatic verify_with_corner;
        begin
            max_pos_0 = (1 <<< (IN_WIDTH_A - 1)) - 1;
            min_neg_0 =  1 <<< (IN_WIDTH_A - 1);
            max_pos_1 = (1 <<< (IN_WIDTH_B - 1)) - 1;
            min_neg_1 =  1 <<< (IN_WIDTH_B - 1);

            run_and_check(1'b0, max_pos_0, max_pos_1);
            run_and_check(1'b0, min_neg_0, min_neg_1);
            run_and_check(1'b0, max_pos_0, min_neg_1);
            run_and_check(1'b0, min_neg_0, max_pos_1);
            run_and_check(1'b0,        '0,        '0);
        end
    endtask

    // -------------------------------------------------------------------------
    // Main control code
    // -------------------------------------------------------------------------
    initial begin
        $display("\nStarting verification...\n");

        $dumpfile("activity.vcd");
        $dumpvars(0, tb_pe_top.pe_top_i);

        reset_dut;

        verify_with_random;
        verify_with_corner;

        $dumpoff;

        $display("All tests PASSED!\n");
        $finish;
    end

endmodule
