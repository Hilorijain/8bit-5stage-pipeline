`timescale 1ns/1ps
module integration_tb;
    reg clk, rst;
    integer errors = 0;

    riscv_pipeline_top uut (.clk(clk), .rst(rst));

    initial begin
        $dumpfile("sim/integration_test.vcd");
        $dumpvars(0, integration_tb);
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
        repeat (30) @(negedge clk);

        check_reg(4'd0,  8'd0);   // r0 must stay 0
        check_reg(4'd1,  8'd5);
        check_reg(4'd2,  8'd3);
        check_reg(4'd3,  8'd8);
        check_reg(4'd4,  8'd8);
        check_reg(4'd5,  8'd16);
        check_reg(4'd6,  8'd6);
        check_reg(4'd7,  8'd0);   // squashed by taken branch
        check_reg(4'd9,  8'd5);   // not squashed after not-taken branch
        check_reg(4'd10, 8'd7);

        if (uut.dm.mem[0] !== 8'd8) begin
            $display("FAIL: mem[0] -- expected 8, got %d", uut.dm.mem[0]);
            errors = errors + 1;
        end else $display("PASS: mem[0] = %d", uut.dm.mem[0]);

        if (errors == 0) $display(">>> INTEGRATION TEST PASSED <<<");
        else             $display(">>> %0d CHECK(S) FAILED <<<", errors);
        $finish;
    end
endmodule