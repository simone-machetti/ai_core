// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

`timescale 1 ns/1 ps

module testbench #(
    parameter int IN_SIZE_0  = 4,
    parameter int IN_SIZE_1  = 8,
    parameter int SIZE_ARRAY = 8
);

    localparam int OUT_SIZE = IN_SIZE_0 + IN_SIZE_1 + 8;
    localparam time T       = 1.3ns;

    logic clk, rst_n;



`ifdef POST_SYN_SIM

    logic [SIZE_ARRAY-1:0][IN_SIZE_0-1:0] in_0;
    logic [SIZE_ARRAY-1:0][IN_SIZE_1-1:0] in_1;
    logic [           1:0][ OUT_SIZE-1:0] out;
    logic                 [ OUT_SIZE-1:0] acc;

    baseline baseline_i (
        .clk_i (clk),
        .rst_ni(rst_n),
        .in_0_i(in_0),
        .in_1_i(in_1),
        .out_o (out)
    );

`else

    logic [              IN_SIZE_0-1:0] in_0 [0:SIZE_ARRAY-1];
    logic [              IN_SIZE_1-1:0] in_1 [0:SIZE_ARRAY-1];
    logic [(IN_SIZE_0+IN_SIZE_1)+8-1:0] out  [           0:1];
    logic [(IN_SIZE_0+IN_SIZE_1)+8-1:0] acc;

    baseline #(
        .IN_SIZE_0 (IN_SIZE_0),
        .IN_SIZE_1 (IN_SIZE_1)
    ) baseline_i (
        .clk_i (clk),
        .rst_ni(rst_n),
        .in_0_i(in_0),
        .in_1_i(in_1),
        .out_o (out)
    );

`endif

    initial clk = 1'b0;

    always begin
        #(0.65ns);
        clk = ~clk;
    end

    int i;
    int j;
    initial begin
        $display("\nStarting random test...\n");

`ifdef VCD

        $dumpfile("activity.vcd");
        $dumpvars(0, testbench.baseline_i);

`endif

        rst_n = 1'b0;
        repeat(10) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        for (j = 0; j < 100; j++) begin
            acc = '0;
            for (i = 0; i < SIZE_ARRAY; i++) begin
                in_0[i] = $signed($urandom());
                in_1[i] = $signed($urandom());

                acc = ($signed(in_0[i]) * $signed(in_1[i])) + $signed(acc);
            end

            repeat(3) @(posedge clk);

            if ($signed(out[0]) + $signed(out[1]) !== $signed(acc)) begin
                $error("Error!\n");
                $fatal;
            end

            @(posedge clk);
        end

`ifdef VCD

        $dumpoff;

`endif
        $display("All tests PASSED!\n");
        $finish;
    end

endmodule
