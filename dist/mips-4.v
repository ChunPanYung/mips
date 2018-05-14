// DataPathProg3.v

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
   Sixteen_D_flip_flops r1 (wd,c1,q1), // $1
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
module Sixteen_D_flip_flops(D,CLK,Q);
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


// 2 to 1 multiplexer
module mux2x1(A,B,select,OUT);
   input A,B,select;
   output OUT;
   wire wX, wY, wZ;

   // level 1
   not not0(wX, select);

   // level 2
   and and0(wY, wX, A);
   and and1(wZ, select, B);

   // level 3
   or or0(OUT, wY, wZ);

   //reg OUT;
   //always @ (select or A or B)
         //if (select == 0) OUT = A;
         //else OUT = B;
endmodule

module mux2x1_2bit(A, B, select, OUT);
  input [1:0] A, B;
  input select;
  output [1:0] OUT;

  mux2x1 mux0(A[0], B[0], select, OUT[0]),
         mux1(A[1], B[1], select, OUT[1]);
endmodule

// 4-bit 2 to 1 multiplexer
module mux2x1_4bit(A, B, select, OUT);
   input [3:0] A, B;
   input select;
   output [3:0] OUT;

   // 2 to 1 multiplexer
   mux2x1 mux0(A[0], B[0], select, OUT[0]);
   mux2x1 mux1(A[1], B[1], select, OUT[1]);
   mux2x1 mux2(A[2], B[2], select, OUT[2]);
   mux2x1 mux3(A[3], B[3], select, OUT[3]);

endmodule //mux2x1_4bit 

// 16-bit 2 to 1 multiplexer
module mux2x1_16bit(A, B, select, OUT);
   input [15:0] A, B;
   input select;
   output [15:0] OUT;

   // 2 to 1 multiplexer
   mux2x1_4bit mux0(A[3:0],   B[3:0],   select, OUT[3:0]);
   mux2x1_4bit mux1(A[7:4],   B[7:4],   select, OUT[7:4]);
   mux2x1_4bit mux2(A[11:8],  B[11:8],  select, OUT[11:8]);
   mux2x1_4bit mux3(A[15:12], B[15:12], select, OUT[15:12]);

endmodule //mux2x1_4bit 

// 4 to 1 multiplexer
module mux4x1(i0,i1,i2,i3,select,y);
   input i0,i1,i2,i3;
   input [1:0] select;
   output y;
   wire InvertS0, InvertS1, wa, wb, wc, wd;

   // level 1
   not not0(InvertS0, select[0]);
   not not1(InvertS1, select[1]);

   // level 2
   and and0(wa, i0, InvertS1, InvertS0);
   and and1(wb, i1, InvertS1, select[0]);
   and and2(wc, i2, select[1], InvertS0);
   and and3(wd, i3, select[1], select[0]);

   // level 3
   or or0(y, wa, wb, wc, wd);

endmodule

// 4 bit 4x1 multiplexer implemented by using 4 4x1 1bit multiplexers
// for each bit.
module mux4x1_4bit(i0,i1,i2,i3,select,y); 
    input [3:0] i0,i1,i2,i3; // 4 bit input
    input [1:0] select; // 2 select inputs
    output [3:0] y; // 4 bit output

    //instantiate the 4x1 MUX
    mux4x1 mux0(i0[0],i1[0],i2[0],i3[0],select,y[0]), 
           mux1(i0[1],i1[1],i2[1],i3[1],select,y[1]), 
           mux2(i0[2],i1[2],i2[2],i3[2],select,y[2]), 
           mux3(i0[3],i1[3],i2[3],i3[3],select,y[3]); 

endmodule 

// 16 bit 4x1 multiplexer implemented by using 4 4-bit 4x1 multiplexers 
// for each 4 bits.
module mux4x1_16bit(i0,i1,i2,i3,select,y); 
    input [15:0] i0,i1,i2,i3; // 16 bit inputs
    input [1:0] select; // 2 select inputs
    output [15:0] y; // 16 bit outputs


    //instantiate the 4x1 MUX
    mux4x1_4bit mux0(i0[3:0],i1[3:0],i2[3:0],i3[3:0],select,y[3:0]), 
                mux1(i0[7:4],i1[7:4],i2[7:4],i3[7:4],select,y[7:4]), 
                mux2(i0[11:8],i1[11:8],i2[11:8],i3[11:8],select,y[11:8]), 
                mux3(i0[15:12],i1[15:12],i2[15:12],i3[15:12],select,y[15:12]);
