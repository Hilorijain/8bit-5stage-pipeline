// Inside riscv_pipeline_top.v 


module riscv_pipeline_top (
    input clk,
    input rst
);

wire       reg_write_w;
 wire [7:0] wb_data_w;
 wire [3:0] rd_addr_w;

 wire [1:0] forward_a, forward_b; 
 wire [7:0] alu_result_m;
 wire       stall_hazard;
 wire branch_taken_e;

// Fetch stage

reg  [7:0] pc;
wire [7:0] pc_plus1 = pc + 8'd1;
wire [15:0] instr_f;      // Fetch stage

imem im (.addr(pc), .instr(instr_f));

// Fetch's output feeds the IF/ID register, not decode logic directly
wire [15:0] instr_d;      
wire [7:0]  pc_d;

if_id_reg if_id (
    .clk(clk),
    .stall(stall_hazard),         // wired to 0 for now  
    .flush(branch_taken_e),       
    .instr_in(instr_f),
    .pc_in(pc),
    .instr_out(instr_d),
    .pc_out(pc_d)
);

//  Decode stage

wire [3:0] opcode_d = instr_d[15:12];
wire [3:0] rd_d     = instr_d[11:8];
wire [3:0] rs1_d    = instr_d[7:4];
wire [3:0] rs2_d    = instr_d[3:0];

// Control unit -- same module, same logic, just wired to the Decode-stage 
wire reg_write_d, alu_src_d, mem_read_d, mem_write_d, mem_to_reg_d, branch_d, imm_sel_d;
wire [2:0] alu_ctrl_d;

control_unit cu (
    .opcode(opcode_d),
    .reg_write(reg_write_d), .alu_src(alu_src_d),
    .mem_read(mem_read_d),   .mem_write(mem_write_d),
    .mem_to_reg(mem_to_reg_d), .branch(branch_d),
    .imm_sel(imm_sel_d), .alu_ctrl(alu_ctrl_d)
);

// Immediate generation 
wire [3:0] imm_field_d = imm_sel_d ? instr_d[11:8] : instr_d[3:0];
wire [7:0] imm_ext_d;

imm_gen ig (.imm_in(imm_field_d), .imm_out(imm_ext_d));

wire [7:0] rd1_d, rd2_d;

regfile rf (
    .clk(clk),
    .we(reg_write_w),              // placeholder -- real WB write-enable connects later
    .rs1_addr(rs1_d), .rs2_addr(rs2_d), .rd_addr(rd_addr_w),
    .wd(wb_data_w),               // placeholder -- real WB write-data connects later
    .rd1(rd1_d), .rd2(rd2_d)
);

// ID/EX register connection

wire [7:0] pc_e, rd1_e, rd2_e, imm_e;
wire [3:0] rs1_addr_e, rs2_addr_e, rd_addr_e;
wire       reg_write_e, alu_src_e, mem_read_e, mem_write_e, mem_to_reg_e, branch_e;
wire [2:0] alu_ctrl_e;
wire [3:0] opcode_e;

