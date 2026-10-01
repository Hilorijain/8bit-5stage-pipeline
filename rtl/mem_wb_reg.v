// mem_wb_reg.v
// Pipeline register between Memory and Writeback.
// The last and simplest register -- only what WB actually needs 


module mem_wb_reg (
    input             clk,
    input             stall,
    input             flush,

    input      [7:0]  alu_result_in,
    input      [7:0]  mem_rdata_in,
    input      [3:0]  rd_addr_in,

    input             reg_write_in,
    input             mem_to_reg_in,

    output reg [7:0]  alu_result_out,
    output reg [7:0]  mem_rdata_out,
    output reg [3:0]  rd_addr_out,

    output reg        reg_write_out,
    output reg        mem_to_reg_out
);

    always @(posedge clk) begin
        if (flush) begin
            reg_write_out <= 1'b0;
        end else if (stall) begin
            alu_result_out <= alu_result_out;
            mem_rdata_out  <= mem_rdata_out;
            rd_addr_out    <= rd_addr_out;
            reg_write_out  <= reg_write_out;
            mem_to_reg_out <= mem_to_reg_out;
        end else begin
            alu_result_out <= alu_result_in;
            mem_rdata_out  <= mem_rdata_in;
            rd_addr_out    <= rd_addr_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end

endmodule