	LLB R1, 0x01
	LHB R1, 0x00	
	LLB R2, 0x22
	LHB R2, 0x22	
	LLB R3, 0x33
	LHB R3, 0x33	
	LLB R4, 0x44
	LHB R4, 0x44	
	LLB R5, 0x55
	LHB R5, 0x55	
	LLB R6, 0x66
	LHB R6, 0x66	
	LLB R7, 0x77
	LHB R7, 0x77	
	LLB R8, 0x88
	LHB R8, 0x88	
	LLB R9, 0x99
	LHB R9, 0x99	
	LLB R10, 0xaa
	LHB R10, 0xaa	
	LLB R11, 0xbb
	LHB R11, 0xbb	
	LLB R12, 0xcc
	LHB R12, 0xcc	
	LLB R13, 0xdd
	LHB R13, 0xdd	
	LLB R14, 0xee
	LHB R14, 0xee	
	LLB R15, 0xff
	LHB R15, 0xff
	jal r15change
	hlt   //r15change adds 1 to R15, skips this halt
	add R0, R15, R1
	add R15, R0, R15
	add R1, R1, R1
	B GT, hop
	hlt
hop:
	SW R14, R8, 3
	add R8, R8, R1
	LW R13, R8, 1
	add R11, R0, R13
	B NEQ, hop2
	add R13, R11, R11
hop2:
	jal jalswap
	add R1, R12, R0 //should happen
	hlt  //corect halt location
	
r15change:
	add R15, R15, R1
	jr R15
	hlt
jalret:
	jr R15
jalswap:
	sw R15, R12, 7
	lw R2, R12, 7
	jr R2