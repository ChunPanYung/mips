// Behavioral model of MIPS - pipelined implementation with forwarding unit

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

// Include if it's not included before
`ifndef FORWARDING_V
  `include "forwarding.v"
`endif






module CPU (clock,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);
  reg [1:0] EXMEM_Branch;
  reg EXMEM_Zero;
  reg [15:0] EXMEM_Target,EXMEM_ALUOut,EXMEM_RD2;
  reg MEMWB_RegWrite,MEMWB_MemtoReg;
  reg [1:0] MEMWB_rd;
  wire [15:0] Awire, Bwire;
  input clock;
  output [15:0] PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD;

  initial begin 
    // addi $t1, $0,  15   ($t1=15) 16'h410F 
    IMemory[0]  = 16'b0100_00_01_00001111;  
    // addi $t2, $0,  7    ($t2= 7) 16'h4207
    IMemory[1]  = 16'b0100_00_10_00000111;  
    // nop 16'h0
    //IMemory[2]  = 16'd0;  
    // and  $t3, $t1, $t2  ($t3= 7) 16'h29C0
    IMemory[3]  = 16'b0010_10_01_11_000000; 
    // nop 16'h0
    IMemory[4]  = 16'd0;  
    // sub  $t2, $t1, $t3  ($t2= 8) 16'h1780
    IMemory[5]  = 16'b0001_01_11_10_000000;  
    // nop 16'h0
    IMemory[6]  = 16'd0;  
    // or   $t2, $t2, $t3  ($t2=8) 16'h3E80
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
   reg [1:0]  IDEX_rt,IDEX_rd,IDEX_rs;
   reg_file rf (IFID_IR[11:10],IFID_IR[9:8],MEMWB_rd,WD,MEMWB_RegWrite,RD1,RD2,clock);
   MainControl MainCtr (IFID_IR[15:12],Control); 
   assign SignExtend = {{8{IFID_IR[7]}},IFID_IR[7:0]}; 
  
// EXE
   reg EXMEM_RegWrite,EXMEM_MemtoReg,
       EXMEM_MemWrite;
   wire [15:0] Target;
   reg [15:0] EXMEM_IR; // For monitoring the pipeline
   reg [1:0] EXMEM_rd;
   wire [1:0] fwdSelect1, fwdSelect2;
   wire [15:0] B,ALUOut;
   //wire [2:0] ALUctl;
   wire [1:0] WR;
   alu branch (3'b010,IDEX_SignExt<<1,IDEX_PCplus2,Target,Unused2);
	 // Forwarding Unit
   ForwardingUnit FU(IDEX_rs, IDEX_rt, EXMEM_rd, MEMWB_rd, EXMEM_RegWrite, MEMWB_RegWrite, fwdSelect1, fwdSelect2);
	 // Multiplexer for Forwarding Unit
   mux4x1_16bit mux_FA(IDEX_RD1, WD, EXMEM_ALUOut, 16'b0, fwdSelect1, Awire),  //forwarding multiplexer A
                mux_FB(B, WD, EXMEM_ALUOut, 16'b0, fwdSelect2, Bwire);         //forwarding multiplexer B
   alu ex (IDEX_ALUOp, Awire, Bwire, ALUOut, Zero);
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
    IDEX_rs <= IFID_IR[11:10];
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