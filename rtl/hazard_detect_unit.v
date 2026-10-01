// hazard_detect_unit.v
module hazard_detect_unit (
    input        mem_read_e,      // is the instruction in EX a load?
    input  [3:0] rd_addr_e,
    input  [3:0] rs1_d, rs2_d,    // operands of the instruction currently in ID
    output       stall
);
    assign stall = mem_read_e && (rd_addr_e != 4'd0) &&
                   ((rd_addr_e == rs1_d) || (rd_addr_e == rs2_d));
endmodule