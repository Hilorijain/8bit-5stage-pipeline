`timescale 1ns/1ps
module branch_tb;
    reg clk, rst;
    riscv_pipeline_top uut (.clk(clk), .rst(rst));

    initial begin
        $dumpfile("sim/branch_test.vcd");
        $dumpvars(0, branch_tb);
    end

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1; #1; @(negedge clk); rst <= 0;
        repeat (14) @(negedge clk);

        if (uut.rf.regs[1] !== 8'd0) $display("FAIL: r1 -- expected 0, got %d", uut.rf.regs[1]);
        else $display("PASS: r1 = %d", uut.rf.regs[1]);

        if (uut.rf.regs[2] !== 8'd1) $display("FAIL: r2 -- expected 1, got %d", uut.rf.regs[2]);
        else $display("PASS: r2 = %d", uut.rf.regs[2]);

        if (uut.rf.regs[3] !== 8'd0) $display("FAIL: r3 -- expected 0 (should have been SKIPPED), got %d", uut.rf.regs[3]);
        else $display("PASS: r3 = %d (correctly skipped)", uut.rf.regs[3]);

        if (uut.rf.regs[4] !== 8'd1) $display("FAIL: r4 -- expected 1, got %d", uut.rf.regs[4]);
        else $display("PASS: r4 = %d", uut.rf.regs[4]);

        $finish;
    end
endmodule