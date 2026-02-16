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

`ifdef POST_SYN_SIM

    logic [SIZE_ARRAY-1:0][IN_SIZE_0-1:0] in_0;
    logic [SIZE_ARRAY-1:0][IN_SIZE_1-1:0] in_1;
    logic [           1:0][ OUT_SIZE-1:0] out;
    logic                 [ OUT_SIZE-1:0] acc;

    baseline baseline_i (
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
        .IN_SIZE_1 (IN_SIZE_1),
        .SIZE_ARRAY(SIZE_ARRAY)
    ) baseline_i (
        .in_0_i(in_0),
        .in_1_i(in_1),
        .out_o (out)
    );

`endif

    int i;
    int j;
    initial begin
        $display("\nStarting random test...\n");

`ifdef VCD

        $dumpfile("activity.vcd");
        $dumpvars(0, testbench.baseline_i);

`endif

        for (j = 0; j < 100; j++) begin
            acc = '0;
            for (i = 0; i < SIZE_ARRAY; i++) begin
                in_0[i] = $signed($urandom());
                in_1[i] = $signed($urandom());

                acc = ($signed(in_0[i]) * $signed(in_1[i])) + $signed(acc);
            end

            #1;

            if ($signed(out[0]) + $signed(out[1]) !== $signed(acc)) begin
                $error("Error!\n");
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
