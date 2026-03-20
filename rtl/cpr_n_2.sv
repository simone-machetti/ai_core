// -----------------------------------------------------------------------------
// Author: Simone Machetti
// -----------------------------------------------------------------------------

/* verilator lint_off GENUNNAMED */
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNOPTFLAT */

`timescale 1 ns/1 ps

module cpr_n_2 #(
    parameter int IN_SIZE  = 8,
    parameter int IN_WIDTH = 8,

    localparam int OUT_WIDTH = IN_WIDTH + $clog2(IN_SIZE) + 1
)(
    input  logic [ IN_WIDTH-1:0] in_i [0:IN_SIZE-1],
    output logic [OUT_WIDTH-1:0] sum_o,
    output logic [OUT_WIDTH-1:0] carry_o
);

    function automatic int cnt_in_stage_size(input int stage);
        int in_size, cpr_num, rem, i;
        begin
            if (stage == 0) begin
                cnt_in_stage_size = IN_SIZE;
            end else begin
                in_size = IN_SIZE;
                cpr_num = (in_size + 3) / 4;
                rem     = 0;
                for (i = 1; i <= stage; i++) begin
                    in_size = (cpr_num * 2) + rem;
                    cpr_num = in_size / 4;
                    rem     = in_size % 4;
                end
                cnt_in_stage_size = in_size;
            end
        end
    endfunction

    genvar stage, cpr;
    generate

        if (IN_SIZE < 4) begin

            assign sum_o   = '0;
            assign carry_o = '0;

            initial $fatal(1, "compressor_n_2: IN_SIZE must be >= 4, got %0d", IN_SIZE);

        end else begin

            localparam int STAGE_NUM = $clog2(IN_SIZE) - 1;

            logic [OUT_WIDTH-1:0] tmp [0:STAGE_NUM-1][0:IN_SIZE-1];

            for (stage = 0; stage < STAGE_NUM; stage++) begin : gen_stages

                localparam int IN_STAGE_NUM   = cnt_in_stage_size(stage);
                localparam int CPR_NUM        = stage == 0 ? (IN_STAGE_NUM + 3) / 4 : IN_STAGE_NUM / 4;
                localparam int REM            = stage == 0 ? (CPR_NUM * 4) - IN_STAGE_NUM : IN_STAGE_NUM % 4;
                localparam int WIDTH_IN       = stage == 0 ? IN_WIDTH : IN_WIDTH + stage + 2;
                localparam bit IS_FIRST_STAGE = stage == 0 ? 1 : 0;
                localparam int EXT_BITS       = stage == 0 ? 3 : 1;
                localparam int WIDTH_OUT      = WIDTH_IN + EXT_BITS;

                for (cpr = 0; cpr < CPR_NUM; cpr++) begin : gen_cprs

                    localparam int BASE_IN     = cpr * 4;
                    localparam int BASE_OUT    = cpr * 2;
                    localparam bit IS_LAST_CPR = cpr == CPR_NUM - 1 ? 1 : 0;

                    logic [ WIDTH_IN-1:0] in [0:3];
                    logic [WIDTH_OUT-1:0] sum;
                    logic [WIDTH_OUT-1:0] carry;

                    if (IS_FIRST_STAGE) begin
                        if (IS_LAST_CPR) begin
                            assign in[0] = (REM > 3) ? '0 : in_i[BASE_IN+0];
                            assign in[1] = (REM > 2) ? '0 : in_i[BASE_IN+1];
                            assign in[2] = (REM > 1) ? '0 : in_i[BASE_IN+2];
                            assign in[3] = (REM > 0) ? '0 : in_i[BASE_IN+3];
                        end else begin
                            assign in[0] = in_i[BASE_IN+0];
                            assign in[1] = in_i[BASE_IN+1];
                            assign in[2] = in_i[BASE_IN+2];
                            assign in[3] = in_i[BASE_IN+3];
                        end
                    end else begin
                        assign in[0] = tmp[stage-1][BASE_IN+0][WIDTH_IN-1:0];
                        assign in[1] = tmp[stage-1][BASE_IN+1][WIDTH_IN-1:0];
                        assign in[2] = tmp[stage-1][BASE_IN+2][WIDTH_IN-1:0];
                        assign in[3] = tmp[stage-1][BASE_IN+3][WIDTH_IN-1:0];
                    end

                    cpr_4_2 #(
                        .IN_WIDTH(WIDTH_IN),
                        .EXT_BITS(EXT_BITS)
                    ) cpr_4_2_i (
                        .in_i   (in),
                        .sum_o  (sum),
                        .carry_o(carry)
                    );

                    assign tmp[stage][BASE_OUT+0][WIDTH_OUT-1:0] = sum;
                    assign tmp[stage][BASE_OUT+1][WIDTH_OUT-1:0] = carry;
                end


                localparam int BASE_IN  = (CPR_NUM - 1) * 4;
                localparam int BASE_OUT = (CPR_NUM - 1) * 2;

                if (!IS_FIRST_STAGE && (REM > 0)) begin
                    assign tmp[stage][BASE_OUT+2][WIDTH_OUT-1:0] = {{(WIDTH_OUT-WIDTH_IN){tmp[stage-1][BASE_IN+4][WIDTH_IN-1]}}, tmp[stage-1][BASE_IN+4][WIDTH_IN-1:0]};
                    assign tmp[stage][BASE_OUT+3][WIDTH_OUT-1:0] = {{(WIDTH_OUT-WIDTH_IN){tmp[stage-1][BASE_IN+5][WIDTH_IN-1]}}, tmp[stage-1][BASE_IN+5][WIDTH_IN-1:0]};
                end
            end

            assign sum_o   = tmp[STAGE_NUM-1][0];
            assign carry_o = tmp[STAGE_NUM-1][1];

        end

    endgenerate

endmodule
