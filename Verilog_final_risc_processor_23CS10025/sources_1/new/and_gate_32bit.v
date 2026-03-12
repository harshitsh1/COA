
module and_gate_32_bit (
    input [31:0] n1,
    input [31:0] n2,
    output [31:0] out
);

    and_gate_8bit and_gate0 (.n1(n1[7:0]),.n2(n2[7:0]),.out(out[7:0]));
    and_gate_8bit and_gate1 (.n1(n1[15:8]),.n2(n2[15:8]),.out(out[15:8]));
    and_gate_8bit and_gate2 (.n1(n1[23:16]),.n2(n2[23:16]),.out(out[23:16]));
    and_gate_8bit and_gate3 (.n1(n1[31:24]),.n2(n2[31:24]),.out(out[31:24]));
    
endmodule