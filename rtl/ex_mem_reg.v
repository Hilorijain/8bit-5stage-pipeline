// ex_mem_reg.v
// Pipeline register between Execute and Memory.
// Carries the ALU result, store data, and destination address forward.
// Signals only needed up through EX (alu_src, branch, opcode, rs1/rs2_addr)
// are deliberately NOT carried further 

module ex_mem_reg (
    input             clk,
    input             stall,
    input             flush,

    // ---- data ----
    input      [7:0]  alu_result_in,
    input      [7:0]  rd2_in,          // value to store, for SW
    input      [3:0]  rd_addr_in,

    // ---- control (only what MEM/WB still need) ----
    input             reg_write_in,
    input             mem_read_in,
    input             mem_write_in,
    input             mem_to_reg_in,

    output reg [7:0]  alu_result_out,
    output reg [7:0]  rd2_out,
    output reg [3:0]  rd_addr_out,

    output reg        reg_write_out,
    output reg        mem_read_out,
    output reg        mem_write_out,
    output reg        mem_to_reg_out
);

    always @(posedge clk) begin
        if (flush) begin
            
            reg_write_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_read_out  <= 1'b0;

        end else if (stall) begin
            alu_result_out <= alu_result_out;
            rd2_out        <= rd2_out;
            rd_addr_out    <= rd_addr_out;
            reg_write_out  <= reg_write_out;
            mem_read_out   <= mem_read_out;
            mem_write_out  <= mem_write_out;
            mem_to_reg_out <= mem_to_reg_out;
            
        end else begin
            alu_result_out <= alu_result_in;
            rd2_out        <= rd2_in;
            rd_addr_out    <= rd_addr_in;
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end

endmodule