// Test ALU Control
// When compile, use it with "-I ../src"
`include "mips-pipe3.v"

// Test module

module test ();

  reg clock;
  wire [15:0] PC,IFID_IR,IDEX_IR,WD;

  CPU test_cpu(clock,PC,IFID_IR,IDEX_IR,WD);

  always #1 clock = ~clock;
  
  initial begin
    $display (" PC  IFID_IR  IDEX_IR   WD");
    $monitor ("%3d  %h     %h     %3d", PC,IFID_IR,IDEX_IR,WD);
    clock = 1;
    #29 $finish;
  end

endmodule


/* Compiling and simulation

Program with nop's
------------------------------
 PC  IFID_IR  IDEX_IR   WD
  0  xxxxxxxx xxxxxxxx   0
  4  2009000f xxxxxxxx   0
  8  200a0007 2009000f  15
 12  00000000 200a0007   7
 16  012a5824 00000000   0
 20  00000000 012a5824   7
 24  012b5022 00000000   0
 28  00000000 012b5022   8
 32  014b5025 00000000   0
 36  00000000 014b5025  15
 40  014b5820 00000000   0
 44  00000000 014b5820  22
 48  016a482a 00000000   0
 52  014b482a 016a482a   0
 56  xxxxxxxx 014b482a   1
 60  xxxxxxxx xxxxxxxx   X

Program without nop's
------------------------------
 PC  IFID_IR  IDEX_IR   WD
  0  xxxxxxxx xxxxxxxx   0
  4  2009000f xxxxxxxx   0
  8  200a0007 2009000f  15
 12  012a5824 200a0007   7
 16  012b5022 012a5824   X
 20  014b5025 012b5022   x
 24  014b5820 014b5025   X
 28  016a482a 014b5820   x
 32  014b482a 016a482a   X
 36  xxxxxxxx 014b482a   X
 40  xxxxxxxx xxxxxxxx   X
 44  xxxxxxxx xxxxxxxx   X
 48  xxxxxxxx xxxxxxxx   X
 52  xxxxxxxx xxxxxxxx   X
 56  xxxxxxxx xxxxxxxx   X
 60  xxxxxxxx xxxxxxxx   X

*/
