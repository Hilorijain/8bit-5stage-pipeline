// pipeline_tb.v
// Runs pipeline_test1.hex through the pipelined datapath.
// Same check pattern as singlecycle_tb.v -- same expected final state,
// since the NOPs only add timing slack, not different computation.

`timescale 1ns/1ps

module pipeline_tb;

    reg clk, rst;
    integer errors = 0;

    riscv_pipeline_top uut (.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/pipeline_test1.vcd");
        $dumpvars(0, pipeline_tb);
    end

    task check_reg;
        input [3:0] idx;
        input [7:0] expected;
        begin
            if (uut.rf.regs[idx] !== expected) begin
                $display("FAIL: r%0d -- expected %d, got %d",
                          idx, expected, uut.rf.regs[idx]);
                errors = errors + 1;
            end else begin
                $display("PASS: r%0d = %d", idx, uut.rf.regs[idx]);
            end
        end
    endtask

    initial begin
        rst = 1;
        #1;
        @(negedge clk);
        rst <= 0;

        // 15 instructions + pipeline fill/drain slack
        repeat (25) @(negedge clk);

        check_reg(4'd1, 8'd5);
        check_reg(4'd2, 8'd3);
        check_reg(4'd3, 8'd8);
        check_reg(4'd4, 8'd2);
        check_reg(4'd5, 8'd1);
        check_reg(4'd6, 8'd8);

        if (uut.dm.mem[0] !== 8'd8) begin
            $display("FAIL: mem[0] -- expected 8, got %d", uut.dm.mem[0]);
            errors = errors + 1;
        end else $display("PASS: mem[0] = %d", uut.dm.mem[0]);

        if (errors == 0) $display(">>> PIPELINE (NO-HAZARD) TEST PASSED <<<");
        else             $display(">>> %0d CHECK(S) FAILED <<<", errors);

        $finish;
    end

endmodule