// test bench
// When compile, use it with "-I ../src"
`include "regfile.v"


module testing ();

 // input
 reg [1:0] rr1,rr2,wr;
 reg [15:0] wd;
 reg regwrite, clock;
 // ouput
 wire [15:0] rd1,rd2;

 reg_file regs (rr1,rr2,wr,wd,regwrite,rd1,rd2,clock);

 initial
   begin

     #10 regwrite=1'd1;    // enable writing

     #10 wd=16'd500;       // set write data

     #10          rr1=2'b0; rr2=2'b0; clock=1'b0;
     #10 wr=2'd1; rr1=2'b1; rr2=2'b1; clock=1'b1;
     #10                              clock=1'b0;
     #10 wr=2'd2; rr1=2'd2; rr2=2'd2; clock=1'b1;
     #10                              clock=1'b0;
     #10 wr=2'd3; rr1=2'd3; rr2=2'd3; clock=1'd1;
     #10                              clock=1'd0;

     #10 regwrite=1'd0;    // disable writing

     #10 wd=16'd30000;     // set write data

     #10 wr=2'd1; rr1=2'd1; rr2=2'd1; clock=1'd1;
     #10                              clock=1'd0;
     #10 wr=2'd2; rr1=2'd2; rr2=2'd2; clock=1'd1;
     #10                              clock=1'd0;
     #10 wr=2'd3; rr1=2'd3; rr2=2'd3; clock=1'd1;
     #10                              clock=1'd0;

     #10 regwrite=1'd1;    //enable writing

     #10 wd=-16'd1;        // set write data

     #10 wr=2'd1; rr1=2'd1; rr2=2'd1; clock=1'd1;
     #10                              clock=1'd0;
     #10 wr=2'd2; rr1=2'd2; rr2=2'd2; clock=1'd1;
     #10                              clock=1'd0;
     #10 wr=2'd3; rr1=2'd3; rr2=2'd3; clock=1'd1;
     #10                              clock=1'd0;

   end

 initial
   $monitor ("regwrite=%d clock=%d rr1=%d rr2=%d wr=%d wd=%d rd1=%d rd2=%d",
	   regwrite,clock,rr1,rr2,wr,wd,rd1,rd2);

endmodule
