// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off DECLFILENAME */

`timescale 1 ns/1 ps

module tb_sqr_4x8_sc_alpha_top #(
    parameter bit IS_PIPELINED = 1,
    parameter bit IS_SQUARE    = 0
);
    localparam int IN_SIZE      = 32;
    localparam int IN_WIDTH_A   = 4;
    localparam int EXT_NUM      = 15;
    localparam int PP_WIDTH     = IS_SQUARE ? (2 * IN_WIDTH_A) : IN_WIDTH_A;
    localparam int CPR_EXT_BITS = 4;
    localparam int OUT_WIDTH    = PP_WIDTH + CPR_EXT_BITS + 20;

    real clk_p = `CLK_PERIOD_NS;

    logic                  clk;
    logic                  rst_n;
    logic                  is_signed [ 0:EXT_NUM-1];
    logic                  is_shift  [ 0:EXT_NUM-1];
    logic [IN_WIDTH_A-1:0] a         [ 0:IN_SIZE-1];
    logic [ OUT_WIDTH-1:0] out;

    logic [ OUT_WIDTH-1:0] exp;
    logic [IN_WIDTH_A-1:0] max_pos;
    logic [IN_WIDTH_A-1:0] min_neg;

`ifdef POST_SYNTH
    logic [IN_SIZE*IN_WIDTH_A-1:0] a_flat;
    logic [EXT_NUM-1:0]            is_signed_flat;
    logic [EXT_NUM-1:0]            is_shift_flat;

    always_comb begin
        for (int i = 0; i < IN_SIZE; i++) begin
            a_flat[i*IN_WIDTH_A +: IN_WIDTH_A] = a[i];
        end
        for (int i = 0; i < EXT_NUM; i++) begin
            is_signed_flat[i] = is_signed[i];
            is_shift_flat[i]  = is_shift[i];
        end
    end

    sqr_4x8_sc_alpha_top sqr_4x8_sc_alpha_top_i (
        .clk_i      (clk),
        .rst_ni     (rst_n),
        .is_signed_i(is_signed_flat),
        .is_shift_i (is_shift_flat),
        .a_i        (a_flat),
        .out_o      (out)
    );
`else
    sqr_4x8_sc_alpha_top #(
        .IS_PIPELINED(IS_PIPELINED),
        .IS_SQUARE   (IS_SQUARE)
    ) sqr_4x8_sc_alpha_top_i (
        .clk_i      (clk),
        .rst_ni     (rst_n),
        .is_signed_i(is_signed),
        .is_shift_i (is_shift),
        .a_i        (a),
        .out_o      (out)
    );
`endif

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
    );
        logic signed [OUT_WIDTH-1:0] a_ext;
        logic signed [OUT_WIDTH-1:0] sqr_ext;

        begin
            exp = '0;

            for (int k = 0; k < EXT_NUM; k++) begin
                is_signed[k] = 1'b1;
                is_shift[k]  = 1'b0;
            end

            for (int i = 0; i < IN_SIZE; i++) begin
                if (use_random) begin
                    a[i] = IN_WIDTH_A'($urandom_range(0, (1 << IN_WIDTH_A) - 1));
                    // a[i] = 4'b1101;
                end else begin
                    a[i] = a_fixed;
                end

                a_ext   = OUT_WIDTH'($signed(a[i]));
                sqr_ext = OUT_WIDTH'(a_ext * a_ext);

                if (IS_SQUARE) begin
                    exp = OUT_WIDTH'($signed(exp)) + OUT_WIDTH'(sqr_ext);
                end else begin
                    exp = OUT_WIDTH'($signed(exp)) + OUT_WIDTH'(a_ext);
                end
            end

            if (IS_PIPELINED) begin
                repeat(3) @(posedge clk);
            end else begin
                repeat(2) @(posedge clk);
            end

            if (out !== exp) begin
                $error("Error!\n");
                $fatal;
            end
        end

    endtask

    task automatic verify_with_random;
        begin
            for (int i = 0; i < 1000; i++) begin
                run_and_check(1'b1, '0);
            end
        end
    endtask

    task automatic verify_with_corner;
        begin
            max_pos = (1 <<< (IN_WIDTH_A - 1)) - 1;
            min_neg =  1 <<< (IN_WIDTH_A - 1);

            run_and_check(1'b0, max_pos);
            run_and_check(1'b0, min_neg);
            run_and_check(1'b0,      '0);
        end
    endtask

    // -------------------------------------------------------------------------
    // Main control code
    // -------------------------------------------------------------------------
    initial begin
        $display("\nStarting verification...\n");

        $dumpfile("activity.vcd");
        $dumpvars(0, tb_sqr_4x8_sc_alpha_top.sqr_4x8_sc_alpha_top_i);

        reset_dut;

        verify_with_random;
        // verify_with_corner;

        $dumpoff;

        $display("All tests PASSED!\n");
        $finish;
    end

endmodule
