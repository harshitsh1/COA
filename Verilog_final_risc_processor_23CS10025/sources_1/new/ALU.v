module ALU (
    input [31:0] operand_a,
    input [31:0] operand_b,
    input [4:0] alu_control,
    output [31:0] result,
    output zero_flag,
    output negative_flag,
    output overflow_flag
);

    // ALU operation codes AS PER ISA
//    parameter ADD  = 5'b00000;
//    parameter SUB  = 5'b00001;
//    parameter AND  = 5'b00010;
//    parameter OR   = 5'b00011;
//    parameter XOR  = 5'b00100;
//    parameter NOR  = 5'b00101;
//    parameter NOT  = 5'b00110;
//    parameter SL   = 5'b00111;  // Shift Left
//    parameter SRL  = 5'b01000;  // Shift Right Logical
//    parameter SRA  = 5'b01001;  // Shift Right Arithmetic
//    parameter INC  = 5'b01010;
//    parameter DEC  = 5'b01011;
//    parameter SLT  = 5'b01100;  // Set Less Than
//    parameter SGT  = 5'b01101;  // Set Greater Than
//    parameter LUI  = 5'b01110;  // Load Upper Immediate
//    parameter HAM  = 5'b01111;  // Hamming Weight (population count)
    
    // Correct ISA
        parameter LUI  = 5'b00000;
        
        parameter ADD  = 5'b00001;
        parameter SUB  = 5'b00010;
        parameter AND  = 5'b00011;
        parameter OR   = 5'b00100;
        parameter XOR  = 5'b00101;
        parameter NOR  = 5'b00110;
        parameter SL   = 5'b00111;
        parameter SRL  = 5'b01000;
        parameter SRA  = 5'b01001;
        parameter SLT  = 5'b01010;
        parameter SGT  = 5'b01011;
        parameter NOT  = 5'b01100;
        parameter INC  = 5'b01101;
        parameter DEC  = 5'b01110;
        parameter HAM  = 5'b01111;
    
    // Internal wires for module outputs
    wire [31:0] add_result, sub_result;
    wire [31:0] and_result, or_result, xor_result, nor_result, not_result;
    wire [31:0] sl_result, srl_result, sra_result;
    wire [31:0] inc_result, dec_result;
    wire [31:0] slt_result, sgt_result, lui_result, ham_result;
    wire inc_cout, dec_bout;
    wire [32:0] temp_add, temp_sub;
    
    // Instantiate your custom modules
    and_gate_32_bit and_inst (.n1(operand_a), .n2(operand_b), .out(and_result));
    or_gate_32_bit or_inst (.n1(operand_a), .n2(operand_b), .out(or_result));
    xor_gate_32_bit xor_inst (.n1(operand_a), .n2(operand_b), .out(xor_result));
    nor_gate_32bit nor_inst (.n1(operand_a), .n2(operand_b), .out(nor_result));
    not_gate_32_bit not_inst (.inp(operand_a), .out(not_result));
    
    shift_left sl_inst (.A(operand_a), .B(operand_b), .out(sl_result));
    shift_right_logical srl_inst (.A(operand_a), .B(operand_b), .out(srl_result));
    shift_right_arithmetic sra_inst (.A(operand_a), .B(operand_b), .out(sra_result));
    
    inc inc_inst (.A(operand_b), .OUT(inc_result), .Cout(inc_cout));
    dec dec_inst (.A(operand_b), .OUT(dec_result), .Bout(dec_bout));
    
    slt slt_inst (.A(operand_a), .B(operand_b), .C(slt_result));
    sgt sgt_inst (.A(operand_a), .B(operand_b), .C(sgt_result));
    
    lui lui_inst (.immediate(operand_b[15:0]), .result(lui_result));
    ham ham_inst (.src(operand_b), .result(ham_result));
    
    // ADD and SUB need overflow detection - implement with behavioral code
    assign temp_add = {1'b0, operand_a} + {1'b0, operand_b};
    assign temp_sub = {1'b0, operand_a} - {1'b0, operand_b};
    assign add_result = temp_add[31:0];
    assign sub_result = temp_sub[31:0];
    
    // Direct output assignment based on control signal
    reg [31:0] result_reg;
    always @(*) begin
        case (alu_control)
            ADD: result_reg = add_result;
            SUB: result_reg = sub_result;
            AND: result_reg = and_result;
            OR:  result_reg = or_result;
            XOR: result_reg = xor_result;
            NOR: result_reg = nor_result;
            NOT: result_reg = not_result;
            SL:  result_reg = sl_result;
            SRL: result_reg = srl_result;
            SRA: result_reg = sra_result;
            INC: result_reg = inc_result;
            DEC: result_reg = dec_result;
            SLT: result_reg = slt_result;
            SGT: result_reg = sgt_result;
            LUI: result_reg = lui_result;
            HAM: result_reg = ham_result;
            default: result_reg = 32'h0;
        endcase
        case (alu_control)
            HAM: $display("+++++++++ HAM %d oper_a : %d  and oper_b : %d ",ham_result,operand_a,operand_b);
        endcase
    end
    
    assign result = result_reg;
    
    // Flags
    assign zero_flag = (result == 32'h0);
    assign negative_flag = result[31];
    assign overflow_flag = ((alu_control == ADD) && temp_add[32]) ||
                          ((alu_control == SUB) && temp_sub[32]) ||
                          ((alu_control == INC) && inc_cout) ||
                          ((alu_control == DEC) && dec_bout);

endmodule