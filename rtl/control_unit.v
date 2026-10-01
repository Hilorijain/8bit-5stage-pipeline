// control_unit.v
// Combinational control signal decoder -- pure lookup from opcode to
// control signals, no state. In a pipelined design each stage completes
// in one cycle, so control never needs to "remember" anything (unlike a
// multi-cycle design, where the controller is genuinely an FSM).

module control_unit (
    input  [3:0] opcode,
    output reg       reg_write,
    output reg       alu_src,     // 0 = 2nd ALU operand from register, 1 = from immediate
    output reg       mem_read,
    output reg       mem_write,
    output reg       mem_to_reg,  // 0 = writeback from ALU, 1 = writeback from memory
    output reg       branch,
    output reg       imm_sel,     // 0 = immediate from instr[3:0]  (I-type)
                                  // 1 = immediate from instr[11:8] (S/B-type)
    output reg [2:0] alu_ctrl
);

    localparam OP_ADD  = 4'b0000;
    localparam OP_SUB  = 4'b0001;
    localparam OP_AND  = 4'b0010;
    localparam OP_OR   = 4'b0011;
    localparam OP_XOR  = 4'b0100;
    localparam OP_SLT  = 4'b0101;
    localparam OP_ADDI = 4'b0110;
    localparam OP_ANDI = 4'b0111;
    localparam OP_ORI  = 4'b1000;
    localparam OP_LW   = 4'b1001;
    localparam OP_SW   = 4'b1010;
    localparam OP_BEQ  = 4'b1011;
    localparam OP_BNE  = 4'b1100;

    always @(*) begin
        // Safe default: a NOP. Every side-effect signal defaults to 0
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        imm_sel    = 1'b0;
        alu_ctrl   = 3'b000;

        case (opcode)
            // R-type: both operands from registers, write result back
            OP_ADD:  begin reg_write=1; alu_src=0; alu_ctrl=3'b000; end
            OP_SUB:  begin reg_write=1; alu_src=0; alu_ctrl=3'b001; end
            OP_AND:  begin reg_write=1; alu_src=0; alu_ctrl=3'b010; end
            OP_OR:   begin reg_write=1; alu_src=0; alu_ctrl=3'b011; end
            OP_XOR:  begin reg_write=1; alu_src=0; alu_ctrl=3'b100; end
            OP_SLT:  begin reg_write=1; alu_src=0; alu_ctrl=3'b101; end

            // I-type ALU: 2nd operand is the immediate (instr[3:0])
            OP_ADDI: begin reg_write=1; alu_src=1; alu_ctrl=3'b000; end
            OP_ANDI: begin reg_write=1; alu_src=1; alu_ctrl=3'b010; end
            OP_ORI:  begin reg_write=1; alu_src=1; alu_ctrl=3'b011; end

            // LW: address = rs1 + imm (ALU does ADD), writeback comes from memory
            OP_LW:   begin reg_write=1; alu_src=1; mem_read=1; mem_to_reg=1; alu_ctrl=3'b000; end

            // SW: address = rs1 + imm, immediate is in instr[11:8], no writeback
            OP_SW:   begin reg_write=0; alu_src=1; mem_write=1; imm_sel=1; alu_ctrl=3'b000; end

            // Branches: compare rs1/rs2 via SUB, immediate (offset) in instr[11:8].
            // BEQ and BNE are IDENTICAL here -- the take/don't-take decision
            // is resolved separately using the opcode + the ALU's zero flag.
            OP_BEQ:  begin reg_write=0; alu_src=0; branch=1; imm_sel=1; alu_ctrl=3'b001; end
            OP_BNE:  begin reg_write=0; alu_src=0; branch=1; imm_sel=1; alu_ctrl=3'b001; end

            default: ; // keep safe-NOP defaults
        endcase
    end

endmodule