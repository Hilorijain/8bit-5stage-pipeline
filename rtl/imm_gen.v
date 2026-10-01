// imm_gen.v
// Widens the 4-bit immediate field to 8 bits by sign extension.
// Sign extension (not zero extension) is used for negative immediates
// range becomes -8 to +7 instead of 0 to 15,
// for backward branches and countdown loops 

module imm_gen (
    input  [3:0] imm_in,
    output [7:0] imm_out
);

    // Replicate the sign bit 
    assign imm_out = {{4{imm_in[3]}}, imm_in};

endmodule