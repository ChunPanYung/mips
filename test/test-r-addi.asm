# Test program for mips-r-type+addi.vl

  .text	

  .globl __start 
__start:

  # For addi: Op rs rt imm
	# for r-type: Op rs rt rd funct


  # 0100 00 01 00001111, 410F
  addi $t1, $0,  15   # $t1=15
	# 0100 00 10 00000111, 4207
  addi $t2, $0,  7    # $t2= 7 
	# 0010 10 01 11 000000, 29C0
  and  $t3, $t1, $t2  # $t3= 7
	# 0001 01 11 10 000000, 1780
  sub  $t2, $t1, $t3  # $t2= 8
	# 0011 11 10 10 000000, 3E80
  or   $t2, $t2, $t3  # $t2=15
	# 0100 11 10 11 000000, 4EC0
  add  $t3, $t2, $t3  # $t3=22
	# 0111 10 11 01 000000, 7B40
  slt  $t1, $t3, $t2  # $t1= 0
	# 0111 11 10 01 000000, 7E40
  slt  $t1, $t2, $t3  # $t1= 1






