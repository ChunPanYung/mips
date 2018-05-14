// Test ALU Control
// When compile, use it with "-I ../src"
`include "mips-r-type_addi.v"

// Test Bench
module testBench;
	 // input
	 reg [3:0] Op;
	 // output
	 wire [5:0] Control;
	 // Assign array to individual output
	 wire RegDst, ALUsrc, RegWrite;
	 wire [2:0] ALUCtl;
	 assign {RegDst, ALUsrc, RegWrite, ALUCtl[2:0]} = Control;



   // module
	 //MainControl MainCon (Op, {RegDst, ALUsrc, RegWrite, Control});
	 MainControl MainCon (Op, Control);

   initial
      begin
         // input: add(0000),  output: 1 0 1 010
			       Op = 4'b0000;
				 // input: sub(0001),  output: 1 0 1 110
			   #10 Op = 4'b0001;
				 // input: and(0010),  output: 1 0 1 000
			   #10 Op = 4'b0010;
				 // input: or(0011),   output: 1 0 1 001
				 #10 Op = 4'b0011;
				 // input: addi(0100), output: 0 1 1 010
				 #10 Op = 4'b0100;
				 // input: slt(0111),  output: 1 0 1 111
				 #10 Op = 4'b0111;

      end

   initial
			begin
		     $display ("Op     RegDst    ALUsrc   RegWrite     ALUCtl");
         $monitor ("%b        %b         %b          %b        %b",
		     Op, RegDst, ALUsrc, RegWrite, ALUCtl[2:0]);
				 //Op, Control);
		  end

endmodule
