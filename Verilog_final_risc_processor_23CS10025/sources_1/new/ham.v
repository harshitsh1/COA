// HAM - Hamming Weight (Population Count)
// Counts number of 1s in the input
module ham(
    input wire [31:0] src,          // Source register value
    output wire [31:0] result       // Hamming weight (count of 1s)
);
    reg [5:0] count;  // 6 bits needed for count 0-32
    integer i;
    
    always @(*) begin
        count = 0;
        for (i = 0; i < 32; i = i + 1) begin
            count = count + src[i];
        end
    end
    
    assign result = {26'b0, count};  // Zero-extend to 32 bits
endmodule