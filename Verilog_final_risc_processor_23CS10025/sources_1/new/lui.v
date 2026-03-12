module lui(
    input wire [15:0] immediate,    // 16-bit immediate value
    output wire [31:0] result       // 32-bit result
);
    assign result = {immediate, 16'h0000};  // Concatenate immediate with 16 zeros
endmodule