endmodule 

// Input [15:12] of instruction
// Output 10 bits: RegDst, ALUsrc, MemtoReg, RegWrite, MemWrite, Branch[1:0], ALUControl[2:0]
module MainControl (Op,Control); 

  input [3:0] Op;
  output reg [9:0] Control;

  always @(Op) case (Op)
    4'b0000: Control <= 10'b1001000010; // ADD
    4'b0001: Control <= 10'b1001000110; // SUB
    4'b0010: Control <= 10'b1001000000; // AND
    4'b0011: Control <= 10'b1001000001; // OR
    4'b0100: Control <= 10'b0101000010; // ADDI
    4'b0111: Control <= 10'b1001000111; // SLT
    4'b1000: Control <= 10'b0000010110; // BEQ
    4'b1001: Control <= 10'b0000001110; // BNE
    4'b0101: Control <= 10'b0111000010; // LW
    4'b0110: Control <= 10'b0100100010; // SW
  endcase

endmodule

module BranchControl(BRANCH,ZERO,OUT);
  input [1:0] BRANCH;
  input ZERO;
  output OUT;
  wire one, two, nzero;
    not n1(nzero, ZERO);
    and a1(one,ZERO,BRANCH[1]),
        a2(two,BRANCH[0],nzero);
    or  o1(OUT,one,two);
endmodule

module CPU (clock,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);
  reg [1:0] EXMEM_Branch;
  reg EXMEM_Zero;
  reg [15:0] EXMEM_Target,EXMEM_ALUOut,EXMEM_RD2;
  reg MEMWB_RegWrite,MEMWB_MemtoReg;
  reg [1:0] MEMWB_rd;
  input clock;
  output [15:0] PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD;

  initial begin 
   // Program: swap memory cells (if needed) and compute absolute value |5-7|=2
   IMemory[0]  = 16'b0101_00_01_00000000;  // lw $1, 0($0)
   IMemory[1]  = 16'b0101_00_10_00000010;  // lw $2, 4($0)
   IMemory[2]  = 16'd0;  // nop
   IMemory[3]  = 16'd0;  // nop
   IMemory[4]  = 16'd0;  // nop
   IMemory[5]  = 16'b0111_01_10_11_000000;  // slt $3, $1, $2
   IMemory[6]  = 16'd0;  // nop
   IMemory[7]  = 16'd0;  // nop
   IMemory[8]  = 16'd0;  // nop
   IMemory[9]  = 16'b1000_11_00_00000101;  // beq $3, $0, IMemory[15]  
   IMemory[10] = 16'd0;  // nop
   IMemory[11] = 16'd0;  // nop
   IMemory[12] = 16'd0;  // nop
   IMemory[13] = 16'b0110_00_01_00000010;  // sw $1, 2($0)
   IMemory[14] = 16'b0110_00_10_00000000;  // sw $2, 0($0)
   IMemory[15] = 16'd0;  // nop
   IMemory[16] = 16'd0;  // nop
   IMemory[17] = 16'd0;  // nop
   IMemory[18] = 16'b0101_00_01_00000000;  // lw $1, 0($0)
   IMemory[19] = 16'b0101_00_10_00000010;  // lw $2, 2($0)
   IMemory[20] = 16'd0;  // nop
   IMemory[21] = 16'd0;  // nop
   IMemory[22] = 16'd0;  // nop
   IMemory[23] = 16'b0001_01_10_11_000000;  // sub $3, $1, $2
