// macro
`define ALU4_V 1

// include if it's not included before (according to global constant
// for that file)
`ifndef MULTIPLEXER_V
   `include "multiplexer.v"
`endif


// 4-bit MIPS ALU in Verilog

module ALU (op,a,b,result,zero);
   input [3:0] a;
   input [3:0] b;
   input [2:0] op;
   output [3:0] result;
   output zero;
   wire c1,c2,c3,c4, set, or01, or23;

   ALU1   alu0 (a[0],b[0],op[2],op[1:0],set,   op[2],c1,result[0]);
   ALU1   alu1 (a[1],b[1],op[2],op[1:0],1'b0,  c1,   c2,result[1]);
   ALU1   alu2 (a[2],b[2],op[2],op[1:0],1'b0,  c2,   c3,result[2]);
   ALUmsb alu3 (a[3],b[3],op[2],op[1:0],1'b0,  c3,   c4,result[3],set);

   or or1(or01, result[0],result[1]);
   or or2(or23, result[2],result[3]);
   nor nor1(zero,or01,or23);

endmodule


// 1-bit ALU for bits 0-2

module ALU1 (a,b,binvert,op,less,carryin,carryout,result);
   input a,b,less,carryin,binvert;
   input [1:0] op;
   output carryout,result;
   wire sum, a_and_b, a_or_b, b_inv, b1;

   not not1(b_inv, b);
   mux2x1 mux1(b,b_inv,binvert,b1);
   and and1(a_and_b, a, b);
   or or1(a_or_b, a, b);
   fulladder adder1(sum,carryout,a,b1,carryin);
   mux4x1 mux2(a_and_b,a_or_b,sum,less,op[1:0],result);

endmodule


// 1-bit ALU for the most significant bit

module ALUmsb (a,b,binvert,op,less,carryin,carryout,result,sum);
   input a,b,less,carryin,binvert;
   input [1:0] op;
   output carryout,result,sum;
   wire sum, a_and_b, a_or_b, b_inv, b1;

   not not1(b_inv, b);
   mux2x1 mux1(b,b_inv,binvert,b1);
   and and1(a_and_b, a, b);
   or or1(a_or_b, a, b);
   fulladder adder1(sum,carryout,a,b1,carryin);
   mux4x1 mux2(a_and_b,a_or_b,sum,less,op[1:0],result);

endmodule


module halfadder (S,C,x,y);
   input x,y;
   output S,C;

   xor (S,x,y);
   and (C,x,y);
endmodule


module fulladder (S,C,x,y,z);
   input x,y,z;
   output S,C;
   wire S1,D1,D2;

   halfadder HA1 (S1,D1,x,y),
             HA2 (S,D2,S1,z);
   or g1(C,D2,D1);
endmodule
