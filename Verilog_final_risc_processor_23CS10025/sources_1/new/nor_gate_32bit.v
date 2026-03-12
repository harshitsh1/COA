module nor_gate_32bit (
    input [31:0] n1,
    input [31:0] n2,
    output [31:0] out
);

    nor_gate_8bit nor_gate0 (.n1(n1[7:0]),.n2(n2[7:0]),.out(out[7:0]));
    nor_gate_8bit nor_gate1 (.n1(n1[15:8]),.n2(n2[15:8]),.out(out[15:8]));
    nor_gate_8bit nor_gate2 (.n1(n1[23:16]),.n2(n2[23:16]),.out(out[23:16]));
    nor_gate_8bit nor_gate3 (.n1(n1[31:24]),.n2(n2[31:24]),.out(out[31:24]));
    
endmodule