`timescale 1ns / 1ps

module processor_six_stage (
    input  wire         clk,
    input  wire         reset,
    input  wire [3:0]   resultRegInp,
    output wire [31:0]  result_out,
    output wire [31:0]  rsOut_out,
    output wire [31:0]  resultRegOut,
    output wire [31:0]  ins
);
    
    // FSM States - 6 Stage Pipeline
    localparam FETCH     = 3'b000;
    localparam DECODE    = 3'b001; 
    localparam EXECUTE   = 3'b010;
    localparam MEM       = 3'b011;
    localparam MEM_CHECK = 3'b100;
    localparam WRITE_OUT = 3'b101;
    localparam HALT      = 3'b110;
    
    reg [2:0] current_state, next_state;
    
    // Instruction memory outputs
    wire [5:0]  opcode;
    wire [5:0]  funct;
    wire        zero_flag;
    wire        negative_flag;
    wire        overflow_flag;
    
    // Control signals
    wire [4:0]  alu_control;
    wire        alu_src;
    wire        wr_reg;
    wire        reg_dst;
    wire        immSel;
    wire        rdMem;
    wire        wrMem;
    wire        mToReg;
    wire [2:0]  brOp;
    wire        updPc;
    
    // Internal control signals
    reg         updPc_gated;
    reg         wr_reg_gated;
    reg         wrMem_gated;
    reg         rdMem_gated;
    
    wire        isCmov;
    wire        isCall;
    
    // Halt detection
    wire        is_halt;
    assign is_halt = (opcode == 6'b100100);
    
    //==========================================================================
    // FSM STATE REGISTER
    //==========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= FETCH;
        end else begin
            current_state <= next_state;
        end
    end
    
    //==========================================================================
    // FSM NEXT STATE LOGIC
    //==========================================================================
    always @(*) begin
        case (current_state)
            FETCH: begin
                next_state = DECODE;
            end
            
            DECODE: begin
                next_state = EXECUTE;
            end
            
            EXECUTE: begin
                if (is_halt) begin
                    next_state = HALT;
                end else begin
                    next_state = MEM;
                end
            end
            
            MEM: begin
                next_state = MEM_CHECK;
            end
            
            MEM_CHECK: begin
                next_state = WRITE_OUT;
            end
            
            WRITE_OUT: begin
                next_state = FETCH;
            end
            
            HALT: begin
                next_state = HALT;  // Stay in HALT forever
            end
            
            default: begin
                next_state = FETCH;
            end
        endcase
    end
    
    //==========================================================================
    // FSM OUTPUT LOGIC - Gate control signals based on state
    //==========================================================================
    always @(*) begin
        case (current_state)
            FETCH: begin
                updPc_gated   = 1'b0;
                wr_reg_gated  = 1'b0;
                wrMem_gated   = 1'b0;
                rdMem_gated   = 1'b0;
            end
            
            DECODE: begin
                updPc_gated   = 1'b0;
                wr_reg_gated  = 1'b0; 
                wrMem_gated   = 1'b0;
                rdMem_gated   = 1'b0;
            end
            
            EXECUTE: begin
                updPc_gated   = 1'b0;       // No PC update yet
                wr_reg_gated  = 1'b0;       // No register write yet
                wrMem_gated   = 1'b0;       // No memory operations yet
                rdMem_gated   = 1'b0;
            end
            
            MEM: begin
                updPc_gated   = 1'b0;
                wr_reg_gated  = 1'b0;       // No register write yet
                wrMem_gated   = wrMem;      // Allow memory write
                rdMem_gated   = rdMem;      // Allow memory read
            end
            
            MEM_CHECK: begin
                updPc_gated   = 1'b0;
                wr_reg_gated  = 1'b0;       // No register write yet
                wrMem_gated   = wrMem;      // Keep memory signals active
                rdMem_gated   = rdMem;      // Keep memory signals active
            end
            
            WRITE_OUT: begin
                updPc_gated   = updPc;
                wr_reg_gated  = wr_reg;     // Allow register write
                wrMem_gated   = 1'b0;
                rdMem_gated   = 1'b0;
            end
            
            HALT: begin
                updPc_gated   = 1'b0;
                wr_reg_gated  = 1'b0;
                wrMem_gated   = 1'b0;
                rdMem_gated   = 1'b0;
            end
            
            default: begin
                updPc_gated   = 1'b0;
                wr_reg_gated  = 1'b0;
                wrMem_gated   = 1'b0;
                rdMem_gated   = 1'b0;
            end
        endcase
    end
    
    //==========================================================================
    // CONTROL PATH INSTANTIATION
    //==========================================================================
    control_unit ctrl (
        .opcode(opcode),
        .funct(funct),
        .alu_control(alu_control),
        .alu_src(alu_src),
        .immSel(immSel),
        .wr_reg(wr_reg),
        .reg_dst(reg_dst),
        .rdMem(rdMem),
        .wrMem(wrMem),
        .mToReg(mToReg),
        .brOp(brOp),
        .isCmov(isCmov),
        .isCall(isCall),
        .updPc(updPc)
    );
    
    //==========================================================================
    // DATAPATH INSTANTIATION
    //==========================================================================
    datapath dp (
        .clk(clk),
        .reset(reset),
        .updPc(updPc_gated),        // Use gated signal
        .resultRegInp(resultRegInp),
        .resultRegOut(resultRegOut),
        .reg_dst(reg_dst),
        .wr_reg(wr_reg_gated),      // Use gated signal
        
        .alu_control(alu_control),
        .alu_src(alu_src),
        .immSel(immSel),
        
        .rdMem(rdMem_gated),        // Use gated signal
        .wrMem(wrMem_gated),        // Use gated signal
        .mToReg(mToReg),
        
        .brOp(brOp),
        .isCmov(isCmov),
        .isCall(isCall),
        .opcode(opcode),
        .funct(funct),
        .result_out(result_out),
        .rsOut_out(rsOut_out),
        
        .ins(ins),
        
        .zero_flag(zero_flag),
        .negative_flag(negative_flag),
        .overflow_flag(overflow_flag)
    );
    
    //==========================================================================
    // DEBUG DISPLAY
    //==========================================================================
//    always @(posedge clk) begin
//        if (!reset) begin
//            case (current_state)
//                EXECUTE: $display("[TIME=%0t] STATE=EXECUTE | OPCODE=%b | INS=%h | RESULT=%h", 
//                                  $time, opcode, ins, result_out);
//                MEM:     $display("[TIME=%0t] STATE=MEM | rdMem=%b | wrMem=%b", 
//                                  $time, rdMem_gated, wrMem_gated);
//                MEM_CHECK: $display("[TIME=%0t] STATE=MEM_CHECK | rdMem=%b | wrMem=%b | Data should be loaded", 
//                                    $time, rdMem_gated, wrMem_gated);
//                WRITE_OUT: $display("[TIME=%0t] STATE=WRITE_OUT | wr_reg=%b", 
//                                    $time, wr_reg_gated);
//            endcase
//        end
//        if (is_halt && current_state == EXECUTE) begin
//            $display("[TIME=%0t] === HALT INSTRUCTION EXECUTED ===", $time);
//        end
//    end
    
endmodule