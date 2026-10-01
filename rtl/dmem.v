// dmem.v
// Data memory: 256 x 8-bit, byte-addressed.
// Combinational read (gated by mem_read), synchronous write.
// Same read/write philosophy as regfile.v

module dmem (
    input             clk,
    input             mem_read,
    input             mem_write,
    input      [7:0]  addr,
    input      [7:0]  wdata,
    output     [7:0]  rdata
);

    reg [7:0] mem [0:255];

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 8'd0;
    end

    // Gated read: an instruction that isn't a load reads a clean 0,
   
    assign rdata = mem_read ? mem[addr] : 8'd0;

    always @(posedge clk) begin
        if (mem_write) mem[addr] <= wdata;
    end

endmodule