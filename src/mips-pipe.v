// Behavioral model of MIPS - pipelined implementation

// macro
`define MIPS-PIPE_V 1

// include if it's not included before
`ifndef ALU16_V
  `include "ALU16.v"
`endif

// Include if it's not include before
`ifndef REGFILE_V
  `include "regfile.v"
`endif

// Include if it's not included before
`ifndef CONTROL_V
  `include "control.v"
`endif

// CPU
module CPU (clock,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);

  input clock;
  output [15:0] PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD;

  initial begin 
// Program: swap memory cells (if needed) and compute absolute value |5-7|=2
   IMemory[0]  = 16'0101  // lw $1, 0($0)
   IMemory[1]  = 16'h8c090004;  // lw $2, 2($0)
   IMemory[2]  = 16'h00000000;  // nop
   IMemory[3]  = 16'h00000000;  // nop
   IMemory[4]  = 16'h00000000;  // nop
   IMemory[5]  = 16'h0109502a;  // slt $3, $1, $2
   IMemory[6]  = 16'h00000000;  // nop
   IMemory[7]  = 16'h00000000;  // nop
   IMemory[8]  = 16'h00000000;  // nop
   IMemory[9]  = 16'h11400005;  // beq $3, $0, IMemory[15]  
   IMemory[10] = 16'h00000000;  // nop
   IMemory[11] = 16'h00000000;  // nop
   IMemory[12] = 16'h00000000;  // nop
   IMemory[13] = 16'hac080004;  // sw $1, 2($0)
   IMemory[14] = 16'hac090000;  // sw $2, 0($0)
   IMemory[15] = 16'h00000000;  // nop
   IMemory[16] = 16'h00000000;  // nop
   IMemory[17] = 16'h00000000;  // nop
   IMemory[18] = 16'h8c080000;  // lw $1, 0($0)
   IMemory[19] = 16'h8c090004;  // lw $2, 2($0)
   IMemory[20] = 16'h00000000;  // nop
   IMemory[21] = 16'h00000000;  // nop
   IMemory[22] = 16'h00000000;  // nop
   IMemory[23] = 16'h01095022;  // sub $3, $1, $2
// Data
   DMemory [0] = 16'h5; // switch the cells and see how the simulation output changes
   DMemory [1] = 16'h7; // (beq is taken if [0]=16'h7; [1]=16'h5, not taken otherwise)
  end

// Pipeline 

// IF 
   wire [15:0] PCplus, NextPC;
   wire Branch;
   reg[15:0] PC, IMemory[0:1023], IFID_IR, IFID_PCplus;
   alu fetch (3'b010,PC,16'd2,PCplus,Unused1);
   mux2x1_16bit mux0 (PCplus, EXMEM_Target, Branch, NextPC);

// ID
   wire [9:0] Control;
   reg IDEX_RegWrite,IDEX_MemtoReg,
       IDEX_Branch,  IDEX_MemWrite,
       IDEX_ALUSrc,  IDEX_RegDst;
   reg [1:0]  IDEX_ALUOp;
   wire [15:0] RD1,RD2,SignExtend, WD;
   reg [15:0] IDEX_PCplus,IDEX_RD1,IDEX_RD2,IDEX_SignExt,IDEXE_IR;
   reg [15:0] IDEX_IR; // For monitoring the pipeline
   reg [4:0]  IDEX_rt,IDEX_rd;
   reg_file rf (IFID_IR[11:10],IFID_IR[9:8],MEMWB_rd,WD,MEMWB_RegWrite,RD1,RD2,clock);
   MainControl MainCtr (IFID_IR[15:12],Control); 
   assign SignExtend = {{8{IFID_IR[7]}},IFID_IR[7:0]}; 
  
