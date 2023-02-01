#############################################################
# This test focuses more on control instructions (branches) #
#############################################################

#################################
# This section focuses on jumps #
#################################
		LLB R1, 0x05		# R1 contains address of CONT1
		JR R1				# Jump to CONT1
		B UNCOND, FAIL
		ADD R0, R0, R0
		ADD R0, R0, R0
CONT1: 	JAL FUNC			# jump to function
		LLB R4, 0x57
		SUB R0, R3, R4
		B EQ, PASS
	
FAIL:	LLB R1, 0xFF		# R1 will contain 0xFFFF (indicates failure)
		HLT			

PASS:	LLB R1, 0xAA		# R1 will contain 0xFFAA
		LHB R1, 0xAA		# R1 will contain 0xAAAA (indicated pass)
		HLT
		
FUNC:	LLB	R3, 0x57
		JR R15				# return
