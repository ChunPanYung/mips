// Macro
`define OTHER_V 1

module Cast_shftRight_1 (In, Out);
	// input
	input [15:0] In;
	// output
	output [15:0] Out;

	assign Out[15:0] = {1'b0,  In[15], In[14], In[13], In[12], In[11], In[10],
	                    In[9], In[8],  In[7],  In[6],  In[5],  In[4],  In[3],
											In[2], In[1]};

endmodule //Cast_shftRight_1

module sign_8to16 (bit8, bit16);
	// input
	input [7:0] bit8;
	// output
	output [15:0] bit16;

	assign bit16[15:0] = { {8{bit8[7]}} , bit8[7:0] };

endmodule // sign_8to16
