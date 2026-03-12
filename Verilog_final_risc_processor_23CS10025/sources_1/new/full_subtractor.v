`timescale 1ns / 1ps
module full_subtractor(
    input wire a, b, bin,
    output wire d, bout
    );
    
    wire t1,t2,t3,t4,t5;

    xor g1(t1,a,b);     // t1 = a^b
    xor g2(d,bin,t1);   // d = bin^a^b
    not g3(t2,a);       // t2 = ~a
    and g4(t3,t2,b);    // t3 = (~a)&b
    not g5(t4,t1);      // t4 = ~(a^b)
    and g6(t5,t4,bin);  // t5 = ~(a^b)&bin
    or g7(bout,t3,t5);  // bout = ((~a)&b) | (~(a^b)&bin)
    
endmodule