// EXE
   reg EXMEM_RegWrite,EXMEM_MemtoReg,
       EXMEM_Branch,  EXMEM_MemWrite;
   wire [15:0] Target;
   reg EXMEM_Zero;
   reg [15:0] EXMEM_Target,EXMEM_ALUOut,EXMEM_RD2;
   reg [15:0] EXMEM_IR; // For monitoring the pipeline
   reg [4:0] EXMEM_rd;
   wire [15:0] B,ALUOut;
   wire [2:0] ALUctl;
   wire [4:0] WR;
   alu branch (3'b010,IDEX_SignExt<<2,IDEX_PCplus,Target,Unused2);
   alu ex (ALUctl, IDEX_RD1, B, ALUOut, Zero);
   ALUControl ALUCtrl(IDEX_ALUOp, IDEX_SignExt[5:0], ALUctl); // ALU control unit
   assign B  = (IDEX_ALUSrc) ? IDEX_SignExt: IDEX_RD2;        // ALUSrc Mux 
   assign WR = (IDEX_RegDst) ? IDEX_rd: IDEX_rt;              // RegDst Mux

// MEM
   reg MEMWB_RegWrite,MEMWB_MemtoReg;
   reg [15:0] DMemory[0:1023],MEMWB_MemOut,MEMWB_ALUOut;
   reg [15:0] MEMWB_IR; // For monitoring the pipeline
   wire [15:0] MemOut;
   reg [4:0] MEMWB_rd;
   assign MemOut = DMemory[EXMEM_ALUOut>>2];
   always @(negedge clock) if (EXMEM_MemWrite) DMemory[EXMEM_ALUOut>>2] <= EXMEM_RD2;
  
// WB
   assign WD = (MEMWB_MemtoReg) ? MEMWB_MemOut: MEMWB_ALUOut; // MemtoReg Mux


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
    IFID_PCplus <= PCplus;
    IFID_IR <= IMemory[PC>>2];

// ID
    IDEX_IR <= IFID_IR; // For monitoring the pipeline
    {IDEX_RegDst,IDEX_ALUSrc,IDEX_MemtoReg,IDEX_RegWrite,IDEX_MemWrite,IDEX_Branch,IDEX_ALUOp} <= Control;   
    IDEX_PCplus <= IFID_PCplus;
    IDEX_RD1 <= RD1; 
    IDEX_RD2 <= RD2;
    IDEX_SignExt <= SignExtend;
    IDEX_rt <= IFID_IR[20:16];
    IDEX_rd <= IFID_IR[15:11];

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
    $monitor ("%2d  %3d  %h %h %h %h %h", $time,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);
    clock = 1;
    #56 $finish;
  end

endmodule


/* Compiling and simulation

C:\Markov\CCSU Stuff\Courses\Spring-10\CS385\HDL>iverilog mips-pipe.vl

C:\Markov\CCSU Stuff\Courses\Spring-10\CS385\HDL>vvp a.out

time PC  IFID_IR  IDEX_IR  EXMEM_IR MEMWB_IR WD
 0    0  00000000 xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx
 1    4  8c080000 00000000 xxxxxxxx xxxxxxxx xxxxxxxx
 3    8  8c090004 8c080000 00000000 xxxxxxxx xxxxxxxx
 5   12  00000000 8c090004 8c080000 00000000 00000000
 7   16  00000000 00000000 8c090004 8c080000 00000005
 9   20  00000000 00000000 00000000 8c090004 00000007
11   24  0109502a 00000000 00000000 00000000 00000000
13   28  00000000 0109502a 00000000 00000000 00000000
15   32  00000000 00000000 0109502a 00000000 00000000
17   36  00000000 00000000 00000000 0109502a 00000001
19   40  11400005 00000000 00000000 00000000 00000000
21   44  00000000 11400005 00000000 00000000 00000000
23   48  00000000 00000000 11400005 00000000 00000000
25   52  00000000 00000000 00000000 11400005 00000001
27   56  ac080004 00000000 00000000 00000000 00000000
29   60  ac090000 ac080004 00000000 00000000 00000000
32   64  00000000 ac090000 ac080004 00000000 00000000
33   68  00000000 00000000 ac090000 ac080004 00000004
35   72  00000000 00000000 00000000 ac090000 00000000
37   76  8c0b0000 00000000 00000000 00000000 00000000
39   80  8c0c0004 8c0b0000 00000000 00000000 00000000
41   84  00000000 8c0c0004 8c0b0000 00000000 00000000
43   88  00000000 00000000 8c0c0004 8c0b0000 00000007
45   92  00000000 00000000 00000000 8c0c0004 00000005
47   96  016c5822 00000000 00000000 00000000 00000000
49  100  xxxxxxxx 016c5822 00000000 00000000 00000000
51  104  xxxxxxxx xxxxxxxx 016c5822 00000000 00000000
53  108  xxxxxxxx xxxxxxxx xxxxxxxx 016c5822 00000002
55  112  xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx 0000000X

*/
