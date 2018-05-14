// Test 16-bit 4to1 multiplexer
// When compile, use it with "-I ../src"
`include "multiplexer.v"

// Test Bench
module testBench;
	 // input
   reg [15:0] i0, i1, i2, i3;
	 reg [1:0] select;
	 // output
	 wire [15:0] y;


   mux4x1_16bit mux (i0,i1,i2,i3,select,y);

   initial
      begin

      // Set input to 4to1 16-bit mulitplexer to:
			// 25, 0, 32767, -1
			// use the "select" input to select one of them
			// and print it out.
			#10 i0 = 15'd25; i1 = 15'd0; i2 = 15'd32767; i3 = -15'd1;
			   select = 2'd0;
			#10 i0 = 15'd25; i1 = 15'd0; i2 = 15'd32767; i3 = -15'd1;
			   select = 2'd1;
			#10 i0 = 15'd25; i1 = 15'd0; i2 = 15'd32767; i3 = -15'd1;
			   select = 2'd2;
			#10 i0 = 15'd25; i1 = 15'd0; i2 = 15'd32767; i3 = -15'd1;
			   select = 2'd3;

      end

   initial
      $monitor ("i0 = %d i1 = %d i2 = %d i3 = %d select = %d y = %d",
		     i0, i1, i2, i3, select, y);

endmodule