// Data
   DMemory [0] = 16'h5; // switch the cells and see how the simulation output changes
   DMemory [1] = 16'h7; // (beq is taken if [0]=16'h7; [1]=16'h5, not taken otherwise)
  end
  
  /* other test for the rest of the operations. If bne not taken, result is 22; if taken, or is skipped and 15 is result.
initial begin   
    IMemory[0]   = 16'b0100_00_01_00001111;  // addi $1, $0,  15   ($t1=15) 16'h410F  
    IMemory[1]   = 16'b0100_00_10_00000111;  // addi $2, $0,  7    ($t2= 7) 16'h4207 
    IMemory[2]   = 16'd0;  					 // nop
    IMemory[3]   = 16'd0;  					 // nop
    IMemory[4]   = 16'd0;  					 // nop
    IMemory[5]   = 16'b0010_10_01_11_000000; // and  $3, $1, $2  ($3= 7) 16'h29C0
    IMemory[6]   = 16'd0;  					 // nop
    IMemory[7]   = 16'd0;  					 // nop
    IMemory[8]   = 16'd0;  					 // nop                  
    IMemory[9]   = 16'b0001_01_11_10_000000; // sub  $2, $1, $3  ($2= 8) 16'h1780  
    IMemory[10]  = 16'd0;  					 // nop
    IMemory[11]  = 16'd0;  					 // nop
    IMemory[12]  = 16'd0;  					 // nop                    
	IMemory[13]  = 16'b1001_11_00_00000110;  // bne $3, $0, 7 = (branch on not equal) 26+2+(7*2) == PC 42
    IMemory[14]  = 16'd0;  					 // nop
    IMemory[15]  = 16'd0;  					 // nop	
	IMemory[16]  = 16'd0;  					 // nop
    IMemory[17]  = 16'b0011_11_10_10_000000; // or   $2, $2, $3  ($2=15) 16'h3E80 
    IMemory[18]  = 16'd0;  					 // nop
    IMemory[19]  = 16'd0;  					 // nop
    IMemory[20]  = 16'd0;  					 // nop                   // nop 16'h0
    IMemory[21]  = 16'b0000_10_11_11_000000; // add  $3, $2, $3  ($3=22 or 15 if bne taken) 16'h0BC0 
    IMemory[22]  = 16'd0;  					 // nop
    IMemory[23]  = 16'd0;  					 // nop
    IMemory[24]  = 16'd0;  					 // nop                    
    IMemory[25]  = 16'b0111_11_10_01_000000; // slt  $1, $3, $2  ($1= 0) 16'h7E40 
    IMemory[26]  = 16'b0111_10_11_01_000000; // slt  $1, $2, $3  ($1= 1) 16'h7B40
end
*/

// Pipeline 

// IF 
   wire [15:0] PCplus2, NextPC;
   reg[15:0] PC, IMemory[0:1023], IFID_IR, IFID_PCplus2;
   alu fetch (3'b010,PC,16'd2,PCplus2,Unused1);
   BranchControl branchCtrl(EXMEM_Branch,EXMEM_Zero,BranchSelect);
   mux2x1_16bit BranchMux(PCplus2,EXMEM_Target,BranchSelect,NextPC); // Branch ALU multiplexer;

// ID
   wire [9:0] Control;
   reg IDEX_RegWrite,IDEX_MemtoReg,
       IDEX_MemWrite,IDEX_ALUSrc,
       IDEX_RegDst;
   reg[1:0] IDEX_Branch;
   reg [2:0]  IDEX_ALUOp;
   wire [15:0] RD1,RD2,SignExtend,WD;
   reg [15:0] IDEX_PCplus2,IDEX_RD1,IDEX_RD2,IDEX_SignExt,IDEXE_IR;
   reg [15:0] IDEX_IR; // For monitoring the pipeline
   reg [1:0]  IDEX_rt,IDEX_rd;
   reg_file rf (IFID_IR[11:10],IFID_IR[9:8],MEMWB_rd,WD,MEMWB_RegWrite,RD1,RD2,clock);
   MainControl MainCtr (IFID_IR[15:12],Control); 
   assign SignExtend = {{8{IFID_IR[7]}},IFID_IR[7:0]}; 
  
