// loaduse_tb.v
`timescale 1ns/1ps


module loaduse_tb;

    reg clk, rst;
    riscv_pipeline_top uut (.clk(clk), .rst(rst));

    
initial begin
    $dumpfile("sim/loaduse_test.vcd");
    $dumpvars(0, loaduse_tb);
end

    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        rst = 1; #1; @(negedge clk); rst <= 0;
        repeat (12) @(negedge clk);
        if (uut.rf.regs[2] !== 8'd3) $display("FAIL: r2 -- expected 3, got %d", uut.rf.regs[2]);
        else $display("PASS: r2 = %d", uut.rf.regs[2]);
        if (uut.rf.regs[3] !== 8'd6) $display("FAIL: r3 -- expected 6, got %d", uut.rf.regs[3]);
        else $display("PASS: r3 = %d", uut.rf.regs[3]);
        $finish;
    end
endmodule