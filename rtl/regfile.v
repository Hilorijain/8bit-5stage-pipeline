    // regfile.v
    // 16 x 8-bit general-purpose register file, 2 read ports, 1 write port
    // Register 0 is hardwired to zero (similar to riscv convention)

    `timescale 1ns/1ps

    module regfile (
        input        clk,
        input        we,           // RegWrite: 1 = write wd into rd_addr on this clock edge
        input  [3:0] rs1_addr,
        input  [3:0] rs2_addr,
        input  [3:0] rd_addr,
        input  [7:0] wd,           // write data (from writeback mux)
        output [7:0] rd1,          // read data 1
        output [7:0] rd2           // read data 2
    );

        reg [7:0] regs [0:15];     // 16 registers of 8 bits each

        integer i;
        
        // Initialize registers for simulation
        initial begin
            for ( i = 0; i < 16; i = i + 1)
                regs[i] = 8'd0;
        end

        // // Combinational, value appears immediately based on address
        // // Register 0 always reads as zero, regardless of what's stored there
        // assign rd1 = (rs1_addr == 4'd0) ? 8'd0 : regs[rs1_addr];
        // assign rd2 = (rs2_addr == 4'd0) ? 8'd0 : regs[rs2_addr];


    //add same-cycle write-then-read bypass:
    assign rd1 = (rs1_addr == 4'd0) ? 8'd0 :
                (we && rd_addr == rs1_addr) ? wd :
                regs[rs1_addr];

    assign rd2 = (rs2_addr == 4'd0) ? 8'd0 :
                (we && rd_addr == rs2_addr) ? wd :
                regs[rs2_addr];

        // Synchronous write: only happens on a clock edge 
        // and never allowed to overwrite register 0
        always @(posedge clk) begin
            if (we && rd_addr != 4'd0) begin
                regs[rd_addr] <= wd;
            end
        end

    endmodule