`timescale 1ns / 1ps

module half_adder(input in1, input in2, output out , output cout );

xor g1(out, in1, in2);     // Out = A ^ B
and g2(cout,in1, in2);        //  cout = A & B

endmodule
