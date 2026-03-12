module nor_gate_8bit (
    input  [7:0] n1,
    input  [7:0] n2,
    output [7:0] out
);
    wire [7:0] or_out; 

    or_gate_8bit u1 (
        .n1(n1),
        .n2(n2),
        .out(or_out)
    );

    not_gate_8bit u2 (
        .inp(or_out),
        .out(out)
    );

endmodule
