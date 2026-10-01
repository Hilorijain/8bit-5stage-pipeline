// forward_tb.v
// Checks that a value is correctly forwarded EX/MEM -> EX 

`timescale 1ns/1ps

module forward_tb;

    reg clk, rst;
    integer errors = 0;

    riscv_pipeline_top uut (.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/forward_test.vcd");
        $dumpvars(0, forward_tb);
    end

    initial begin
        rst = 1;
        #1;
        @(negedge clk);
        rst <= 0;

        repeat (12) @(negedge clk);

        if (uut.rf.regs[5] !== 8'd11) begin
            $display("FAIL: r5 -- expected 11, got %d", uut.rf.regs[5]);
            $display("      (if you got 3, forwarding is NOT working -- r3's stale value was used)");
            errors = errors + 1;
        end else begin
            $display("PASS: r5 = %d (forwarding correctly bypassed r3's fresh value)", uut.rf.regs[5]);
        end

        if (errors == 0) $display(">>> FORWARDING TEST PASSED <<<");
        else             $display(">>> FORWARDING TEST FAILED <<<");

        $finish;
    end

endmodule