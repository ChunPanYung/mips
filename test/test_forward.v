// Test ALU Control
// When compile, use it with "-I ../src"
`include "forwarding.v"

// Test Bench
module testBench;
	 // input
	 reg [1:0] x0, x1, x2, x3;
	 reg x4, x5;
	 // output 
	 wire [1:0] q0, q1;



   // module: Forwarding Unit
	 ForwardingUnit forUnit(x0, x1, x2, x3, x4, x5, q0, q1);

   initial
      begin
				// q0 = 10; 
				#10 x0 = 2'b01; x1 = 2'b00; x2 = 2'b01; x3 = 2'b01; x4 = 1'b1; x5 = 1'b0;
				// q1 = 10;
				#10 x0 = 2'b00; x1 = 2'b01; x2 = 2'b01; x3 = 2'b01; x4 = 1'b1; x5 = 1'b0;
				
				// q0 = 01;
				#10 x0 = 2'b11; x1 = 2'b01; x2 = 2'b01; x3 = 2'b11; x4 = 1'b1; x5 = 1'b1;
				// q1 = 01;
				#10 x0 = 2'b01; x1 = 2'b10; x2 = 2'b11; x3 = 2'b10; x4 = 1'b1; x5 = 1'b1;
				
				// q0 = 01;
				#10 x0 = 2'b11; x1 = 2'b01; x2 = 2'b01; x3 = 2'b11; x4 = 1'b0; x5 = 1'b0;
				// q1 = 01;
				#10 x0 = 2'b01; x1 = 2'b10; x2 = 2'b11; x3 = 2'b10; x4 = 1'b0; x5 = 1'b0;

				


      end

   initial
			begin
		     $display ("IDEX_rs IDEX_rt EXMEM_rd MEMWB_rd EXMEM_RegWrite MEMWB_RegWrite Out Out");
         $monitor ("%b      %b      %b       %b       %b              %b              %b  %b",
		     x0, x1, x2, x3, x4, x5, q0, q1);
			
		  end

endmodule
