`timescale 1ns / 1ps

module tb_processor_five_stage;

    //==========================================================================
    // TESTBENCH SIGNALS
    //==========================================================================
    reg clk;
    reg reset;

    wire [31:0] result_out;
    wire [31:0] rsOut_out;
    wire [31:0] ins;
    wire [3:0]   resultRegInp;
    wire [31:0]  resultRegOut;

    // Monitor internal signals
    wire [2:0] current_state;
    wire [5:0] opcode;

    assign current_state = uut.current_state;
    assign opcode = uut.opcode;

    integer cycle_count = 0;
    integer instr_count = 0;

    //==========================================================================
    // DEVICE UNDER TEST (DUT)
    //==========================================================================
    processor_five_stage uut (
        .clk(clk),
        .reset(reset),
        .resultRegInp(4'b0011),
        .result_out(result_out),
        .resultRegOut(resultRegOut),
        .rsOut_out(rsOut_out),
        .ins(ins)
    );

    //==========================================================================
    // CLOCK GENERATION (100 MHz)
    //==========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //==========================================================================
    // STATE NAME DECODER
    //==========================================================================
    function [71:0] state_name;
        input [2:0] s;
        begin
            case (s)
                3'b000: state_name = "FETCH";
                3'b001: state_name = "DECODE";
                3'b010: state_name = "EXECUTE";
                3'b011: state_name = "MEM";
                3'b100: state_name = "WRITE_OUT";
                3'b101: state_name = "HALT";
                default: state_name = "UNKNOWN";
            endcase
        end
    endfunction

    //==========================================================================
    // MAIN TEST SEQUENCE
    //==========================================================================
    initial begin
        $display("\n===========================================================");
        $display("            NEW HALT MODULE TESTBENCH START (5-STAGE)      ");
        $display("===========================================================");
        $display("Cycle | State     | PC     | Opcode  | Instruction | Result");
        $display("-----------------------------------------------------------");

        // Initialize and reset
        reset = 1;
        #100;
        reset = 0;
        

        // Run until HALT or max cycles
        repeat (20000) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            // Display key pipeline state
            $display("%4d  | %-9s | %06b | %08h | %08h",
                     cycle_count,
                     state_name(current_state),
                     opcode,
                     ins,
                     result_out);

            if (current_state == 3'b010)  // EXECUTE
                instr_count = instr_count + 1;
                #10;

            // Stop simulation on HALT
            if (current_state == 3'b101) begin
                $display("-----------------------------------------------------------");
                $display("*** HALT instruction detected at cycle %0d ***", cycle_count);
                $display("Instructions Executed: %0d", instr_count);
                $display("CPI (Cycles/Instr): %.2f", cycle_count * 1.0 / instr_count);
                $display("===========================================================\n");
                #50;
                $finish;
            end
        end

        // Timeout (no HALT detected)
        $display("-----------------------------------------------------------");
        $display("*** TIMEOUT: HALT not reached after %0d cycles ***", cycle_count);
        $finish;
    end

    //==========================================================================
    // WATCHDOG (safety)
    //==========================================================================
    initial begin
        #100000;
        $display("\n*** ERROR: Simulation timeout (no HALT reached) ***");
        $finish;
    end

endmodule