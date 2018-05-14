// macro
`define MIPS_R_TYPE_ADDI_V 1

// include if not defined
`ifndef ALU16_V
   `include "ALU16.v"
`endif

// include if not defined
`ifndef REGFILE_V
   `include "regfile.v"
`endif

module MainControl (Op,Control);

  input [3:0] Op;
  output reg [5:0] Control;

  always @(Op) case (Op)
    4'b0000: Control <= 6'b101010; // ADD
    4'b0001: Control <= 6'b101110; // SUB
    4'b0010: Control <= 6'b101000; // AND
    4'b0011: Control <= 6'b101001; // OR
    4'b0100: Control <= 6'b011010; // ADDI
    4'b0111: Control <= 6'b101111; // SLT
  endcase

endmodule

// Main CPU: contains instruction, Sign Extender,
// 2 multiplexer, MainControl (also serve as ALU Control)
module CPU (clock,ALUOut,IR);

  input clock;
  output [15:0] ALUOut,IR;
	// Program Counter
  reg[15:0] PC;
	// Instruction Memory
  reg[15:0] IMemory[0:512];
  wire [15:0] IR,NextPC,A,B,ALUOut,RD2,SignExtend;
  wire [2:0] ALUctl;
  wire [1:0] ALUOp;
  wire [1:0] WR;
	wire Unused; // unused output

// Test Program:
  initial begin

    // addi $t1, $0,  15   ($t1=15)
		// 0100 00 01 00001111
    IMemory[0] = 16'h410F;

    // addi $t2, $0,  7    ($t2= 7)
		// 0100 00 10 00000111
    IMemory[1] = 16'h4207;

    // and  $t3, $t1, $t2  ($t3= 7)
		// 0010 10 01 11 000000
    IMemory[2] = 16'h29C0;

    // sub  $t2, $t1, $t3  ($t2= 8)
		// 0001 01 11 10 000000
    IMemory[3] = 16'h1780;

    // or   $t2, $t2, $t3  ($t2=15)
		// 0011 11 10 10 000000
    IMemory[4] = 16'h3E80;

    // add  $t3, $t2, $t3  ($t3=22)
		// 0000 10 11 11 000000
    IMemory[5] = 16'h0BC0;

    // slt  $t1, $t3, $t2  ($t1= 0)
		// 0111 11 10 01 000000
    IMemory[6] = 16'h7E40;

    // slt  $t1, $t2, $t3  ($t1= 1)
		// 0111 10 11 01 000000
    IMemory[7] = 16'h7B40;

  end

  initial PC = 0; // Get the first instruction

  assign IR = IMemory[PC>>1]; // increment by 1


  assign WR = (RegDst) ? IR[7:6]: IR[9:8]; // RegDst Mux

  assign B  = (ALUSrc) ? SignExtend: RD2; // ALUSrc Mux

  assign SignExtend = {{8{IR[7]}},IR[7:0]}; // sign extension unit

	// register file
  reg_file rf (IR[11:10], IR[9:8], WR, ALUOut, RegWrite, A, RD2, clock);

	// fetch the next instruction
	alu fetch (3'd2, PC, 16'd2, NextPC, Unused);

  alu ex (ALUctl, A, B, ALUOut, Zero);  // main ALU


  MainControl MainCtr (IR[15:12],{RegDst,ALUSrc,RegWrite,ALUctl});

  always @(negedge clock) begin
    PC <= NextPC;
  end

endmodule