id_ex_reg id_ex (
    .clk(clk),
    .stall(1'b0),    // hazard unit connects here
    .flush(stall_hazard || branch_taken_e),  

    .pc_in(pc_d), .rd1_in(rd1_d), .rd2_in(rd2_d), .imm_in(imm_ext_d),
    .rs1_addr_in(rs1_d), .rs2_addr_in(rs2_d), .rd_addr_in(rd_d),

    .reg_write_in(reg_write_d), .alu_src_in(alu_src_d),
    .mem_read_in(mem_read_d), .mem_write_in(mem_write_d),
    .mem_to_reg_in(mem_to_reg_d), .branch_in(branch_d),
    .alu_ctrl_in(alu_ctrl_d), .opcode_in(opcode_d),

    .pc_out(pc_e), .rd1_out(rd1_e), .rd2_out(rd2_e), .imm_out(imm_e),
    .rs1_addr_out(rs1_addr_e), .rs2_addr_out(rs2_addr_e), .rd_addr_out(rd_addr_e),

    .reg_write_out(reg_write_e), .alu_src_out(alu_src_e),
    .mem_read_out(mem_read_e), .mem_write_out(mem_write_e),
    .mem_to_reg_out(mem_to_reg_e), .branch_out(branch_e),
    .alu_ctrl_out(alu_ctrl_e), .opcode_out(opcode_e)
);


hazard_detect_unit hdu (
    .mem_read_e(mem_read_e), .rd_addr_e(rd_addr_e),
    .rs1_d(rs1_d), .rs2_d(rs2_d),
    .stall(stall_hazard)
);


// Execute stage

wire [7:0] operand_a_e = (forward_a == 2'b10) ? alu_result_m :
                          (forward_a == 2'b01) ? wb_data_w   :
                                                  rd1_e;

wire [7:0] operand_b_reg_e = (forward_b == 2'b10) ? alu_result_m :
                              (forward_b == 2'b01) ? wb_data_w   :
                                                      rd2_e;

wire [7:0] alu_b_e = alu_src_e ? imm_e : operand_b_reg_e;

wire [7:0] alu_result_e;
wire       zero_e;

alu a (
    .a(operand_a_e), .b(alu_b_e), .alu_ctrl(alu_ctrl_e),
    .result(alu_result_e), .zero(zero_e)
);

// Branch decision
assign branch_taken_e = branch_e & ( (opcode_e == 4'b1011) ?  zero_e    // BEQ
                                                          : ~zero_e); // BNE

wire [7:0] branch_target_e = pc_e + imm_e;

//  EX/MEM register connection

wire [7:0] rd2_m;
wire [3:0] rd_addr_m;
wire       reg_write_m, mem_read_m, mem_write_m, mem_to_reg_m;

ex_mem_reg ex_mem (
    .clk(clk),
    .stall(1'b0),   // this register never actually stalls in practice
    .flush(1'b0),   // connected properly once branch flush logic exists

    .alu_result_in(alu_result_e),
    //.rd2_in(rd2_e), 
        .rd2_in(operand_b_reg_e),          // value to store, for SW
    .rd_addr_in(rd_addr_e),

    .reg_write_in(reg_write_e),
    .mem_read_in(mem_read_e),
    .mem_write_in(mem_write_e),
    .mem_to_reg_in(mem_to_reg_e),

    .alu_result_out(alu_result_m),
    .rd2_out(rd2_m),
    .rd_addr_out(rd_addr_m),

    .reg_write_out(reg_write_m),
    .mem_read_out(mem_read_m),
    .mem_write_out(mem_write_m),
    .mem_to_reg_out(mem_to_reg_m)
);

// Forwarding unit 
forwarding_unit fu (
    .rs1_addr_e(rs1_addr_e), .rs2_addr_e(rs2_addr_e),
    .ex_mem_rd_addr(rd_addr_m), .mem_wb_rd_addr(rd_addr_w),
    .reg_write_m(reg_write_m), .reg_write_w(reg_write_w),
    .forward_a(forward_a), .forward_b(forward_b)
);

// Memory stage

wire [7:0] mem_rdata_m;

dmem dm (
    .clk(clk),
    .mem_read(mem_read_m),
    .mem_write(mem_write_m),
    .addr(alu_result_m),   // address = rs1 + imm, computed back in EX
    .wdata(rd2_m),         // SW stores this value
    .rdata(mem_rdata_m)
);

// MEM/WB register connection

wire [7:0] alu_result_w, mem_rdata_w;
//wire [3:0] rd_addr_w;
wire       mem_to_reg_w;

mem_wb_reg mem_wb (
    .clk(clk),
    .stall(1'b0),
    .flush(1'b0),

    .alu_result_in(alu_result_m),
    .mem_rdata_in(mem_rdata_m),
    .rd_addr_in(rd_addr_m),

    .reg_write_in(reg_write_m),
    .mem_to_reg_in(mem_to_reg_m),

    .alu_result_out(alu_result_w),
    .mem_rdata_out(mem_rdata_w),
    .rd_addr_out(rd_addr_w),

    .reg_write_out(reg_write_w),
    .mem_to_reg_out(mem_to_reg_w)
);

// Writeback stage

assign wb_data_w = mem_to_reg_w ? mem_rdata_w : alu_result_w;

// PC update -- branch redirect not wired in yet 
always @(posedge clk) begin
    if (rst) pc <= 8'd0;
    else if (stall_hazard) pc <= pc;
    else if (branch_taken_e) pc <= branch_target_e;
    else     pc <= pc_plus1;
end

endmodule