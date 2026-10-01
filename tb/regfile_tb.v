// regfile_tb.v
// Checks: normal write+read, dual-port simultaneous read, reg0 hardwired to zero

`timescale 1ns/1ps

module regfile_tb;

    reg        clk;
    reg        we;
    reg  [3:0] rs1_addr, rs2_addr, rd_addr;
    reg  [7:0] wd;
    wire [7:0] rd1, rd2;

    integer errors = 0;

    // instantiate the DUT
    regfile uut (
        .clk(clk),
        .we(we),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // clock: toggles every 5ns -> 10ns period
    // always begin
    //     clk = 0; #5;
    //     clk = 1; #5;
    // end
    initial clk = 0;

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/regfile_test.vcd");
        $dumpvars(0, regfile_tb);
    end

    // self-check helper task
    task check8;
        input [7:0] actual;
        input [7:0] expected;
        input [127:0] label;   // for the message
        begin
            if (actual !== expected) begin
                $display("FAIL: %s -- expected %d, got %d", label, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %s -- got %d", label, actual);
            end
        end
    endtask

    initial begin
        // defaults
        we = 0; rs1_addr = 0; rs2_addr = 0; rd_addr = 0; wd = 0;
        #1
        @(negedge clk);


        // Test 1: write 8'd5 into register 3
        we = 1; rd_addr = 4'd3; wd = 8'd5;
        @(posedge clk);   // write happens on this edge
        we <= 0;
        @(negedge clk);   // move past the edge, settle combinational reads
        rs1_addr = 4'd3;
        #1;
        check8(rd1, 8'd5, "reg3 read back after write");

        // Test 2: write 8'd9 into register 7, then read reg3 and reg7 simultaneously
        we = 1; rd_addr = 4'd7; wd = 8'd9;
        @(posedge clk);
        we <= 0;
        @(negedge clk);
        rs1_addr = 4'd3; rs2_addr = 4'd7;
        #1;
        check8(rd1, 8'd5, "dual-port read: rs1=reg3");
        check8(rd2, 8'd9, "dual-port read: rs2=reg7");

        // Test 3: attempt to write register 0 -- must NOT change (hardwired zero)
        we = 1; rd_addr = 4'd0; wd = 8'd99;
        @(posedge clk);
        we <= 0;
        @(negedge clk);
        rs1_addr = 4'd0;
        #1;
        check8(rd1, 8'd0, "reg0 stays zero even after attempted write");

        // Test 4: read an untouched register (reg1), should read 0 (default sim value)
        rs1_addr = 4'd1;
        #1;
        check8(rd1, 8'd0, "untouched reg1 reads as 0");

        // summary
        if (errors == 0)
            $display(">>> ALL REGFILE TESTS PASSED <<<");
        else
            $display(">>> %0d REGFILE TEST(S) FAILED <<<", errors);

        $finish;
    end

endmodule