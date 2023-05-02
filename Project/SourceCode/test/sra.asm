############################
##Test SRA basic function ##
############################

LLB		R1, 0x0F0F		# R1 contains 0x00000F0F
LHB   R1, 0xF000    # R1 contains 0xF0000F0F
SRA	  R3, R1, 0x08	# R3 should be 0xFFF0000F
LLB		R4, 0x000F		# R4 contains 0x0000000F
LHB		R4, 0xFFF0		# R4 contains 0xFFF0000F
SUB		R4, R3, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test SRA basic function ##
############################

LLB		R1, 0x0000		# R1 contains 0x00000000
LHB   R1, 0x0F0F    # R1 contains 0x0F0F0000
SRA	  R3, R1, 0x10	# R3 should be 0x00000F0F
LLB		R4, 0x0F0F		# R4 contains 0x00000000
LHB		R4, 0x0000		# R4 contains 0x0F0F0000
SUB		R4, R3, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

##################################
##Test that SRA sets carry flag ##
##################################
## should set overflow
LLB		R1, 0x0000		# R1 contains 0x00000F0F
LHB   R1, 0x0000    # R1 contains 0x0F0F0F0F
SRA	R3, R1, 0x04	  # R3 should be 0x00000000
B		EQ, L_PASS	# branch to pass routine if overflow
B		NEQ, L_FAIL	# branch to fail routine

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