#####################################
# This test focus on LW/SW and ADDZ #
#####################################	
        LLB R6, 0x33		# R6 contains 0x0033
		LLB R10, 0x56		# R10 contains 0x0056
		LLB R8, 0x02		# R8 contains 0x0002
		LLB R2, 0x40
		ADD R14, R2, R2		# R14 contains 0x80
		LLB R12, 0x00
		LHB R12, 0x95		# R12 contains 0x9500
		LLB R13, 0x60
		LHB R13, 0x95		# R13 contains 0x9560
		
##############################
# Now for some LW/SW testing #
##############################
		SW R12, R14,0x2		# storing 0x9500 at location 0x0082
		SW R13, R14,0x3		# storing 0x9560 at location 0x0083
		LLB R1, 0x04		# R1 should have 4
		ADD R2, R1, R14		# R2 should now have 0x0084
		LW R3, R2, 0xE		# should be loading R3 with location 0x0082 (9500)
		SUB R0, R3, R12
		B NEQ, FAIL
		LW R4, R2, 0xF		# should be loading R4 with location 0x0083 (9560)
		SUB R0, R4, R13
		B NEQ, FAIL
#################
#  ADDZ testing #
#################	
		ADDZ R5, R6, R10		# zero flag should last be set so R5 = 0x0056+0x0033
		LLB R7, 0x89
		LHB R7, 0x00
		SUB R0, R7, R5
		B NEQ, FAIL
		ADD R0, R6, R6			# this add should clear zero flag
		ADDZ R8, R10, R10		# would be performing 0x0056 + 0x0056, however R8 should stay 0x0002
		LLB R9, 0x02
		SUB R0, R8, R9
		B NEQ, FAIL
				
PASS:	LLB R1, 0xAA		# R1 will contain 0xFFAA
		LHB R1, 0xAA		# R1 will contain 0xAAAA (indicated pass)
		HLT
		
FAIL:	LLB R1, 0xFF		# R1 will contain 0xFFFF (indicates failure)
		HLT