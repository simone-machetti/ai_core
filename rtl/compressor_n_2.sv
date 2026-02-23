// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNOPTFLAT */

module compressor_n_2 #(
    parameter int IN_NUM  = 24,
    parameter int IN_SIZE = 12
)(
    input  logic [                       IN_SIZE-1:0] in_i [0:IN_NUM-1],
    output logic [IN_SIZE+(($clog2(IN_NUM)-1)*2)-1:0] sum_o,
    output logic [IN_SIZE+(($clog2(IN_NUM)-1)*2)-1:0] carry_o
);

    function automatic int cnt_num_lanes_at_next_stage(input int num);
        cnt_num_lanes_at_next_stage = 2 * (num / 4) + (num % 4);
    endfunction

    function automatic int cnt_num_in_lanes_at_stage(input int stage);
        int n, k;
        begin
            n = IN_NUM;
            for (k = 0; k < stage; k++) begin
                n = cnt_num_lanes_at_next_stage(n);
            end
            cnt_num_in_lanes_at_stage = n;
        end
    endfunction

    function automatic int cnt_stage_num(input int num);
        int n, l;
        begin
            n = num;
            l = 0;
            while (n > 4) begin
                n = cnt_num_lanes_at_next_stage(n);
                l++;
            end
            if (n > 2) l++;
            cnt_stage_num = l;
        end
    endfunction

    localparam int STAGE_NUM = cnt_stage_num(IN_NUM);
    localparam int OUT_SIZE  = IN_SIZE + (STAGE_NUM * 2);

    logic [OUT_SIZE-1:0] tmp [0:STAGE_NUM-1][0:IN_NUM-1];

    genvar i, j, r;
    generate
        for (i = 0; i < STAGE_NUM; i++) begin : gen_rows
            localparam bit IS_LAST = (i == (STAGE_NUM-1));
            localparam int N_IN    = cnt_num_in_lanes_at_stage(i);
            localparam int NUM_4_2 = IS_LAST ? 1 : (N_IN / 4);
            localparam int REM     = IS_LAST ? 0 : (N_IN % 4);
            localparam int W_IN    = IN_SIZE + (i * 2);
            localparam int W_OUT   = W_IN + 2;

            for (j = 0; j < NUM_4_2; j++) begin : gen_cols
                localparam int base_in  = j * 4;
                localparam int base_out = j * 2;

                logic [ W_IN-1:0] in [0:3];
                logic [W_OUT-1:0] sum;
                logic [W_OUT-1:0] carry;

                if (i == 0) begin
                    if (IS_LAST) begin
                        assign in[0] = (N_IN > 0) ? {{(W_IN-IN_SIZE){in_i[0][IN_SIZE-1]}}, in_i[0]} : '0;
                        assign in[1] = (N_IN > 1) ? {{(W_IN-IN_SIZE){in_i[1][IN_SIZE-1]}}, in_i[1]} : '0;
                        assign in[2] = (N_IN > 2) ? {{(W_IN-IN_SIZE){in_i[2][IN_SIZE-1]}}, in_i[2]} : '0;
                        assign in[3] = (N_IN > 3) ? {{(W_IN-IN_SIZE){in_i[3][IN_SIZE-1]}}, in_i[3]} : '0;
                    end else begin
                        assign in[0] = {{(W_IN-IN_SIZE){in_i[base_in+0][IN_SIZE-1]}}, in_i[base_in+0]};
                        assign in[1] = {{(W_IN-IN_SIZE){in_i[base_in+1][IN_SIZE-1]}}, in_i[base_in+1]};
                        assign in[2] = {{(W_IN-IN_SIZE){in_i[base_in+2][IN_SIZE-1]}}, in_i[base_in+2]};
                        assign in[3] = {{(W_IN-IN_SIZE){in_i[base_in+3][IN_SIZE-1]}}, in_i[base_in+3]};
                    end
                end else begin
                    if (IS_LAST) begin
                        assign in[0] = (N_IN > 0) ? tmp[i-1][0][W_IN-1:0] : '0;
                        assign in[1] = (N_IN > 1) ? tmp[i-1][1][W_IN-1:0] : '0;
                        assign in[2] = (N_IN > 2) ? tmp[i-1][2][W_IN-1:0] : '0;
                        assign in[3] = (N_IN > 3) ? tmp[i-1][3][W_IN-1:0] : '0;
                    end else begin
                        assign in[0] = tmp[i-1][base_in+0][W_IN-1:0];
                        assign in[1] = tmp[i-1][base_in+1][W_IN-1:0];
                        assign in[2] = tmp[i-1][base_in+2][W_IN-1:0];
                        assign in[3] = tmp[i-1][base_in+3][W_IN-1:0];
                    end
                end

                compressor_4_2 #(
                    .IN_SIZE (W_IN),
                    .OUT_SIZE(W_OUT)
                ) compressor_4_2_stage_i_j_i (
                    .in_i   (in),
                    .sum_o  (sum),
                    .carry_o(carry)
                );

                assign tmp[i][base_out+0] = {{(OUT_SIZE-W_OUT){sum[W_OUT-1]}},   sum};
                assign tmp[i][base_out+1] = {{(OUT_SIZE-W_OUT){carry[W_OUT-1]}}, carry};
            end

            for (r = 0; r < REM; r++) begin : gen_pass
                localparam int src = (NUM_4_2 * 4) + r;
                localparam int dst = (NUM_4_2 * 2) + r;

                logic [W_OUT-1:0] pass;

                if (i == 0) begin
                    assign pass = {{(W_OUT-IN_SIZE){in_i[src][IN_SIZE-1]}}, in_i[src]};
                end else begin
                    assign pass = {{(W_OUT-W_IN){tmp[i-1][src][W_IN-1]}}, tmp[i-1][src][W_IN-1:0]};
                end

                assign tmp[i][dst] = {{(OUT_SIZE-W_OUT){pass[W_OUT-1]}}, pass};
            end
        end
    endgenerate

    assign sum_o   = tmp[STAGE_NUM-1][0];
    assign carry_o = tmp[STAGE_NUM-1][1];

endmodule
