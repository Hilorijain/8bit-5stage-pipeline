// control_unit_tb.v
// one R-type, one I-type-ALU, LW, SW, and one branch.

`timescale 1ns/1ps

module control_unit_tb;

    reg  [3:0] opcode;
    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, imm_sel;
    wire [2:0] alu_ctrl;
    integer errors = 0;

    control_unit uut (
        .opcode(opcode),
        .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read), .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .branch(branch),
        .imm_sel(imm_sel), .alu_ctrl(alu_ctrl)
    );

    task check1;
        input actual, expected;
        input [127:0] label;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s -- expected %b, got %b", label, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %s -- got %b", label, actual);
            end
        end
    endtask

    initial begin
        // ADD: reg_write=1, alu_src=0, alu_ctrl=000, everything else 0
        opcode = 4'b0000; #1;
        check1(reg_write, 1'b1, "ADD reg_write");
        check1(alu_src,   1'b0, "ADD alu_src");
        if (alu_ctrl !== 3'b000) begin
            $display("FAIL: ADD alu_ctrl -- expected 000, got %b", alu_ctrl);
            errors = errors + 1;
        end else $display("PASS: ADD alu_ctrl -- got %b", alu_ctrl);

        // ADDI: reg_write=1, alu_src=1 (uses immediate)
        opcode = 4'b0110; #1;
        check1(reg_write, 1'b1, "ADDI reg_write");
        check1(alu_src,   1'b1, "ADDI alu_src");

        // LW: reg_write=1, alu_src=1, mem_read=1, mem_to_reg=1
        opcode = 4'b1001; #1;
        check1(reg_write,  1'b1, "LW reg_write");
        check1(mem_read,   1'b1, "LW mem_read");
        check1(mem_to_reg, 1'b1, "LW mem_to_reg");

        // SW: reg_write=0, mem_write=1, imm_sel=1 (S-type immediate position)
        opcode = 4'b1010; #1;
        check1(reg_write, 1'b0, "SW reg_write");
        check1(mem_write, 1'b1, "SW mem_write");
        check1(imm_sel,   1'b1, "SW imm_sel");

        // BEQ: reg_write=0, branch=1, imm_sel=1
        opcode = 4'b1011; #1;
        check1(reg_write, 1'b0, "BEQ reg_write");
        check1(branch,    1'b1, "BEQ branch");
        check1(imm_sel,   1'b1, "BEQ imm_sel");

        // Reserved/unused opcode: NOP
        opcode = 4'b1111; #1;
        check1(reg_write, 1'b0, "reserved opcode reg_write=0 (safe default)");
        check1(mem_write, 1'b0, "reserved opcode mem_write=0 (safe default)");

        if (errors == 0) $display(">>> ALL CONTROL_UNIT TESTS PASSED <<<");
        else $display(">>> %0d CONTROL_UNIT TEST(S) FAILED <<<", errors);

        $finish;
    end

endmodule