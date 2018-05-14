// Test 16-bit 4to1 multiplexer
// When compile, use it with "-I ../src"
`include "multiplexer.v"

// Test Bench
module testBench;
	 // input
   reg [15:0] i0, i1;
	 reg select;
	 // output
	 wire [15:0] y;


   mux2x1_16bit mux (i0,i1,select,y);

   initial
      begin

      // Set input to 2to1 16-bit mulitplexer to:
			// 25, 1000
			// use the "select" input to select one of them
			// and print it out.
			#10 i0 = 15'd25; i1 = 15'd1000; select = 0;
			#10 i0 = 15'd25; i1 = 15'd1000; select = 1;

      end

   initial
      $monitor ("i0 = %d i1 = %d select = %d y = %d",
		     i0, i1, select, y);

endmodule
