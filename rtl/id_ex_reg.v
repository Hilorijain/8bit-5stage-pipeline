// id_ex_reg.v
// Pipeline register between Decode and Execute.
// Carries both the decoded data (register values, immediate, register
// addresses) and the control signals forward -- control signals must
// travel with the instruction since EX runs one cycle after ID decoded it.

module id_ex_reg (
    input             clk,
    input             stall,   // hold current contents (load-use hazard)
    input             flush,   // force control signals to safe no-op

    // data
    input      [7:0]  pc_in,
    input      [7:0]  rd1_in, rd2_in,
    input      [7:0]  imm_in,
    input      [3:0]  rs1_addr_in, rs2_addr_in, rd_addr_in,

    // control
    input             reg_write_in, alu_src_in, mem_read_in,
    input             mem_write_in, mem_to_reg_in, branch_in,
    input      [2:0]  alu_ctrl_in,
    input      [3:0]  opcode_in,   // needed later for BEQ-vs-BNE 

    output reg [7:0]  pc_out,
    output reg [7:0]  rd1_out, rd2_out,
    output reg [7:0]  imm_out,
    output reg [3:0]  rs1_addr_out, rs2_addr_out, rd_addr_out,

    output reg        reg_write_out, alu_src_out, mem_read_out,
    output reg        mem_write_out, mem_to_reg_out, branch_out,
    output reg [2:0]  alu_ctrl_out,
    output reg [3:0]  opcode_out
);

    always @(posedge clk) begin
        if (flush) begin

            reg_write_out  <= 1'b0;
            mem_write_out  <= 1'b0;
            branch_out     <= 1'b0;
            mem_read_out   <= 1'b0;
            
        end else if (stall) begin
            // hold everything 
            pc_out         <= pc_out;
            rd1_out        <= rd1_out;
            rd2_out        <= rd2_out;
            imm_out        <= imm_out;
            rs1_addr_out   <= rs1_addr_out;
            rs2_addr_out   <= rs2_addr_out;
            rd_addr_out    <= rd_addr_out;
            reg_write_out  <= reg_write_out;
            alu_src_out    <= alu_src_out;
            mem_read_out   <= mem_read_out;
            mem_write_out  <= mem_write_out;
            mem_to_reg_out <= mem_to_reg_out;
            branch_out     <= branch_out;
            alu_ctrl_out   <= alu_ctrl_out;
            opcode_out     <= opcode_out;
            
        end else begin
            pc_out         <= pc_in;
            rd1_out        <= rd1_in;
            rd2_out        <= rd2_in;
            imm_out        <= imm_in;
            rs1_addr_out   <= rs1_addr_in;
            rs2_addr_out   <= rs2_addr_in;
            rd_addr_out    <= rd_addr_in;
            reg_write_out  <= reg_write_in;
            alu_src_out    <= alu_src_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            branch_out     <= branch_in;
            alu_ctrl_out   <= alu_ctrl_in;
            opcode_out     <= opcode_in;
        end
    end

endmodule