// macro
`define MIPS-SIMPLE_V 1

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



// Main CPU: contains instruction, Sign Extender,
// 2 multiplexer, MainControl (also serve as ALU Control)
module CPU (clock,WD,IR,PC);

  // Input
  input clock;
  // Output
  output [15:0] WD ,IR, PC;
  // Program Counter
  reg [15:0] PC;
  // Instruction Memory
  reg[15:0] IMemory[0:512];
  // Data Memory
  reg[15:0] DMemory[0:512];


  wire [15:0] IR,ALUOut,RD2,SignExtend,Target;
  // Unused Wire
  wire Unused[1:0];

  // Test Program:
  initial begin
	
	// For Diagram, we need to put:
	// DMemory [0] = 16'h5;
  //  DMemory [1] = 16'h7;
	// Using addi and sw:
	// addi $1, $0, 5 (4105)
	// addi $2, $0, 7 (4207)
	// sw $1, 0($0)   (6100)
	// sw $2, 2($0)   (6202)

  // Program: swap memory cells and compute absolute value
    IMemory[0] = 16'b0101_00_01_00000000;  // lw $1, 0($0) = 5 (5200)
    IMemory[1] = 16'b0101_00_10_00000010;  // lw $2, 2($0) = 7 (5202)
    IMemory[2] = 16'b0111_01_10_11_000000; // slt $3, $1, $2 = (set on less than if true) (76C0)
    IMemory[3] = 16'b1000_01_00_00000001;  // beq $3, $0, 1 = (branch on equal) (8401)
    IMemory[4] = 16'b0110_00_01_00000010;  // sw $1, 2($0) (6102)
    IMemory[5] = 16'b0110_00_10_00000000;  // sw $2, 0($0) (6200)
    IMemory[6] = 16'b0101_00_01_00000000;  // lw $1, 0($0) (5100)
    IMemory[7] = 16'b0101_00_10_00000010;  // lw $2, 2($0) (5202)
    IMemory[8] = 16'b0001_01_10_01_000000; // sub $1, $1, $2 (1640)

    // Data Memory: Initial Value
    DMemory [0] = 16'h5; // swap the cells and see how the simulation output changes
    DMemory [1] = 16'h7;
  end

  // Level 1//
  wire[15:0] A; // Program Counter
  wire [15:0] PCplus; // wire for next address in program counter
  // Program Counter: initial value = 0
  initial PC = 0;
  // Instruction Memory
  assign IR = IMemory[PC>>1];
  // ALU: Used to calculate and fetch the address of next instruction
  alu fetch (3'b010,PC,16'd2,PCplus,Unused[0]);

  // Level 2 //
  // Wire for MainControl
  wire RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite;
  wire [1:0] Branch, WR;
  wire [2:0] ALUOp;
  // Sign Extension: from 8-bit to 16-bit
  assign SignExtend = {{8{IR[7]}},IR[7:0]};
  // Register Files (4 of 16-bit registers)
  reg_file rf (IR[11:10],IR[9:8],WR,WD,RegWrite,A,RD2,clock);
  // 2-bit 2to1 multiplexer
  assign WR = (RegDst) ? IR[7:6]: IR[9:8];
  // Main Control
  MainControl MainCtr (IR[15:12],{RegDst,ALUSrc,MemtoReg,RegWrite,MemWrite,Branch,ALUOp});

  // Level 3 //
  wire [15:0] B, NextPC;
  // 16-bit 2to1 multiplexer
  assign B  = (ALUSrc) ? SignExtend: RD2; // ALUSrc Mux
  // ALU 16-bit: main ALU for mathematical calculation
  alu main (ALUOp, A, B, ALUOut, Zero);
  // ALU for branching decision (with unsigned shift left by 2)
  alu branch (3'b010,SignExtend<<1,PCplus,Target,Unused[1]);

  // 16-bit 2to1 Multiplexer for whether to branch or not
  mux2x1_16bit BranchMux(PCplus,Target,BranchSelect,NextPC);

  // Level 4 //
  // Branch Control
  BranchControl BranCon (Branch, Zero, BranchSelect);



  // Level 5//
  // Multiplexer: choose between ALUOut and DMemory
  mux2x1_16bit DMemMux(ALUOut, DMemory[ALUOut>>1], MemtoReg, WD);

  // ALU: Next PC
  always @(negedge clock) begin
    PC <= NextPC;

  end


endmodule
