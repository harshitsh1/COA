module slt(
    input wire signed [31:0] A, B,
    output wire [31:0] C
);
    
    assign C[31:1] = {31{1'b0}};  // Upper 31 bits are always 0
    assign C[0] = A < B;          // LSB is 1 if A < B, 0 otherwise
endmodule