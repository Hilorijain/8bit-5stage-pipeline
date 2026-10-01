// forwarding_unit.v

//   00 = no forwarding needed
//   10 = forward from EX/MEM 
//   01 = forward from MEM/WB 


module forwarding_unit (
    input      [3:0] rs1_addr_e, rs2_addr_e,   // EX stage's operand registers
    input      [3:0] ex_mem_rd_addr,
    input      [3:0] mem_wb_rd_addr,
    input            reg_write_m,               // EX/MEM stage will write a register
    input            reg_write_w,               // MEM/WB stage will write a register
    output reg [1:0] forward_a,                 // for rs1
    output reg [1:0] forward_b                  // for rs2
);

    always @(*) begin
        //a
        if (reg_write_m && (ex_mem_rd_addr != 4'd0) && (ex_mem_rd_addr == rs1_addr_e))
            forward_a = 2'b10;   // EX/MEM wins -- checked first, most recent
        else if (reg_write_w && (mem_wb_rd_addr != 4'd0) && (mem_wb_rd_addr == rs1_addr_e))
            forward_a = 2'b01;
        else
            forward_a = 2'b00;

        //b
        if (reg_write_m && (ex_mem_rd_addr != 4'd0) && (ex_mem_rd_addr == rs2_addr_e))
            forward_b = 2'b10;
        else if (reg_write_w && (mem_wb_rd_addr != 4'd0) && (mem_wb_rd_addr == rs2_addr_e))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end

endmodule