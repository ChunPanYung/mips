// macro
`define ALU16_V 1

// include if it's not included before
`ifndef ALU4_V
   `include "ALU4.v"
`endif

// main module: 16-bit ALU
// The paremeter has been modified to match with the one in "mips-r-type_addi.v":
// module alu (ALUctl, A, B, ALUOut, Zero);
//
// Although name is different, and underlining structure is same
module alu (op, a, b, sum, zero);
   // input
	 input [15:0] a, b;
	 input [2:0] op;
	 // output
	 output [15:0] sum;
	 output zero;
   // wire
	 wire set, wa, wb, wc, wd, c0, c1, c2;
	 // wire: ignored these output
	 wire ign[4:0];

	 ALU4Combo alu0(sum[3:0],   wa, ign[0], c0,     op, op[2], set,  a[3:0],   b[3:0]);
	 ALU4Combo alu1(sum[7:4],   wb, ign[2], c1,     op, c0,    1'b0, a[7:4],   b[7:4]);
	 ALU4Combo alu2(sum[11:8],  wc, ign[3], c2,     op, c1,    1'b0, a[11:8],  b[11:8]);
	 ALU4Combo alu3(sum[15:12], wd, set,    ign[4], op, c2,    1'b0, a[15:12], b[15:12]);

   // level 2
	 nor nor0(zero, wa, wb, wc, wd);

endmodule //alu



// This 4bitALU is designed for combo into 4x bits ALU
// it can't be used alone.
module ALU4Combo (result, zero, sum, carryOut, op, carryIn, less, a, b);
   // input
   input [3:0] a, b;
	 input [2:0] op;
	 input carryIn, less;
   // output
	 output [3:0] result;
	 output carryOut, sum, zero;
	 // wire
	 wire c1, c2, c3, c4, or01, or23;

	 ALU1   alu0 (a[0],b[0],op[2],op[1:0],less,carryIn,c1,result[0]);
	 ALU1   alu1 (a[1],b[1],op[2],op[1:0],1'b0,c1,     c2,result[1]);
	 ALU1   alu2 (a[2],b[2],op[2],op[1:0],1'b0,c2,     c3,result[2]);
	 ALUmsb alu3 (a[3],b[3],op[2],op[1:0],1'b0,c3,     carryOut,result[3],sum);

	 or or0(or01, result[0],result[1]);
	 or or1(or23, result[2],result[3]);
	 or or2(zero,or01,or23);

endmodule //4bitALU

