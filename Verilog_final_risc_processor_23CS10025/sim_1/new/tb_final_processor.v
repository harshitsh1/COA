`timescale 1ns / 1ps


module tb_final_processor;

    //==========================================================================
    // Testbench Signals
    //==========================================================================
    reg         clk;
    reg         reset;
    reg         sw;
    wire [15:0] leds;
    
    //==========================================================================
    // Clock Generation: 100MHz (10ns period)
    //==========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period = 100MHz
    end
    
    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    final_processor dut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .leds(leds)
    );
    
    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        // Initialize signals
        reset = 1;
        sw = 0;
        #100;
        
        // Display header
        $display("========================================");
        $display("FPGA Halt Module Testbench");
        $display("Testing Autonomous Program Execution");
        $display("========================================");
        $display("Time\t\tReset\tSW\tLEDs (hex)");
        $display("----------------------------------------");
        
        // Hold reset high for 100ns
        #100;
        $display("%0t ns:\tReset=1\tSW=%b\tLEDs=0x%04h", $time, sw, leds);
        
        // Release reset - processor starts execution
        reset = 0;
        $display("%0t ns:\tReset=0 (Program Started)", $time);
        $display("----------------------------------------");
        
        // Wait for program to complete
        // The program does: 5+4+3+2+1 = 15 (0x000F)
        // Give enough time for all instructions to execute
        #50000;
        
        // Display results with SW=0 (lower 16 bits)
        sw = 0;
        #20;
        $display("\n========================================");
        $display("Program Execution Complete");
        $display("========================================");
        $display("%0t ns:\tSW=0 (Lower 16 bits)", $time);
        $display("\t\tLEDs = 0x%04h (decimal: %0d)", leds, leds);
        
        if (leds == 16'h0002) begin
            $display("\t\t✓ PASS: Correct result (expected 0x0002)");
        end else begin
            $display("\t\t✗ FAIL: Incorrect result (expected 0x0002)");
        end
        
        // Toggle switch to display upper 16 bits
        #50;
        sw = 1;
        #20;
        $display("\n%0t ns:\tSW=1 (Upper 16 bits)", $time);
        $display("\t\tLEDs = 0x%04h (decimal: %0d)", leds, leds);
        
        if (leds == 16'h0000) begin
            $display("\t\t✓ PASS: Correct result (expected 0x0000)");
        end else begin
            $display("\t\t✗ FAIL: Incorrect result (expected 0x0000)");
        end
        
        // Toggle switch back to lower bits
        #50;
        sw = 0;
        #20;
        $display("\n%0t ns:\tSW=0 (Lower 16 bits again)", $time);
        $display("\t\tLEDs = 0x%04h (decimal: %0d)", leds, leds);
        
        // Display full 32-bit result
        #50;
        $display("\n========================================");
        $display("Final 32-bit Result Register:");
        $display("  Full value: 0x%08h", {dut.resultRegOut});
        $display("  Upper 16b:  0x%04h", dut.resultRegOut[31:16]);
        $display("  Lower 16b:  0x%04h", dut.resultRegOut[15:0]);
        $display("  Decimal:    %0d", dut.resultRegOut);
        $display("========================================");
        
        // Run a bit longer to observe stability
        #100;
        
        $display("\nSimulation completed at %0t ns", $time);
        $finish;
    end
    
    //==========================================================================
    // Monitor - Track LED changes during execution
    //==========================================================================
    initial begin
        $monitor("%0t ns:\tReset=%b\tSW=%b\tLEDs=0x%04h", 
                 $time, reset, sw, leds);
    end
    
    //==========================================================================
    // Waveform Dump (Optional - for viewing in GTKWave/ModelSim)
    //==========================================================================
    initial begin
        $dumpfile("final_processor.vcd");
        $dumpvars(0, tb_final_processor);
    end
    
    //==========================================================================
    // Timeout Watchdog
    //==========================================================================
    initial begin
        #50000;  // 50us timeout
        $display("\n========================================");
        $display("ERROR: Simulation timeout!");
        $display("Program may not have halted properly");
        $display("========================================");
        $finish;
    end

endmodule
