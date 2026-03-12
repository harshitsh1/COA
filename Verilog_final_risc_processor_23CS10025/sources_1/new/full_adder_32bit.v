`timescale 1ns / 1ps
module full_adder_32bit(
    input  [31:0] A,
    input  [31:0] B,
    input  Cin,
    output [31:0] SUM,
    output Cout
);
    wire [2:0] carry;   // carry between 8-bit blocks

    // Four 8-bit adders chained together
    full_adder_8bit FA0 (A[7:0],   B[7:0],   Cin,      SUM[7:0],   carry[0]);
    full_adder_8bit FA1 (A[15:8],  B[15:8],  carry[0], SUM[15:8],  carry[1]);
    full_adder_8bit FA2 (A[23:16], B[23:16], carry[1], SUM[23:16], carry[2]);
    full_adder_8bit FA3 (A[31:24], B[31:24], carry[2], SUM[31:24], Cout);
endmodule
