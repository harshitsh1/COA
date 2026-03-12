module shift_right_arithmetic(
    input [31:0] A,    
    input [31:0] B,    
    output [31:0] out  
);
    reg [31:0] temp;
    always @(*) begin
        if (B >= 32) begin
            // For arithmetic shift, if all bits shifted out:
            // - Positive numbers become 0
            // - Negative numbers become all 1s (0xFFFFFFFF)
            temp = A[31] ? 32'hFFFFFFFF : 32'h0;
        end else begin
            temp = $signed(A) >>> B[4:0];  // Arithmetic right shift - preserves sign
        end
    end
    assign out = temp;
endmodule