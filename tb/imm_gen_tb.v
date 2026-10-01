// imm_gen_tb.v
// Checks both a positive and negative immediate sign-extend correctly.

`timescale 1ns/1ps

module imm_gen_tb;

    reg  [3:0] imm_in;
    wire [7:0] imm_out;
    integer errors = 0;

    imm_gen uut (.imm_in(imm_in), .imm_out(imm_out));

    task check8;
        input [7:0] actual, expected;
        input [127:0] label;
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
        
        imm_in = 4'b0101; #1;
        check8(imm_out, 8'd5, "+ve imm 5 -> 5");

        // Negative: 4'b1111 (-1 in 4-bit two's complement) should
        // sign-extend to 8'b11111111 (-1 in 8-bit two's complement)
        imm_in = 4'b1111; #1;
        check8(imm_out, 8'b11111111, "negative imm -1 -> -1 (8-bit)");

        // Boundary: 4'b1000 is -8 in 4-bit, should become -8 in 8-bit
        imm_in = 4'b1000; #1;
        check8(imm_out, 8'b11111000, "boundary imm -8 -> -8 (8-bit)");

        if (errors == 0) $display(">>> ALL IMM_GEN TESTS PASSED <<<");
        else $display(">>> %0d IMM_GEN TEST(S) FAILED <<<", errors);

        $finish;
    end

endmodule