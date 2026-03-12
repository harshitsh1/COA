module inc(
    input  [31:0] A,      // Register input
    output [31:0] OUT,    // Incremented result
    output Cout           // Carry-out (in case of overflow)
);

    // We add A + 1
    wire [31:0] ONE = 32'b1;

    full_adder_32bit ADD (
        .A(A),
        .B(ONE),
        .Cin(1'b0),
        .SUM(OUT),
        .Cout(Cout)
    );

endmodule
