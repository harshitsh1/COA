module shift_left(
    input [31:0] A,    
    input [31:0] B,    
    output [31:0] out  
);
    reg [31:0] temp;
    always @(*) begin
        if (B >= 32)
            temp = 32'h0;  
        else
            temp = A << B[4:0];  
    end
    assign out = temp;
endmodule
