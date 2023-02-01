##############################################################
# This test focus on Register Register, LLB, LHB, and Shifts #
##############################################################	
		LLB R1, 0x55
		LLB R2, 0x33
		ADD R3, R2, R1		# (should be 0x88)
		SUB R4, R1, R2		# (should be 0x22)
		ADD R14, R3, R4 	# (should be 0xAA in R14)
		LLB R13, 0xAA		# R13 will contain 0xFFAA (sign extension)
		LHB R13, 0x00		# R13 will now contain 0x00AA
		SUB R0, R14, R13	# (performing a compare)
		B NEQ, FAIL
		LLB R5, 0x77
		AND R6, R5, R2		# (should be 0x33)
		NOR R7, R3, R2		# (should be 0xFF44)
		LHB R7, 0x00		# R7 will now contain 0x0044
		ADD R8, R0, R0		# R8 = 0x00
		LLB R2, 0x01		# R2 = 1
AGN:	ADD R8, R8, R2		# R8 = R8 + 1
        SUB R7, R7, R4		# R7 = R7 - 0x22
		B NEQ, AGN			# Will loop twice
		SUB R0, R8, R2		# compare R8 to 1
		B LTE,	FAIL		# R8 should equal 2
		LLB R9, 0xAA		# should contain 0xFFAA (sign extended)
		LLB R10, 0x56
		ADD R11, R9, R10	# should add to 0x0000
		B NEQ, FAIL
		LLB R12, 0xAB		# R12 = 0xFFAB
		LHB R12, 0x34		# R12 = 0x34AB
		LLB R13, 0x55		# R13 = 0x0055
		LHB R13, 0x7B		# R13 = 0x7B55
		ADD R14, R13, R12	# should saturate to 0x7FFF with overflow
		B OVFL, CONT		# branch to continue test
		B UNCOND, FAIL		# else we jump to fail routine
CONT:   LLB R13, 0xFF		# R13 = 0xFFFF
		LHB R13, 0x7F		# R13 = 0x7FFF
		SUB R0, R13, R14 	# compare
		B NEQ, FAIL
		SLL R13, R12,0x02	# R13 should contain 0xD2AC
		SRA R12, R13,4		# R12 should contain 0xFD2A
		SLL R13, R13,3		# R13 should contain 0x9560
		SLL R12, R12,7		# R12 should contain 0x9500
		ADD R14, R12, R13	# R14 should sat to 0x8000
		B OVFL, CONT2		# overflow should be set
		B UNCOND, FAIL
CONT2:	LLB R9, 0x00
		LHB R9, 0x80
		SUB R0, R14, R9		# compare R14 to 0x8000
		B NEQ, FAIL
		SRL R14, R14, 8		# R14 should contain 0x0080
		LLB R9, 0x80
		LHB	R9, 0x00
		SUB R0, R14, R9
		B NEQ, FAIL
		
		
PASS:	LLB R1, 0xAA		# R1 will contain 0xFFAA
		LHB R1, 0xAA		# R1 will contain 0xAAAA (indicated pass)
		HLT
FAIL:	LLB R1, 0xFF		# R1 will contain 0xFFFF (indicates failure)
		HLT