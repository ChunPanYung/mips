// macro
`define MULTIPLEXER_V 1


// 2 to 1 multiplexer
module mux2x1(A,B,select,OUT);
   input A,B,select;
   output OUT;
   wire wX, wY, wZ;

	 // level 1
	 not not0(wX, select);

	 // level 2
	 and and0(wY, wX, A);
	 and and1(wZ, select, B);

	 // level 3
	 or or0(OUT, wY, wZ);

   //reg OUT;
   //always @ (select or A or B)
         //if (select == 0) OUT = A;
         //else OUT = B;
endmodule

// 2-bit 2 to 1 multiplexer
module mux2x1_2bit(A, B, select, OUT);
  input [1:0] A, B;
  input select;
  output [1:0] OUT;

  mux2x1 mux0(A[0], B[0], select, OUT[0]),
         mux1(A[1], B[1], select, OUT[1]);
endmodule

// 4-bit 2 to 1 multiplexer
module mux2x1_4bit(A, B, select, OUT);
   input [3:0] A, B;
	 input select;
	 output [3:0] OUT;

	 // 2 to 1 multiplexer
	 mux2x1 mux0(A[0], B[0], select, OUT[0]);
	 mux2x1 mux1(A[1], B[1], select, OUT[1]);
	 mux2x1 mux2(A[2], B[2], select, OUT[2]);
	 mux2x1 mux3(A[3], B[3], select, OUT[3]);

endmodule //mux2x1_4bit 

// 16-bit 2 to 1 multiplexer
module mux2x1_16bit(A, B, select, OUT);
   input [15:0] A, B;
	 input select;
	 output [15:0] OUT;

	 // 2 to 1 multiplexer
	 mux2x1_4bit mux0(A[3:0],   B[3:0],   select, OUT[3:0]);
	 mux2x1_4bit mux1(A[7:4],   B[7:4],   select, OUT[7:4]);
	 mux2x1_4bit mux2(A[11:8],  B[11:8],  select, OUT[11:8]);
	 mux2x1_4bit mux3(A[15:12], B[15:12], select, OUT[15:12]);

endmodule //mux2x1_4bit 

// 4 to 1 multiplexer
module mux4x1(i0,i1,i2,i3,select,y);
   input i0,i1,i2,i3;
   input [1:0] select;
   output y;
	 wire InvertS0, InvertS1, wa, wb, wc, wd;

   // level 1
	 not not0(InvertS0, select[0]);
	 not not1(InvertS1, select[1]);

	 // level 2
	 and and0(wa, i0, InvertS1, InvertS0);
	 and and1(wb, i1, InvertS1, select[0]);
	 and and2(wc, i2, select[1], InvertS0);
	 and and3(wd, i3, select[1], select[0]);

	 // level 3
	 or or0(y, wa, wb, wc, wd);

   //reg y;
   //always @ (i0 or i1 or i2 or i3 or select)
            //case (select)
               //2'b00: y = i0;
               //2'b01: y = i1;
               //2'b10: y = i2;
               //2'b11: y = i3;
            //endcase
endmodule

// 4 bit 4x1 multiplexer implemented by using 4 4x1 1bit multiplexers
// for each bit.
module mux4x1_4bit(i0,i1,i2,i3,select,y); 
    input [3:0] i0,i1,i2,i3; // 4 bit input
    input [1:0] select; // 2 select inputs
    output [3:0] y; // 4 bit output

    //instantiate the 4x1 MUX
    mux4x1 mux0(i0[0],i1[0],i2[0],i3[0],select,y[0]), 
           mux1(i0[1],i1[1],i2[1],i3[1],select,y[1]), 
           mux2(i0[2],i1[2],i2[2],i3[2],select,y[2]), 
           mux3(i0[3],i1[3],i2[3],i3[3],select,y[3]); 

endmodule 

// 16 bit 4x1 multiplexer implemented by using 4 4-bit 4x1 multiplexers 
// for each 4 bits.
module mux4x1_16bit(i0,i1,i2,i3,select,y); 
    input [15:0] i0,i1,i2,i3; // 16 bit inputs
    input [1:0] select; // 2 select inputs
    output [15:0] y; // 16 bit outputs


    //instantiate the 4x1 MUX
    mux4x1_4bit mux0(i0[3:0],i1[3:0],i2[3:0],i3[3:0],select,y[3:0]), 
                mux1(i0[7:4],i1[7:4],i2[7:4],i3[7:4],select,y[7:4]), 
                mux2(i0[11:8],i1[11:8],i2[11:8],i3[11:8],select,y[11:8]), 
                mux3(i0[15:12],i1[15:12],i2[15:12],i3[15:12],select,y[15:12]);
endmodule 
