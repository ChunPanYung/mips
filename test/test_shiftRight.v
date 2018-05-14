// test bench
`include "other.v"

// Test module
module testShiftRight ();
	reg signed [15:0] inNum;
	wire [15:0] result;

	Cast_shftRight_1 pudding(inNum, result);

	initial begin
		    inNum = 16'd52;
		#10 inNum = 16'd4;
		#10 inNum = 16'd100;
		#10 inNum = -16'd8;
	end

	initial begin
		$display ("Input   Ouput");
		$monitor("%d  %d", inNum, result);
	end

endmodule // testSignExtend
