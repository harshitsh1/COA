module dec(
    input  [31:0] A,       // Register input
    output [31:0] OUT,     // Decremented result
    output Bout            // Borrow out (underflow indicator)
);

    // Constant 1 for subtraction
    wire [31:0] ONE = 32'b1;

    full_subtractor_32bit SUB (
        .A(A),
        .B(ONE),
        .Bin(1'b0),   // no borrow in
        .Diff(OUT),
        .Bout(Bout)
    );

endmodule
