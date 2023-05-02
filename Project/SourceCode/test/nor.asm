############################
##Test NOR basic function ##
############################
LLB		R1, 0x0000		# R1 contains 0x00000000
LLB   R2, 0x0F0F    # R2 contains 0x00000F0F
NOR	  R3, R1, R2	  # R3 should be 0xFFFFF0F0
LLB		R4, 0xF0F0		# R4 contains 0xFFFFF0F0
SUB		R4, R3, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

##################################
##Test that NOR sets carry flag ##
##################################
LLB		R1, 0x0F0F		# R1 contains 0x00000F0F
LHB   R1, 0x0F0F    # R1 contains 0x0F0F0F0F
LLB		R2, 0xF0F0		# R2 contains 0x0000F0F0
LHB   R2, 0xF0F0    # R2 contains 0xF0F0F0F0
NOR	R3, R1, R2	# R3 should be 0x00000000
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