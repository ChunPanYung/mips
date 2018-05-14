// test bench
// When compile, use it with "-I ../src"
`include "control.v"

// Test Module

module testBranchControl;
   reg [1:0] Branch;
   reg Zero;
   wire Out;

   BranchControl BrnCon (Branch, Zero, Out);

   initial
      begin

        Branch = 2'b00; Zero = 0;
    #10 Branch = 2'b00; Zero = 1;
    #10 Branch = 2'b01; Zero = 0;
    #10 Branch = 2'b01; Zero = 1;
    #10 Branch = 2'b10; Zero = 0;
    #10 Branch = 2'b10; Zero = 1;
    #10 Branch = 2'b11; Zero = 0;
    #10 Branch = 2'b11; Zero = 1;

      end



   initial
     $monitor ("  %b   %b   %b",Branch, Zero, Out);

endmodule
