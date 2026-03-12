`timescale 1ns / 1ps


// whole new
module data_mem(
    input wire reset,clk,
    input [31:0]  addr, // from ALU result
    input [31:0]  wrData, //take from register == rtOut
    input rdMem, //oontrol signal
    input wrMem, // control signal
    output reg [31:0] rdData // OUTPUT  passed to the mux
    );
    
    wire [31:0] bram_addr = {{20{addr[9]}}, addr[9:0],2'b00};  
    //    wire [31:0] byte_addr_bram_addr = (bram_addr<<2);
    // FIX: Changed from 'reg' to 'wire' so it can be driven by the BRAM instance
    wire [31:0] rdData_from_bram; 
    
    always @(*)begin 
        if(wrMem) begin
           $display("OOOOOOOO stored : %h",wrData);
        end
        else if (rdMem) begin
           $display("OOOOOOO  loaded : %h from location %d",rdData,bram_addr);
        end
    end
    // reg signed [31:0] mem [0:1023];  //1024 locations
    
    data_bram bram_inst (
        .clka(clk),             // Clock Input
        .ena(1'b1),
        .addra(bram_addr),      // Address Input (A[9:0])
        .dina(wrData),          // Write Data Input
        .wea(wrMem),   // Write Enable Input
        .rsta(reset),         
        .douta(rdData_from_bram)      // Read Data Output 
    );
    // This logic captures the BRAM output into the final 'rdData' register, 
    // only when the read control signal 'rdMem' is active.
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rdData <= 32'h0; // Initialize output on reset (good practice)
        end
        else if (rdMem) begin
            rdData <= rdData_from_bram; // Capture the BRAM output
        end
    end
    
endmodule