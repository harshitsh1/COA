module datapath (
    input  wire         clk,
    input  wire         reset,
    
    //Program Counter
    input  wire         updPc,      // control signal for datapath
    
    // Register file interface
    input  wire         reg_dst,          // which reg to store the value
    input  wire         wr_reg,           // write enable for register file
    input  wire [3:0]   resultRegInp,      //surface to top module
    // ALU interface
    input  wire [4:0]   alu_control,      // 4-bit ALU control
    input  wire         alu_src,          // 1 => pick rtOut, 0 => pick imm
    input  wire         immSel,
    // Data Control Signals
    input  wire        rdMem,
    input  wire        wrMem,
    input  wire        mToReg,
    
    //Branch Instructions
    input  wire [2:0]  brOp,
    
    // CMOV 
    input  wire  isCmov,
    
    //CALL
    input  wire  isCall,
    
    // Outputs
    output wire [5:0]  opcode,
    output wire [5:0]  funct,
    
    output wire [31:0]  result_out,   
    output wire [31:0]  rsOut_out,        // rs register value
    output wire [31:0]  resultRegOut,
    
    output wire [31:0]  ins, 
    
    output wire         zero_flag,
    output wire         negative_flag,
    output wire         overflow_flag
);

    wire [31:0] rsOut, rtOut;
    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire [31:0] imm_base;
    wire [31:0] imm_ext;
    wire [3:0]  dest_reg;
    wire [31:0] rdData;
    wire [31:0] write_data;
    wire [31:0] temp_write_data;
    
    wire [31:0] pcOut;
    wire [31:0] incremented_pcOut;
    wire [31:0] nextPc; //changed nectPc to pcIn
    // Instruction memory outputs
    wire [3:0]  rs;
    wire [3:0]  rt;
    wire [3:0]  rd;
    wire [31:0] imm_signed;
    wire [31:0] jmp_signed;
    
    //Branching
    wire isBranch;
    
    //Cmov
    wire [31:0] Cmov_mux_inp1;
    wire [31:0] Cmov_mux_inp2;
    
   
    //Program counter
    program_counter pc(
        .clk(clk),
        .reset(reset),
        .updPc(updPc),
        .pcIn(nextPc),    //later we need to put here NextPC which would be updated once, the execution is done
        .pcOut(pcOut)
    );
    
    //Next PC component
    assign incremented_pcOut = pcOut+4;
    
    // Instantiate instruction memory
    instruction_memory inst_mem (
        .clk(clk),
        .reset(reset),
        .pcOut(pcOut),
        .opcode(opcode),
        .funct(funct),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        
        .ins(ins),
                
        .imm_signed(imm_signed),
        .jmp_signed(jmp_signed)

    );
    
    //Branch Comparator 
    branch_comparator branch_comp(
        .brOp(brOp),
        .rsOut(rsOut),
        .clk(clk),
        .isBranch(isBranch)
    );
    
    
    //Data Mem
    data_mem data_memory(
        .clk(clk),
        .reset(reset),
        .addr(alu_result),
        .wrData(rtOut),
        .rdMem(rdMem),
        .wrMem(wrMem),
        .rdData(rdData)
    );
    
    // MUX
    assign dest_reg  = (reg_dst) ? rd : rt;

    
    // Instantiate register bank
    reg_bank registers (
        .clk(clk),
        .reset(reset),
        .wrReg(wr_reg),
        .isCall(isCall),
        .rs(rs),
        .rt(rt),
        .rd(dest_reg),
        .rdIn(write_data),      // Write ALU result to register
        .rsOut(rsOut),
        .rtOut(rtOut),
        .resultRegInp(resultRegInp),
        .resultRegOut(resultRegOut)
    );
    
    // MUX - immsel
    assign imm_base = (immSel) ? jmp_signed : imm_signed;
    
    // For branch instr the immediate needs to be byte offset imm<<2
    assign imm_ext = (isBranch ) ? (imm_base<<2) : imm_base;
    
    //MUX - brOp
    assign Cmov_mux_inp1 = (brOp[2]) ? rsOut : pcOut; //updated brOp[2] to |brOp
    
    // MUX - alu_src  select between rt and immediate
    assign Cmov_mux_inp2 = (alu_src) ? rtOut : imm_ext;
     
    cmov_comparator CMOV (
        .isCmov(isCmov),
        .rs_val(rsOut), 
        .rt_val(rtOut),
        .aluip1(Cmov_mux_inp1),
        .aluip2(Cmov_mux_inp2),
        .aluip_fin1(alu_operand_a), 
        .aluip_fin2(alu_operand_b)
    );
    // Instantiate ALU wrapper
    ALU ALUinst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero_flag(zero_flag),
        .negative_flag(negative_flag),
        .overflow_flag(overflow_flag)
    );
    
    // MUX for write data: choose between memory data and ALU result
    assign temp_write_data = (mToReg) ? rdData : alu_result;
    
    // if Call write data = PC out 
    assign write_data = (isCall) ? incremented_pcOut : temp_write_data; 
    
    always@(*) begin
            //$display("   ----check result_out: %h  ", result_out);
//       $display(" -------check brOps mux out %d",Cmov_mux_inp1);
//       $display(" -------check alusrc mux out %d",Cmov_mux_inp2);
//       $display(" -------check alu_operA mux out %d",alu_operand_a);
//       $display(" -------check alu_operB mux out %d",alu_operand_b);
//       $display(" -------check temp_write_data mux out %d",temp_write_data);
//       $display(" -------check write_data mux out %d",write_data);
    end
    // MUX for Next Pc
    assign nextPc = (isBranch) ? alu_result : incremented_pcOut;
    
    always@(*) begin
        $display("________ PC is  %h",pcOut);
//        $display("________ Next PC  is  %d",nextPc);
    end
    
    
    // Output assignments
    assign result_out = write_data;
    // if memory to reg -> send the memory data    
    assign rsOut_out      = rsOut;
    
endmodule
