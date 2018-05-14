// test bench
// When compile, use it with "-I ../src"
`include "ALU16.v"

// Test Module

module testALU;
   reg [15:0] a;
   reg [15:0] b;
   reg [2:0] op;
   wire [15:0] result;
   wire zero;

   alu alu01 (op, a, b, result, zero);

   initial
      begin

		    op = 3'b000; a = 15'b0111; b = 15'b0001;  // AND
		#10 op = 3'b001; a = 15'b0101; b = 15'b0010;  // OR

		#10 op = 3'b010; a = 15'b0101; b = 15'b0001;  // ADD
		#10 op = 3'b010; a = 15'b0111; b = 15'b0001;  // ADD
		#10 op = 3'b110; a = 15'b0101; b = 15'b0001;  // SUB
		#10 op = 3'b110; a = 15'b1111; b = 15'b0001;  // SUB
		#10 op = 3'b111; a = 15'b0101; b = 15'b0001;  // SLT
		#10 op = 3'b111; a = 15'b1110; b = 15'b1111;  // SLT

      end

   initial
    $monitor ("op = %b a = %b b = %b result = %b zero = %b",op,a,b,result,zero);

endmodule


/* Test Results

C:\Verilog>iverilog -o t ALU4.vl

C:\Verilog>vvp t
op = 000 a = 0111 b = 0001 result = 0001 zero = 0
op = 001 a = 0101 b = 0010 result = 0111 zero = 0
op = 010 a = 0101 b = 0001 result = 0110 zero = 0
op = 010 a = 0111 b = 0001 result = 1000 zero = 0
op = 110 a = 0101 b = 0001 result = 0100 zero = 0
op = 110 a = 1111 b = 0001 result = 1110 zero = 0
op = 111 a = 0101 b = 0001 result = 0000 zero = 1
op = 111 a = 1110 b = 1111 result = 0001 zero = 0

*/
