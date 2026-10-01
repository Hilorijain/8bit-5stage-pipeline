// bypass_tb.v
// Confirms the regfile's same-cycle write-then-read bypass closes the
// gap forwarding can't reach: a write and read to the same register
// landing on the identical clock edge, 3 instructions apart.

`timescale 1ns/1ps

module bypass_tb;

    reg clk, rst;
    integer errors = 0;

    riscv_pipeline_top uut (.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/bypass_test.vcd");
        $dumpvars(0, bypass_tb);
    end

    initial begin
        rst = 1;
        #1;
        @(negedge clk);
        rst <= 0;

        repeat (12) @(negedge clk);

        if (uut.rf.regs[5] !== 8'd3) begin
            $display("FAIL: r5 -- expected 3, got %d", uut.rf.regs[5]);
            $display("      (got 8 means r1 was read as 0 -- bypass NOT working)");
            errors = errors + 1;
        end else begin
            $display("PASS: r5 = %d (same-cycle write-then-read bypass working)", uut.rf.regs[5]);
        end

        if (errors == 0) $display(">>> BYPASS TEST PASSED <<<");
        else             $display(">>> BYPASS TEST FAILED <<<");

        $finish;
    end

endmodule