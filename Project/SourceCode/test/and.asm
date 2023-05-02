############################
##Test SUBi basic function ##
############################
## subtracting two positive numbers
## with correct output
LLB		R1, 0x6666		# R1 contains 0x00006666
LLB   R2, 0x6060    # R2 contains 0x00006060
AND	  R3, R1, R2	  # R3 should be 0x00006060
LLB		R4, 0x6060		# R4 contains 0x00006060
SUB		R4, R3, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

##################################
##Test that AND sets carry flag ##
##################################
## should set overflow
LLB		R1, 0x0000		# R1 contains 0x00000000
LHB   R1, 0x0000    # R1 contains 0x00000000
LLB		R2, 0x0000		# R2 contains 0x00000000
LHB   R2, 0x0000    # R2 contains 0x00000000
AND	R3, R1, R2	# R3 should be 0x00000000
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