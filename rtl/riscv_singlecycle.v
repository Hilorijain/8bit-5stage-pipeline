
// Single-cycle datapath , not pipelined
module riscv_singlecycle (
    input clk,
    input rst
);

    // ---------------- Fetch ----------------
    reg  [7:0] pc;
    wire [7:0] pc_plus1 = pc + 8'd1;
    wire [15:0] instr;

    imem im (.addr(pc), .instr(instr));

    // rs1 and rs2 sit at fixed positions in every instruction format,
    // so these are valid before decode logic even runs.
    wire [3:0] opcode = instr[15:12];
    wire [3:0] rd     = instr[11:8];
    wire [3:0] rs1    = instr[7:4];
    wire [3:0] rs2    = instr[3:0];

    // ---------------- Control ----------------
    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, imm_sel;
    wire [2:0] alu_ctrl;

    control_unit cu (
        .opcode(opcode),
        .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read),   .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .branch(branch),
        .imm_sel(imm_sel), .alu_ctrl(alu_ctrl)
    );

    // ---------------- Immediate ----------------
    // imm_sel picks which field holds the immediate: I-type keeps it at
    // [3:0] (where rs2 would be), S/B-type need rs2 so the immediate
    // moves to [11:8] instead.
    wire [3:0] imm_field = imm_sel ? instr[11:8] : instr[3:0];
    wire [7:0] imm_ext;

    imm_gen ig (.imm_in(imm_field), .imm_out(imm_ext));

    // ---------------- Register file ----------------
    wire [7:0] rd1, rd2;
    wire [7:0] wb_data;

    regfile rf (
        .clk(clk), .we(reg_write),
        .rs1_addr(rs1), .rs2_addr(rs2), .rd_addr(rd),
        .wd(wb_data), .rd1(rd1), .rd2(rd2)
    );

    // ---------------- Execute ----------------
    wire [7:0] alu_b = alu_src ? imm_ext : rd2;
    wire [7:0] alu_result;
    wire       zero;

    alu a (.a(rd1), .b(alu_b), .alu_ctrl(alu_ctrl),
           .result(alu_result), .zero(zero));

    // BEQ and BNE share identical control signals (see control_unit.v) --
    // the opcode itself picks which sense of the zero flag means "take".
    wire branch_taken = branch & ( (opcode == 4'b1011) ?  zero    // BEQ
                                                       : ~zero ); // BNE

    wire [7:0] branch_target = pc_plus1 + imm_ext;

    // ---------------- Memory ----------------
    wire [7:0] mem_rdata;

    dmem dm (
        .clk(clk), .mem_read(mem_read), .mem_write(mem_write),
        .addr(alu_result),   // address = rs1 + imm, computed by the ALU
        .wdata(rd2),         // SW stores the rs2 value
        .rdata(mem_rdata)
    );

    // ---------------- Writeback ----------------
    assign wb_data = mem_to_reg ? mem_rdata : alu_result;

    // ---------------- PC update ----------------
    always @(posedge clk) begin
        if (rst) pc <= 8'd0;
        else     pc <= branch_taken ? branch_target : pc_plus1;
    end

endmodule