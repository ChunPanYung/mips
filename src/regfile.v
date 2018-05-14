// macro
`define REGFILE_V 1

// include if not define
`ifndef MULTIPLEXER_V
   `include "multiplexer.v"
`endif


// Simplified version of MIPS register file (4 registers, 1-bit data)

// For the project MIPS (4-registers, 16-bit data):
//  1. Change the D flip-flops with 16-bit registers
//  2. Redesign mux4x1 using gate-level modeling


// main module: regfile
// The paremeter has been modified to match with the one in "mips-r-type_addi.v":
// module reg_file (RR1,RR2,WR,WD,RegWrite,RD1,RD2,clock);
//
// Although name is different, and underlining structure is same
module reg_file (rr1,rr2,wr,wd,regwrite,rd1,rd2,clock);

	 // input
   input [1:0] rr1,rr2,wr;
   input [15:0] wd; 
   input regwrite,clock;
	 // output
   output [15:0] rd1,rd2; 
	 // wire
	 wire w0, w1, w2, w3, 
	      c1, c2, c3, 
				regwrite_and_clock;
	 wire [15:0] q1, q2, q3;


   // level 1
   decoder dec(wr[1],wr[0],w3,w2,w1,w0);
   and a0 (regwrite_and_clock,regwrite,clock);

   // level 2
   and a1 (c1,regwrite_and_clock,w1),
       a2 (c2,regwrite_and_clock,w2),
       a3 (c3,regwrite_and_clock,w3);

	 // level 3
   reg_16bit r1 (wd,c1,q1), // $1
             r2 (wd,c2,q2), // $2
             r3 (wd,c3,q3); // $3

   // level 4
   // changed to 16 bit 4x1 multiplexer instantiation. Stack 2 for rr1/rd1, 
	 // and rr2,rd2.
   mux4x1_16bit mux1 (16'b0,q1,q2,q3,rr1,rd1),
                mux2 (16'b0,q1,q2,q3,rr2,rd2);

endmodule


// Components

// 16-bit register 
module reg_16bit(D,CLK,Q);
  input[15:0] D; // 16 bit input
  input CLK; // clock
  output[15:0] Q; // 16 bit output
  // Instantiate 16 D_flip_flops here. (hierarchically for each bit)
  D_flip_flop D1(D[0],CLK,Q[0]),
              D2(D[1],CLK,Q[1]),
              D3(D[2],CLK,Q[2]),
              D4(D[3],CLK,Q[3]),
              D5(D[4],CLK,Q[4]),
              D6(D[5],CLK,Q[5]),
              D7(D[6],CLK,Q[6]),
              D8(D[7],CLK,Q[7]),
              D9(D[8],CLK,Q[8]),
              D10(D[9],CLK,Q[9]),
              D11(D[10],CLK,Q[10]),
              D12(D[11],CLK,Q[11]),
              D13(D[12],CLK,Q[12]),
              D14(D[13],CLK,Q[13]),
              D15(D[14],CLK,Q[14]),
              D16(D[15],CLK,Q[15]);
endmodule

module D_flip_flop(D,CLK,Q);
   input D,CLK; 
   output Q; 
   wire CLK1, Y; 
   not  not1 (CLK1,CLK);
   D_latch D1(D,CLK, Y),
           D2(Y,CLK1,Q);
endmodule 

module D_latch(D,C,Q);
   input D,C; 
   output Q;
   wire x,y,D1,Q1; 
   nand nand1 (x,D, C), 
        nand2 (y,D1,C), 
        nand3 (Q,x,Q1),
        nand4 (Q1,y,Q); 
   not  not1  (D1,D);
endmodule 

// 2 to 4 decoder
module decoder (S1,S0,D3,D2,D1,D0); 
   input S0,S1; 
   output D0,D1,D2,D3; 
 
   not n1 (notS0,S0),
       n2 (notS1,S1);

   and a0 (D0,notS1,notS0), 
       a1 (D1,notS1,   S0), 
       a2 (D2,   S1,notS0), 
       a3 (D3,   S1,   S0); 
endmodule 
