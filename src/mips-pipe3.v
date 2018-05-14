// macro
`define MIPS-PIPE3_V 1

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


module CPU (clock,PC,IFID_IR,IDEX_IR,WD);

  input clock;
  output [15:0] PC,IFID_IR,IDEX_IR,WD;


  // Program with nop's - no hazards
  initial begin
    // addi $t1, $0,  15   ($t1=15) 16'h410F 
    IMemory[0]  = 16'b0100_00_01_00001111;  
    // addi $t2, $0,  7    ($t2= 7) 16'h4207
    IMemory[1]  = 16'b0100_00_10_00000111;  
    // nop 16'h0
    IMemory[2]  = 16'd0;  
    // and  $t3, $t1, $t2  ($t3= 7) 16'h29C0
    IMemory[3]  = 16'b0010_10_01_11_000000; 
    // nop 16'h0
    IMemory[4]  = 16'd0;  
    // sub  $t2, $t1, $t3  ($t2= 8) 16'h1780
    IMemory[5]  = 16'b0001_01_11_10_000000;  
    // nop 16'h0
    IMemory[6]  = 16'd0;  
    // or   $t2, $t2, $t3  ($t2=15) 16'h3E80
    IMemory[7]  = 16'b0011_11_10_10_000000;  
    // nop 16'h0
    IMemory[8]  = 16'd0;  
    // add  $t3, $t2, $t3  ($t3=22) 16'h0BC0
    IMemory[9]  = 16'b0000_10_11_11_000000;  
    // nop 16'h0
    IMemory[10] = 16'd0;  
    // slt  $t1, $t3, $t2  ($t1= 0) 16'h7E40
    IMemory[11] = 16'b0111_11_10_01_000000;  
    // slt  $t1, $t2, $t3  ($t1= 1) 16'h7B40
    IMemory[12] = 16'b0111_10_11_01_000000;  
  end

  //   // Program with nop's - no hazards
  // initial begin
  //   // addi $t1, $0,  15   ($t1=15) 16'h410F 
  //   IMemory[0]  = 16'b0100_00_01_00001111;  
  //   // addi $t2, $0,  7    ($t2= 7) 16'h4207
  //   IMemory[1]  = 16'b0100_00_10_00000111;  
  //   // and  $t3, $t1, $t2  ($t3= 7) 16'h29C0
  //   IMemory[3]  = 16'b0010_10_01_11_000000; 
  //   // sub  $t2, $t1, $t3  ($t2= 8) 16'h1780
  //   IMemory[5]  = 16'b0001_01_11_10_000000;  
  //   // or   $t2, $t2, $t3  ($t2=15) 16'h3E80
  //   IMemory[7]  = 16'b0011_11_10_10_000000;  
  //   // add  $t3, $t2, $t3  ($t3=22) 16'h0BC0
  //   IMemory[9]  = 16'b0000_10_11_11_000000;  
  //   // slt  $t1, $t3, $t2  ($t1= 0) 16'h7E40
  //   IMemory[11] = 16'b0111_11_10_01_000000;  
  //   // slt  $t1, $t2, $t3  ($t1= 1) 16'h7B40
  //   IMemory[12] = 16'b0111_10_11_01_000000;  
  // end



// Pipeline stages

//=== IF STAGE ===
  wire [15:0] NextPC;
  reg  [15:0] PC, IMemory[0:1023];
//--------------------------------
  reg  [15:0] IFID_IR;
//--------------------------------
  alu fetch (3'b010,PC,16'd2,NextPC,Unused);

//=== ID STAGE ===
  wire [9:0] Control;
  wire [15:0] RD1,RD2,SignExtend, WD;
  wire [1:0] WR;
//----------------------------------------------------
  reg [15:0] IDEX_IR; // For monitoring the pipeline
  reg IDEX_RegWrite,IDEX_ALUSrc,IDEX_RegDst;
  reg [2:0]  IDEX_ALUCon;
  reg [15:0] IDEX_RD1,IDEX_RD2,IDEX_SignExt;
  reg [1:0]  IDEX_rt,IDEX_rd;
  // Unused
  wire Zero;
  reg [1:0] Branch;
  reg IDEX_MemtoReg, IDEX_MemWrite;
//----------------------------------------------------
  // Register file
  reg_file rf (IFID_IR[11:10],IFID_IR[9:8],WR,WD,IDEX_RegWrite,RD1,RD2,clock);
  // Main Control
  MainControl MainCtr (IFID_IR[15:12],Control);
  // Sign Extend
  assign SignExtend = {{8{IFID_IR[7]}},IFID_IR[7:0]};

//=== EXE STAGE ===
  wire [15:0] B,ALUOut;
  reg [2:0] IDEX_ALUOp; // Pipeline of ALUOp[2:0]
  alu ex (IDEX_ALUOp, IDEX_RD1, B, ALUOut, Zero);
  // ALUSrc Mux
  mux2x1_16bit mux_exe0 (IDEX_RD2, IDEX_SignExt, IDEX_ALUSrc, B);
  // RegDst Mux
  mux2x1_2bit  mux_exe1 (IDEX_rt, IDEX_rd, IDEX_RegDst, WR);
  assign WD = ALUOut;

  // Initialize Program Counter as 0 to get the address of first instruction
  initial begin
    PC = 0;
  end

// Running the pipeline

  always @(negedge clock) begin

// Stage 1 - IF
  PC <= NextPC;
  IFID_IR <= IMemory[PC>>1];

// Stage 2 - ID
  IDEX_IR <= IFID_IR; // For monitoring the pipeline
  {IDEX_RegDst, IDEX_ALUSrc, IDEX_MemtoReg, IDEX_RegWrite, IDEX_MemWrite, Branch, IDEX_ALUOp} <= Control;
  IDEX_RD1 <= RD1;
  IDEX_RD2 <= RD2;
  IDEX_SignExt <= SignExtend;
  IDEX_rt <= IFID_IR[9:8];
  IDEX_rd <= IFID_IR[7:6];

// Stage 3 - EX
// No transfers needed here - on negedge WD is written into register WR

  end

endmodule
