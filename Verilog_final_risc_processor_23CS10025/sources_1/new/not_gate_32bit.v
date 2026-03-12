module not_gate_32_bit (
    input [31:0] inp,
    output [31:0] out
);

    not_gate_8bit not_gate0 (.inp(inp[7:0]),.out(out[7:0]));
    not_gate_8bit not_gate1 (.inp(inp[15:8]),.out(out[15:8]));
    not_gate_8bit not_gate2 (.inp(inp[23:16]),.out(out[23:16]));
    not_gate_8bit not_gate3 (.inp(inp[31:24]),.out(out[31:24]));
    
endmodule