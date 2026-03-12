`timescale 1ns / 1ps
module full_subtractor_8bit(

    input  [7:0] A,
    input  [7:0] B,
    input  Bin,
    output [7:0] Diff,
    output Bout
);
    wire [6:0] borrow;

    full_subtractor FS0(A[0], B[0], Bin,      Diff[0], borrow[0]);
    full_subtractor FS1(A[1], B[1], borrow[0], Diff[1], borrow[1]);
    full_subtractor FS2(A[2], B[2], borrow[1], Diff[2], borrow[2]);
    full_subtractor FS3(A[3], B[3], borrow[2], Diff[3], borrow[3]);
    full_subtractor FS4(A[4], B[4], borrow[3], Diff[4], borrow[4]);
    full_subtractor FS5(A[5], B[5], borrow[4], Diff[5], borrow[5]);
    full_subtractor FS6(A[6], B[6], borrow[5], Diff[6], borrow[6]);
    full_subtractor FS7(A[7], B[7], borrow[6], Diff[7], Bout);
endmodule
