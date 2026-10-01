// if_id_reg.v
// Pipeline register between Fetch and Decode.
// Latches the fetched instruction and PC so ID can use them


module if_id_reg (
    input             clk,
    input             stall,   // holds current contents(hazard) 
    input             flush,   // clears to NOP -- used later for taken branches
    input      [15:0] instr_in,
    input      [7:0]  pc_in,
    output reg [15:0] instr_out,
    output reg [7:0]  pc_out
);

    always @(posedge clk) begin
        if (flush) begin
            instr_out <= 16'd0;
            pc_out    <= 8'd0;
        end else if (stall) begin
            instr_out <= instr_out;
            pc_out    <= pc_out;
        end else begin
            instr_out <= instr_in;
            pc_out    <= pc_in;
        end
    end

endmodule