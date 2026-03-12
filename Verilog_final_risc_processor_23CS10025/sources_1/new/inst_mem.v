module instruction_memory (
    input  wire reset,clk,
    input  wire [31:0] pcOut,              // Program counter (address)
    output wire  [5:0] opcode,
    output wire  [5:0] funct,
    output wire  [3:0]  rs,
    output wire  [3:0]  rt,
    output wire  [3:0]  rd,
    output wire  [31:0] imm_signed,
    output wire  [31:0] jmp_signed,
    output wire  [31:0] ins
          
    );
    
    wire [31:0] instruction;
    
    wire [31:0] wrInstrData; 
    wire wrInstrMem = 1'b0; 
    wire [31:0] instr_bram_addr = {{22{pcOut[9]}}, pcOut[9:0]};
    
    instr_bram instruction_mem_bram (
        .clka(clk),             // Clock Input
        .ena(1'b1),
        .rsta(reset),
        .addra(instr_bram_addr),      // Address Input (A[9:0)
        .douta(instruction)      // Read Data Output 
    );
   
        
    // Instruction field extraction
    assign opcode = instruction[31:26];
    wire [4:0]  rs_5bit = instruction[25:21];
    wire [4:0]  rt_5bit = instruction[20:16];
    wire [4:0]  rd_5bit = instruction[15:11];
    // wire [4:0]  shamt = instruction[10:6];  // Unused for now
    assign funct = instruction[5:0];
    wire [15:0] imm = instruction[15:0];
    wire [25:0] jmp = instruction[25:0];
    
    assign imm_signed = {{16{imm[15]}}, imm};
    assign jmp_signed = {{6{jmp[25]}}, jmp};
    
    assign rs = rs_5bit[3:0];
    assign rt = rt_5bit[3:0];
    assign rd = rd_5bit[3:0];
    
    assign ins = instruction;
    
endmodule