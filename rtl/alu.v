// alu.v
// 8-bit ALU, 6 operations selected by 3-bit alu_ctrl signal

`timescale 1ns/1ps

module alu (
    input  [7:0] a,
    input  [7:0] b,
    input  [2:0] alu_ctrl,
    output reg [7:0] result,
    output       zero
);

    always @(*) begin
        case (alu_ctrl)
            3'b000: result = a + b;                          // ADD
            3'b001: result = a - b;                          // SUB
            3'b010: result = a & b;                          // AND
            3'b011: result = a | b;                          // OR
            3'b100: result = a ^ b;                          // XOR
            3'b101: result = ($signed(a) < $signed(b)) ? 8'd1 : 8'd0; // SLT
            default: result = 8'd0;                          // gtkwave sim/alu.vcdunused opcodes -> 0
        endcase
    end

    assign zero = (result == 8'd0);

endmodule