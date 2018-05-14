// Include
`include "mips-simple.v"

// Test module

module test ();

  reg clock;
  wire [15:0] WD,IR,PC;

  CPU test_cpu(clock,WD,IR,PC);

  always #1 clock = ~clock;

  initial begin
    $display ("clock PC IR       WD");
    $monitor ("%b    %2d  %h   %h", clock,PC,IR,WD);
    clock = 1;
    #16 $finish;
  end

endmodule


/* Simulation output

// DMemory [0] = 32'h5;
// DMemory [1] = 32'h7;

clock PC IR       WD
1     0  8c080000 00000005
0     4  8c090004 00000007
1     4  8c090004 00000007
0     8  0109502a 00000001
1     8  0109502a 00000001
0    12  11400002 00000001
1    12  11400002 00000001
0    16  ac080004 00000004
1    16  ac080004 00000004
0    20  ac090000 00000000
1    20  ac090000 00000000
0    24  8c0b0000 00000007
1    24  8c0b0000 00000007
0    28  8c0c0004 00000005
1    28  8c0c0004 00000005
0    32  016c5822 00000002
1    32  016c5822 00000002


// DMemory [0] = 32'h7;
// DMemory [1] = 32'h5;

clock PC IR       WD
1     0  8c080000 00000007
0     4  8c090004 00000005
1     4  8c090004 00000005
0     8  0109502a 00000000
1     8  0109502a 00000000
0    12  11400002 00000000
1    12  11400002 00000000
0    24  8c0b0000 00000007
1    24  8c0b0000 00000007
0    28  8c0c0004 00000005
1    28  8c0c0004 00000005
0    32  016c5822 00000002
1    32  016c5822 00000002
0    36  xxxxxxxx 0000000X
1    36  xxxxxxxx 0000000X
0    40  xxxxxxxx 0000000X
1    40  xxxxxxxx 0000000X

*/
