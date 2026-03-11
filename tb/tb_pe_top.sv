// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off DECLFILENAME */

`timescale 1 ns/1 ps

module tb_pe_top
    import pe_pkg::*;
#(
    parameter pe_mode_e MODE = BASELINE_4_8
);
    real clk_period = `CLK_PERIOD_NS;

    logic clk, rst_n;

    logic [IN_WIDTH_A-1:0] max_pos_0, min_neg_0;
    logic [IN_WIDTH_B-1:0] max_pos_1, min_neg_1;

`ifdef POST_SYN_SIM
    logic [IN_SIZE-1:0][IN_WIDTH_A-1:0] in_0;
    logic [IN_SIZE-1:0][IN_WIDTH_B-1:0] in_1;
    logic [        1:0][ OUT_WIDTH-1:0] out;
    logic              [ OUT_WIDTH-1:0] acc;

    pe_top pe_top_i (
        .clk_i (clk),
        .rst_ni(rst_n),
        .in_0_i(in_0),
        .in_1_i(in_1),
        .out_o (out)
    );
`else
    logic [IN_WIDTH_A-1:0] in_0 [0:IN_SIZE-1];
    logic [IN_WIDTH_B-1:0] in_1 [0:IN_SIZE-1];
    logic [ OUT_WIDTH-1:0] out;
    logic [ OUT_WIDTH-1:0] acc;
    logic [ ACC_WIDTH-1:0] pe_acc;
    logic [ ACC_WIDTH-1:0] pe_alpha;
    logic [ ACC_WIDTH-1:0] pe_beta;

    pe_top #(
        .MODE(MODE)
    ) pe_top_i (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .acc_i  (pe_acc),
        .alpha_i(pe_alpha),
        .beta_i (pe_beta),
        .a_i    (in_0),
        .b_i    (in_1),
        .out_o  (out)
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
        $dumpvars(0, tb_pe_top.pe_top_i);
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
    // Mode-dependent verification
    // -------------------------------------------------------------------------
    generate

        if (MODE == WINOGRAD_4_8) begin : gen_winograd_4_8

            task automatic run_and_check(
                input bit                           use_random,
                input logic signed [IN_WIDTH_A-1:0] a0_fixed,
                input logic signed [IN_WIDTH_B-1:0] b0_fixed,
                input logic signed [IN_WIDTH_A-1:0] a1_fixed,
                input logic signed [IN_WIDTH_B-1:0] b1_fixed
            );
                begin
                    acc      = '0;
                    pe_acc   = ACC_WIDTH'($signed($urandom()));
                    pe_alpha = ACC_WIDTH'($signed($urandom()));
                    pe_beta  = ACC_WIDTH'($signed($urandom()));

                    for (int i = 0; i < IN_SIZE; i = i + 2) begin
                        if (use_random) begin
                            in_0[i]   = IN_WIDTH_A'($signed($urandom()));
                            in_1[i]   = IN_WIDTH_B'($signed($urandom()));
                            in_0[i+1] = IN_WIDTH_A'($signed($urandom()));
                            in_1[i+1] = IN_WIDTH_B'($signed($urandom()));
                        end else begin
                            in_0[i]   = a0_fixed;
                            in_1[i]   = b0_fixed;
                            in_0[i+1] = a1_fixed;
                            in_1[i+1] = b1_fixed;
                        end

                        acc = OUT_WIDTH'($signed(acc)) +
                              ((OUT_WIDTH'($signed(in_0[i+1])) + OUT_WIDTH'($signed(in_1[i]))) *
                               (OUT_WIDTH'($signed(in_0[i]))   + OUT_WIDTH'($signed(in_1[i+1]))));
                    end

                    repeat(3) @(posedge clk);

                    if (OUT_WIDTH'($signed(out)) !== (OUT_WIDTH'($signed(acc)) + OUT_WIDTH'($signed(pe_acc)) + OUT_WIDTH'($signed(pe_alpha)) + OUT_WIDTH'($signed(pe_beta)))) begin
                        $error("Error!\n");
                        $fatal;
                    end

                    @(posedge clk);
                end
            endtask

            task automatic verify_with_random;
                begin
                    for (int i = 0; i < 100; i++) begin
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

        end else if (MODE == WINOGRAD_4_4) begin : gen_winograd_4_4

            task automatic run_and_check(
                input bit                           use_random,
                input logic signed [IN_WIDTH_A-1:0] a0_fixed,
                input logic signed [IN_WIDTH_B-1:0] b0_fixed,
                input logic signed [IN_WIDTH_A-1:0] a1_fixed,
                input logic signed [IN_WIDTH_B-1:0] b1_fixed
            );
                logic signed [OUT_WIDTH-1:0] a0_ext, a1_ext;
                logic signed [OUT_WIDTH-1:0] b0_lo_ext, b1_lo_ext;
                logic signed [OUT_WIDTH-1:0] b0_hi_ext, b1_hi_ext;
                logic signed [OUT_WIDTH-1:0] p_lo, p_hi;

                logic        [3:0] b0_lo, b1_lo;
                logic signed [3:0] b0_hi, b1_hi;
                begin
                    acc      = '0;
                    pe_acc   = ACC_WIDTH'($signed($urandom()));
                    pe_alpha = ACC_WIDTH'($signed($urandom()));
                    pe_beta  = ACC_WIDTH'($signed($urandom()));

                    for (int i = 0; i < IN_SIZE; i = i + 2) begin
                        if (use_random) begin
                            in_0[i]   = IN_WIDTH_A'($signed($urandom()));
                            in_1[i]   = IN_WIDTH_B'($signed($urandom()));
                            in_0[i+1] = IN_WIDTH_A'($signed($urandom()));
                            in_1[i+1] = IN_WIDTH_B'($signed($urandom()));
                        end else begin
                            in_0[i]   = a0_fixed;
                            in_1[i]   = b0_fixed;
                            in_0[i+1] = a1_fixed;
                            in_1[i+1] = b1_fixed;
                        end

                        a0_ext = OUT_WIDTH'($signed(in_0[i]));
                        a1_ext = OUT_WIDTH'($signed(in_0[i+1]));

                        b0_lo = in_1[i][3:0];
                        b1_lo = in_1[i+1][3:0];
                        b0_hi = in_1[i][7:4];
                        b1_hi = in_1[i+1][7:4];

                        b0_lo_ext = OUT_WIDTH'($unsigned(b0_lo));
                        b1_lo_ext = OUT_WIDTH'($unsigned(b1_lo));

                        b0_hi_ext = OUT_WIDTH'($signed(b0_hi));
                        b1_hi_ext = OUT_WIDTH'($signed(b1_hi));

                        p_lo = (a1_ext + b0_lo_ext) * (a0_ext + b1_lo_ext);
                        p_hi = (a1_ext + b0_hi_ext) * (a0_ext + b1_hi_ext);

                        acc = OUT_WIDTH'($signed(acc))
                            + OUT_WIDTH'($signed(p_lo + (p_hi <<< 4)));
                    end

                    repeat (3) @(posedge clk);

                    if (OUT_WIDTH'($signed(out)) !== (OUT_WIDTH'($signed(acc)) + OUT_WIDTH'($signed(pe_acc)) + OUT_WIDTH'($signed(pe_alpha)) + OUT_WIDTH'($signed(pe_beta)))) begin
                        $error("Error!\n");
                        $fatal;
                    end

                    @(posedge clk);
                end
            endtask

            task automatic verify_with_random;
                begin
                    for (int i = 0; i < 100; i++) begin
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

        end else begin : gen_baseline

            task automatic run_and_check(
                input bit                           use_random,
                input logic signed [IN_WIDTH_A-1:0] a_fixed,
                input logic signed [IN_WIDTH_B-1:0] b_fixed
            );
                begin
                    acc    = '0;
                    pe_acc = ACC_WIDTH'($signed($urandom()));

                    for (int i = 0; i < IN_SIZE; i++) begin
                        if (use_random) begin
                            in_0[i] = IN_WIDTH_A'($signed($urandom()));
                            in_1[i] = IN_WIDTH_B'($signed($urandom()));
                        end else begin
                            in_0[i] = a_fixed;
                            in_1[i] = b_fixed;
                        end

                        acc = OUT_WIDTH'($signed(acc)) +
                              (OUT_WIDTH'($signed(in_0[i])) * OUT_WIDTH'($signed(in_1[i])));
                    end

                    repeat(3) @(posedge clk);

                    if (OUT_WIDTH'($signed(out)) !== (OUT_WIDTH'($signed(acc)) + OUT_WIDTH'($signed(pe_acc)))) begin
                        $error("Error!\n");
                        $fatal;
                    end

                    @(posedge clk);
                end
            endtask

            task automatic verify_with_random;
                begin
                    for (int i = 0; i < 100; i++) begin
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

        end

    endgenerate

endmodule
