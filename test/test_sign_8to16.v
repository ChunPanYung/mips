// test bench
`include "other.v"

// Test module

module testSignExtend ();
	reg[7:0] inNum;
	wire [15:0] result;

	sign_8to16 pudding(inNum, result);

	initial begin
		    inNum = 16'd52;
		#10 inNum = 16'b0001_0111;
	end

	initial begin
		$display ("Input    Ouput");
		$monitor("%b %b", inNum, result);
	end

endmodule // testSignExtend
