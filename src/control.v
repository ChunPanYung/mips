`define CONTROL_V 1

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
    4'b1010: Control <= 10'b0000011110; // JUMP
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


// BranhControl
module BranchControl_2(Op,OUT);

  input [2:0] Op;
  output reg [1:0] OUT;

  always @(Op) case (Op)
    3'b101: OUT <= 2'b01; // beq
    3'b010: OUT <= 2'b01; // bne
    3'b110: OUT <= 2'b10; // jump
    3'b111: OUT <= 2'b10; // jump
    3'b000: OUT <= 2'b11; 
    3'b001: OUT <= 2'b11; 
    3'b010: OUT <= 2'b11; 
    3'b100: OUT <= 2'b11; 
  endcase

endmodule
