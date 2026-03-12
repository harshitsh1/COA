module control_unit(
    input  wire [5:0] opcode,
    input  wire [5:0] funct,        // 6-bit function field from instr[5:0]
    output reg  [4:0] alu_control,  // 5-bit control to ALU wrapper
    output reg        alu_src,      // 1 => use rt, 0 => use immediate
    output reg        immSel,       // if 0 -> 16bit imm else 26bit jmp
    output reg        wr_reg,       // write register file
    output reg        reg_dst,       // 1 => rd (R-type), 0 => rt (I-type)
    output reg        rdMem,        // Read from data memory
    output reg        wrMem,         // Write to data memory
    output reg        mToReg,       //  if 1 => Meomry send to register else alu_result
    output reg  [2:0] brOp,         // which branch to choose in branch comparator
    output reg        isCmov,
    output reg        isCall,
    output reg        updPc
);

    // ALU control encodings (5-bit for ALU)
    localparam ALU_LUI  = 4'b00000;
        
    localparam ALU_ADD  = 4'b00001;
    localparam ALU_SUB  = 4'b00010;
    localparam ALU_AND  = 4'b00011;
    localparam ALU_OR   = 4'b00100;
    localparam ALU_XOR  = 4'b00101;
    localparam ALU_NOR  = 4'b00110;
    localparam ALU_SL   = 4'b00111;
    localparam ALU_SRL  = 4'b01000;
    localparam ALU_SRA  = 4'b01001;
    localparam ALU_SLT  = 4'b01010;
    localparam ALU_SGT  = 4'b01011;
    localparam ALU_NOT  = 4'b01100;
    localparam ALU_INC  = 4'b01101;
    localparam ALU_DEC  = 4'b01110;
    localparam ALU_HAM  = 4'b01111;

    // Opcode definitions
    // R-type: 000000
    // I-type: ADDI:000001, SUBI:000010, ANDI:000011, ORI:000100, XORI:000101
    //         NOTI:001100, INCI:001101, DECI:001110, HAMI:001111, LUI:010000

    always @(*) begin
        // Default values
        alu_control = ALU_ADD;
        alu_src     = 1'b1;    // default to rt (R-type)
        immSel      = 1'b0;
        wr_reg      = 1'b0;
        reg_dst     = 1'b0;
        rdMem       = 1'b0;
        wrMem       = 1'b0;
        mToReg      = 1'b0;
        updPc       = 1'b0;
        brOp        = 3'b100;
        isCmov      = 1'b0;
        isCall      = 1'b0;

        case (opcode)
            6'b000000: begin // R-type instruction
                reg_dst  = 1'b1;   // write to rd
                wr_reg   = 1'b1;   // enable write
                alu_src  = 1'b1;   // use rt as operand_b
                updPc    = 1'b1;
                brOp     = 3'b100;
                case (funct)
                    6'b000001: alu_control = ALU_ADD;
                    6'b000010: alu_control = ALU_SUB;
                    6'b000011: alu_control = ALU_AND;
                    6'b000100: alu_control = ALU_OR;
                    6'b000101: alu_control = ALU_XOR;
                    6'b000110: alu_control = ALU_NOR;
                    6'b000111: alu_control = ALU_SL;
                    6'b001000: alu_control = ALU_SRL;
                    6'b001001: alu_control = ALU_SRA;
                    6'b001010: alu_control = ALU_SLT;
                    6'b001011: alu_control = ALU_SGT;
                    6'b001100: alu_control = ALU_NOT;
                    6'b001101: alu_control = ALU_INC;
                    6'b001110: alu_control = ALU_DEC;
                    6'b001111: alu_control = ALU_HAM;
                    default:  alu_control = ALU_ADD;
                endcase
            end

            // I-type instructions
            6'b000001: begin // ADDI
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;   // write to rt
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b000010: begin // SUBI
                alu_control = ALU_SUB;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b000011: begin // ANDI
                alu_control = ALU_AND;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b000100: begin // ORI
                alu_control = ALU_OR;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b000101: begin // XORI
                alu_control = ALU_XOR;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b000110: begin // NORI
                alu_control = ALU_NOR;
                alu_src     = 1'b0;   // use immediate
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;   // write to rt
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b000111: begin // SLI
                alu_control = ALU_SL;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001000: begin // SRLI
                alu_control = ALU_SRL;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001001: begin // SRAI
                alu_control = ALU_SRA;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001010: begin // SLTI
                alu_control = ALU_SLT;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001011: begin // SGTI
                alu_control = ALU_SGT;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001100: begin // NOTI
                alu_control = ALU_NOT;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001101: begin // INCI
                alu_control = ALU_INC;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001110: begin // DECI
                alu_control = ALU_DEC;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b001111: begin // HAMI
                alu_control = ALU_HAM;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            6'b010000: begin // LUI
                alu_control = ALU_LUI;
                alu_src     = 1'b0;
                immSel      = 1'b0;
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            // MEMORY Control Signals

            6'b010001: begin //LD
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                immSel      = 1'b0;   
                wr_reg      = 1'b1;
                reg_dst     = 1'b0;   // write to rt
                rdMem       = 1'b1;
                wrMem       = 1'b0;
                mToReg      = 1'b1;
                brOp        = 3'b100;
                updPc    = 1'b1;
                
            end
            
            6'b010010: begin //SW
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                immSel      = 1'b0;
                wr_reg      = 1'b0;
                reg_dst     = 1'b0;   // write to rt
                rdMem       = 1'b0;
                wrMem       = 1'b1;
                mToReg      = 1'b0;
                brOp        = 3'b100;
                updPc    = 1'b1;
            end
            
            
            // BRANCH
            //immSel = 1 means jump
            
             6'b100000: begin //BR
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                brOp        = 3'b000;
                immSel      = 1'b1;
                wr_reg      = 1'b0;
                reg_dst     = 1'b0;   // write to rt
                rdMem       = 1'b0;
                wrMem       = 1'b0;
                mToReg      = 1'b0;
                updPc    = 1'b1;
            end
            
             6'b100001: begin //BMI
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                brOp        = 3'b001;
                immSel      = 1'b0;
                wr_reg      = 1'b0;
                reg_dst     = 1'b0;   // write to rt
                rdMem       = 1'b0;
                wrMem       = 1'b0;
                mToReg      = 1'b0;
                updPc    = 1'b1;
            end
            
            6'b100010: begin //BPL
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                brOp        = 3'b010;
                immSel      = 1'b0;
                wr_reg      = 1'b0;
                reg_dst     = 1'b0;   // write to rt
                rdMem       = 1'b0;
                wrMem       = 1'b0;
                mToReg      = 1'b0;
                updPc    = 1'b1;
                 
                $display("BPL Instruction is hit brop is %h",brOp);
                 
            end
            
             6'b100011: begin //BZ
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                brOp        = 3'b011;
                immSel      = 1'b0;
                wr_reg      = 1'b0;
                reg_dst     = 1'b0;   // write to rt
                rdMem       = 1'b0;
                wrMem       = 1'b0;
                mToReg      = 1'b0;
                updPc    = 1'b1;
            end
            
            6'b010100: begin  //MOVE
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   
                immSel      = 1'b0;  // send 0 in immediate    
                wr_reg      = 1'b1;
                reg_dst     = 1'b0; //rt ( isa file has some wrong)
                brOp        = 3'b100;
                isCmov      = 1'b0;
                mToReg      = 1'b0;
                updPc    = 1'b1;
                
                $display("Move is set ");
                
            end
            
            6'b010101: begin  //CMOV
                alu_control = ALU_ADD;
                alu_src     = 1'b1;   
                immSel      = 1'b0;  // send 0 in immediate    
                wr_reg      = 1'b1;
                reg_dst     = 1'b1; //rd 
                brOp        = 3'b100;
                isCmov      = 1'b1;
                mToReg      = 1'b0;
                updPc    = 1'b1;
                
                $display("CMOV is set ");
            end
            
            //SYSCALLS
            
            6'b100101: begin //NOP
            // Same as default
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   
                immSel      = 1'b1;  // send 0 in immediate 26 bit  
                wr_reg      = 1'b0;
                reg_dst     = 1'b0; //rt ( isa file has some wrong)
                brOp        = 3'b100;
                isCmov      = 1'b0;
                mToReg      = 1'b0;
                updPc    = 1'b1;
            end
            
            6'b100110: begin //CALL
            // Same as default
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   
                immSel      = 1'b0;  // send 0 in immediate 16 bit
                wr_reg      = 1'b1;
                reg_dst     = 1'b0; //rt
                brOp        = 3'b100;
                isCmov      = 1'b0;
                mToReg      = 1'b0;
                isCall      = 1'b1;
                updPc    = 1'b1;
            end
            
            6'b100100: begin //HALT
                alu_control = ALU_ADD;
                alu_src     = 1'b0;   // use immediate
                brOp        = 3'b100;
                immSel      = 1'b0;
                wr_reg      = 1'b0;
                reg_dst     = 1'b0;   // write to rt
                rdMem       = 1'b0;
                wrMem       = 1'b0;
                mToReg      = 1'b0;
                updPc    = 1'b0;
                $display("program halted");
            end

            default: begin
                // No operation - keep defaults
                alu_control = ALU_ADD;
                brOp        = 3'b100;
                alu_src     = 1'b0;
                wr_reg      = 1'b0;
                reg_dst     = 1'b0;
                updPc    = 1'b0;
            end
        endcase
    end
endmodule