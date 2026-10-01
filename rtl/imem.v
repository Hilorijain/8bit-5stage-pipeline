// imem.v
// Instruction memory: 256 x 16-bit words, word-addressed.
// Harvard architecture -- kept separate from data memory so IF and MEM
// never contend for the same port, required for a pipeline

// Combinational read: instruction appears in the same cycle as the address.

module imem (
    input      [7:0]  addr,      // PC value
    output     [15:0] instr
);

    reg [15:0] mem [0:255];

    // Loaded once at simulation starting from given hex file
    initial begin
        $readmemh("programs/day9_test.hex", mem);
    end

    assign instr = mem[addr];

endmodule