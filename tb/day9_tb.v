`timescale 1ns/1ps
module day9_tb;
    reg clk, rst;
    integer errors = 0;

    riscv_pipeline_top uut (.clk(clk), .rst(rst));

    initial begin
        $dumpfile("sim/day9_test.vcd");
        $dumpvars(0, day9_tb);
    end

    initial clk = 0;
    always #5 clk = ~clk;

    task check_reg;
        input [3:0] idx;
        input [7:0] expected;
        begin
            if (uut.rf.regs[idx] !== expected) begin
                $display("FAIL: r%0d -- expected %d, got %d", idx, expected, uut.rf.regs[idx]);
                errors = errors + 1;
            end else $display("PASS: r%0d = %d", idx, uut.rf.regs[idx]);
        end
    endtask

    initial begin
        rst = 1; #1; @(negedge clk); rst <= 0;
        repeat (50) @(negedge clk);

        check_reg(4'd0,  8'd0);
        check_reg(4'd1,  8'd2);    // last write wins
        check_reg(4'd2,  8'd4);    // MEM beats WB
        check_reg(4'd3,  8'd4);
        check_reg(4'd7,  8'd0);    // squashed after load-then-branch
        check_reg(4'd8,  8'd5);    // branch target executed
        check_reg(4'd10, 8'd0);    // loop counter reached 0
        check_reg(4'd11, 8'd6);    // 3+2+1
        check_reg(4'd12, 8'd1);    // exactly once, not per iteration
        check_reg(4'd13, 8'd1);

        if (uut.dm.mem[0] !== 8'd4) begin
            $display("FAIL: mem[0] -- expected 4, got %d", uut.dm.mem[0]);
            errors = errors + 1;
        end else $display("PASS: mem[0] = %d", uut.dm.mem[0]);

        if (errors == 0) $display(">>> DAY 9 EDGE-CASE + LOOP TEST PASSED <<<");
        else             $display(">>> %0d CHECK(S) FAILED <<<", errors);
        $finish;
    end
endmodule