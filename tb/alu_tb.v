// alu_tb.v
// Checks all 6 operations and zero flag

`timescale 1ns/1ps

module alu_tb;

    reg  [7:0] a, b;
    reg  [2:0] alu_ctrl;
    wire [7:0] result;
    wire       zero;

    integer errors = 0;
    
    //instantiate
    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("sim/alu_test.vcd");
        $dumpvars(0, alu_tb);
    end

    task check_result;
        input [7:0] actual_result;
        input [7:0] expected_result;
        input actual_zero;
        input expected_zero;
        input [127:0] label;
        begin
            if (actual_result !== expected_result || actual_zero !== expected_zero) begin
                $display("FAIL: %s -- expected result=%d zero=%b, got result=%d zero=%b",
                          label, expected_result, expected_zero, actual_result, actual_zero);
                errors = errors + 1;
            end else begin
                $display("PASS: %s -- result=%d zero=%b", label, actual_result, actual_zero);
            end
        end
    endtask

    initial begin
        // ADD: 5 + 3 = 8
        a = 8'd5; b = 8'd3; alu_ctrl = 3'b000; #1;
        check_result(result, 8'd8, zero, 1'b0, "ADD 5+3");

        // SUB: 5 - 3 = 2
        a = 8'd5; b = 8'd3; alu_ctrl = 3'b001; #1;
        check_result(result, 8'd2, zero, 1'b0, "SUB 5-3");

        // SUB producing zero: 5 - 5 = 0, zero flag must be 1
        a = 8'd5; b = 8'd5; alu_ctrl = 3'b001; #1;
        check_result(result, 8'd0, zero, 1'b1, "SUB 5-5 (zero flag check)");

        // AND: 5 & 3 = 1  (0101 & 0011 = 0001)
        a = 8'd5; b = 8'd3; alu_ctrl = 3'b010; #1;
        check_result(result, 8'd1, zero, 1'b0, "AND 5&3");

        // OR: 5 | 3 = 7  (0101 | 0011 = 0111)
        a = 8'd5; b = 8'd3; alu_ctrl = 3'b011; #1;
        check_result(result, 8'd7, zero, 1'b0, "OR 5|3");

        // XOR: 5 ^ 3 = 6  (0101 ^ 0011 = 0110)
        a = 8'd5; b = 8'd3; alu_ctrl = 3'b100; #1;
        check_result(result, 8'd6, zero, 1'b0, "XOR 5^3");

        // SLT: 3 < 5 -> 1
        a = 8'd3; b = 8'd5; alu_ctrl = 3'b101; #1;
        check_result(result, 8'd1, zero, 1'b0, "SLT 3<5 (true case)");

        // SLT: 5 < 3 -> 0
        a = 8'd5; b = 8'd3; alu_ctrl = 3'b101; #1;
        check_result(result, 8'd0, zero, 1'b1, "SLT 5<3 (false case, result=0 so zero=1)");

        // summary
        if (errors == 0)
            $display(">>> ALL ALU TESTS PASSED <<<");
        else
            $display(">>> %0d ALU TEST(S) FAILED <<<", errors);

        $finish;
    end

endmodule