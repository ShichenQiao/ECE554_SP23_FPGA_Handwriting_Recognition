############################
##Test LW/SW basic function ##
############################

LLB		R1, 0x0F0F		# R1 contains 0x00000F0F
LHB   R1, 0xF000    # R1 contains 0xF0000F0F
LLB   R2, 0x0004    # R2 contains 0x00000004
SW    R1, R2, 0     # DataMem[4] should contains 0xF0000F0F
LW    R3, R2, 0     # R3 should contains 0xF0000F0F
LLB		R4, 0x0F0F		# R4 contains 0x0000000F
LHB		R4, 0xF000		# R4 contains 0xFFF0000F
SUB		R4, R3, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test LW/SW basic function ##
############################

LLB		R1, 0xA5A5		# R1 contains 0xFFFFA5A5
LHB   R1, 0xA5A5    # R1 contains 0xA5A5A5A5
LLB   R2, 0x0008    # R2 contains 0x00000008
SW    R1, R2, 0     # DataMem[8] should contains 0xA5A5A5A5
LW    R3, R2, 0     # R3 should contains 0xF0000F0F
LLB		R4, 0xA5A5		# R4 contains 0xFFFFA5A5
LHB		R4, 0xA5A5		# R4 contains 0xA5A5A5A5
SUB		R4, R3, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

B		UNCOND, L_PASS

#########################
##Pass routine at 0xAD ##
#########################
MEM 0x00AD
L_PASS:
B		UNCOND, L_PASS

#########################
##Fail routine at 0xDD ##
#########################
MEM 0x00DD
L_FAIL:
B		UNCOND, L_FAIL