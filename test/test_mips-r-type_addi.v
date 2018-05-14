// Test mips-r-type_addi.vvp
// When compile, use it with "-I ../src"
`include "mips-r-type_addi.v"

// Test module

module test ();

  reg clock;
  wire [15:0] WD,IR;

  CPU test_cpu(clock,WD,IR);

  always #1 clock = ~clock;

  initial begin
    $display ("time clock IR(hex) WD(dec)");
    $monitor ("%2d   %b        %h   %d", $time,clock,IR,WD);
    clock = 1;
    #14 $finish;
  end

endmodule
