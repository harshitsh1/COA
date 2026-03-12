`timescale 1ns / 1ps



module final_processor (
    input  wire        clk,          // E3: 100MHz System Clock
    input  wire        reset,        // BTNC: CPU Reset Button (Active-High)
    input  wire        sw,           // J15: SW[0] Display Select Switch
    output wire [15:0] leds           // H17, K15, ...: 16 Green LEDs
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    wire [31:0] result_out;          // 32-bit result from processor
    wire [31:0] rsOut_out;           // RS register output (if needed)
    wire [31:0] ins;                 // Current instruction
    
    wire [3:0] resultRegInp;       // Address of Result reg   
    wire [31:0] resultRegOut;       // value in result reg
    
    assign resultRegInp = 4'b0011;
    
    
    // Synchronized reset signal
    reg reset_sync1, reset_sync2;
    wire reset_clean;
    
    //==========================================================================
    // RESET SYNCHRONIZATION
    // Synchronize the async reset button to the clock domain
    //==========================================================================
    always @(posedge clk) begin
        reset_sync1 <= reset;
        reset_sync2 <= reset_sync1;
    end
    
    assign reset_clean = reset_sync2;
    
    //==========================================================================
    // PROCESSOR INSTANTIATION
    // The halt_module contains the FSM, control path, and datapath
    //==========================================================================
    processor_five_stage processor (
        .clk(clk),
        .reset(reset_clean),
        .resultRegInp(resultRegInp),
        .result_out(result_out),
        .rsOut_out(rsOut_out),
        .resultRegOut(resultRegOut),
        .ins(ins)
    );
    
    //==========================================================================
    // MULTIPLEXED LED OUTPUT
    // SW[0] = 0: Display lower 16 bits (bits [15:0])
    // SW[0] = 1: Display upper 16 bits (bits [31:16])
    //==========================================================================
    assign leds = sw ? resultRegOut[31:16] : resultRegOut[15:0];
    
endmodule

