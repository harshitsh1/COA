module full_subtractor_32bit(
    input  [31:0] A,
    input  [31:0] B,
    input  Bin,
    //ignored Bin for LSB ( hardcoded it to 0 )
    output [31:0] Diff,
    output Bout
);
    wire [2:0] borrow;

    full_subtractor_8bit FS0(A[7:0],   B[7:0],   Bin,      Diff[7:0],   borrow[0]);
    full_subtractor_8bit FS1(A[15:8],  B[15:8],  borrow[0], Diff[15:8], borrow[1]);
    full_subtractor_8bit FS2(A[23:16], B[23:16], borrow[1], Diff[23:16], borrow[2]);
    full_subtractor_8bit FS3(A[31:24], B[31:24], borrow[2], Diff[31:24], Bout);
endmodule
