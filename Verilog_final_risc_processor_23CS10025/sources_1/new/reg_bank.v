module reg_bank (
    input  wire        clk,
    input  wire        reset,
    input  wire        wrReg,           // write enable
    input  wire        isCall,          //update the ra if isCall
    input  wire [3:0]  rs, rt, rd,      // 4-bit addresses (R0..R15)
    input  wire [3:0]   resultRegInp,      //surface to top module
    input  wire [31:0] rdIn,            // data to be written
    output wire [31:0] rsOut,
    output wire [31:0] rtOut,
    output wire [31:0]  resultRegOut
);
    reg [31:0] ra;
    // 16 registers
    reg [31:0] registers [0:15];
    integer i;
    always @(posedge clk or posedge reset) begin
//        $display(wrReg);
        if (reset) begin
            // Initialize registers
            registers[0]  <= 32'h0000_0000;        // R0 always zero
            registers[1]  <= 32'h0000_0000;
            registers[2]  <= 32'h0000_0000;
            registers[3]  <= 32'h0000_0000;
            registers[4]  <= 32'h0000_0000;
            registers[5]  <= 32'h0000_0000;
            registers[6]  <= 32'h0000_0000;
            registers[7]  <= 32'h0000_0000;
            registers[8]  <= 32'h0000_0000;
            registers[9]  <= 32'h0000_0000;
            registers[10] <= 32'h0000_0000;
            registers[11] <= 32'h0000_0000;
            registers[12] <= 32'h0000_0000;
            registers[13] <= 32'h0000_0000;
            registers[14] <= 32'h0000_0000;
            registers[15] <= 32'h0000_0000;
        end else if (wrReg) begin 
            if(isCall == 1'b1) begin
                ra = rdIn;
                $display( " ----Call called %h", ra);
            end       
            else if (rd == 4'h0) begin
//                $display("RD is zero reg");
                registers[0]  = 32'h0; 
            end
            else begin
                //$display(" ----------RDin is  : %d ",rdIn);
                registers[rd] = rdIn;
                $display(" ----------updated register : %d to value %h",rd, registers[rd]);
            end
        end
    end
    assign rsOut = (rs == 4'h0) ? 32'h0 : registers[rs];
    assign rtOut = (rt == 4'h0) ? 32'h0 : registers[rt];
    assign resultRegOut = registers[resultRegInp];
endmodule
