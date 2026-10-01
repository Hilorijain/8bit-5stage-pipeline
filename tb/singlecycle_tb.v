// singlecycle_tb.v
// Runs test1.hex, checks final architectural state against hand-computed values.

`timescale 1ns/1ps

module singlecycle_tb;

    reg clk, rst;
    integer errors = 0;

    riscv_singlecycle uut (.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/singlecycle.vcd");
        $dumpvars(0, singlecycle_tb);
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

        // 7 instructions, one per cycle type tb\singlecycle_tb.vin a single-cycle design;
        // extra cycles as slack for the write to fully settle.
        repeat (12) @(negedge clk);

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

        if (errors == 0) $display(">>> SINGLE-CYCLE DATAPATH PASSED <<<");
        else             $display(">>> %0d CHECK(S) FAILED <<<", errors);

        $finish;
    end

endmodule