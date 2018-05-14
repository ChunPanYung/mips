// macro
`define FORWARDING_V



module equal_2bit(x, y, q);
  input [1:0] x, y;
  output q;
  wire wirex, wirey, ny0, ny1;
    not n1(ny0, y[0]),
        n2(ny1, y[1]);
    xor xor1(wirex, x[0], ny0),
        xor2(wirey, x[1], ny1);
    and a1(q, wirex, wirey);
endmodule


module ForwardingUnit(IDEX_rs, IDEX_rt, EXMEM_rd, MEMWB_rd, EXMEM_RegWrite, MEMWB_RegWrite, fA, fB);
  input [1:0] IDEX_rs, IDEX_rt, EXMEM_rd, MEMWB_rd;
  input EXMEM_RegWrite, MEMWB_RegWrite;
  output [1:0] fA, fB;
  wire oe1, oe2, oe3, oe4, oe5, ne3, ne4, ne5, ne7;
	
	equal_2bit e1(IDEX_rs, EXMEM_rd, oe1),
						 e2(IDEX_rt, EXMEM_rd, oe2),
						 e3(EXMEM_rd, 2'b0, oe3),
						 e4(MEMWB_rd, 2'b0, oe4),
						 e5(EXMEM_rd, IDEX_rs, oe5),
						 e6(MEMWB_rd, IDEX_rs, oe6),
						 e7(EXMEM_rd, IDEX_rt, oe7),
						 e8(MEMWB_rd, IDEX_rt, oe8);
						 
	not note3(ne3, oe3),
			note4(ne4, oe4),
			note5(ne5, oe5),
			note7(ne7, oe7);
	
	and aFB10(fB[1], ne3, oe2, EXMEM_RegWrite),
			aFA10(fA[1], oe1, ne3, EXMEM_RegWrite),
			aFA01(fA[0], MEMWB_RegWrite, ne4, ne5, oe6),
			aFB01(fB[0], ne7, oe8, ne4, MEMWB_RegWrite);
			
endmodule