// EXE
   reg EXMEM_RegWrite,EXMEM_MemtoReg,
       EXMEM_MemWrite;
   wire [15:0] Target;
   reg [15:0] EXMEM_IR; // For monitoring the pipeline
   reg [1:0] EXMEM_rd;
   wire [15:0] B,ALUOut;
   //wire [2:0] ALUctl;
   wire [1:0] WR;
   alu branch (3'b010,IDEX_SignExt<<1,IDEX_PCplus2,Target,Unused2);
   alu ex (IDEX_ALUOp, IDEX_RD1, B, ALUOut, Zero);
   mux2x1_16bit mux_exe0 (IDEX_RD2, IDEX_SignExt, IDEX_ALUSrc, B); // ALUSrc Mux
   mux2x1_2bit  mux_exe1 (IDEX_rt, IDEX_rd, IDEX_RegDst, WR); // RegDst Mux 

// MEM
   reg [15:0] DMemory[0:1023],MEMWB_MemOut,MEMWB_ALUOut;
   reg [15:0] MEMWB_IR; // For monitoring the pipeline
   wire [15:0] MemOut;
   assign MemOut = DMemory[EXMEM_ALUOut>>1];
   always @(negedge clock) if (EXMEM_MemWrite) DMemory[EXMEM_ALUOut>>1] <= EXMEM_RD2;
  
// WB
   mux2x1_16bit DMemMux(MEMWB_ALUOut, MEMWB_MemOut, MEMWB_MemtoReg, WD); // MemtoReg Mux


   initial begin
    PC = 0;
// Initialize pipeline registers
    IDEX_RegWrite=0;IDEX_MemtoReg=0;IDEX_Branch=0;IDEX_MemWrite=0;IDEX_ALUSrc=0;IDEX_RegDst=0;IDEX_ALUOp=0;
    IFID_IR=0;
    EXMEM_RegWrite=0;EXMEM_MemtoReg=0;EXMEM_Branch=0;EXMEM_MemWrite=0;
    EXMEM_Target=0;
    MEMWB_RegWrite=0;MEMWB_MemtoReg=0;
   end

// Running the pipeline

   always @(negedge clock) begin 

// IF
    PC <= NextPC;
    IFID_PCplus2 <= PCplus2;
    IFID_IR <= IMemory[PC>>1];

// ID
    IDEX_IR <= IFID_IR; // For monitoring the pipeline
    {IDEX_RegDst,IDEX_ALUSrc,IDEX_MemtoReg,IDEX_RegWrite,IDEX_MemWrite,IDEX_Branch,IDEX_ALUOp} <= Control; 
    IDEX_PCplus2 <= IFID_PCplus2;
    IDEX_RD1 <= RD1; 
    IDEX_RD2 <= RD2;
    IDEX_SignExt <= SignExtend;
    IDEX_rt <= IFID_IR[9:8];
    IDEX_rd <= IFID_IR[7:6];

// EXE
    EXMEM_IR <= IDEX_IR; // For monitoring the pipeline
    EXMEM_RegWrite <= IDEX_RegWrite;
    EXMEM_MemtoReg <= IDEX_MemtoReg;
    EXMEM_Branch   <= IDEX_Branch;
    EXMEM_MemWrite <= IDEX_MemWrite;
    EXMEM_Target <= Target;
    EXMEM_Zero <= Zero;
    EXMEM_ALUOut <= ALUOut;
    EXMEM_RD2 <= IDEX_RD2;
    EXMEM_rd <= WR;

// MEM
    MEMWB_IR <= EXMEM_IR; // For monitoring the pipeline
    MEMWB_RegWrite <= EXMEM_RegWrite;
    MEMWB_MemtoReg <= EXMEM_MemtoReg;
    MEMWB_MemOut <= MemOut;
    MEMWB_ALUOut <= EXMEM_ALUOut;
    MEMWB_rd <= EXMEM_rd;

// WB
// Register write happens on neg edge of the clock (if MEMWB_RegWrite is asserted)

  end

endmodule


// Test module

module test ();

  reg clock;
  wire [15:0] PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD;

  CPU test_cpu(clock,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);

  always #1 clock = ~clock;
  
  initial begin
    $display ("time PC  IFID_IR  IDEX_IR  EXMEM_IR MEMWB_IR WD");
    $monitor ("%2d  %3d  %h     %h     %h     %h     %d", $time,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);
    clock = 1;
    #56 $finish;
  end

endmodule