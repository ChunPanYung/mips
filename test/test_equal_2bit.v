// test bench
// When compile, use it with "-I ../src"
`include "forwarding.v"

// Test Module

module testBranchControl;
   reg [1:0] x, y;
   wire Out;

   equal_2bit equal(x, y, Out);

   initial
      begin

           x = 2'b00; y = 2'b00;
			# 10 x = 2'b00; y = 2'b01;
			# 10 x = 2'b01; y = 2'b00;
			# 10 x = 2'b11; y = 2'b11;

      end



   initial
     $monitor ("  %b   %b   %b", x, y, Out);

endmodule
