module shift_right_logical(
    input [31:0] A,    
    input [31:0] B,    
    output [31:0] out  
);
    reg [31:0] temp;
    always @(*) begin
        if (B >= 32)
            temp = 32'h0;  // Shift by 32 or more results in 0
        else
            temp = A >> B[4:0];  // Logical right shift - fills with 0s
    end
    assign out = temp;
endmodule