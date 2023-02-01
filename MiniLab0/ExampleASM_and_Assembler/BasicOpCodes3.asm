#############################################################
# This test focuses more on control instructions (branches) #
#############################################################
		LLB R1, 0x55
		LLB R2, 0x33
		ADD R3, R2, R1		# (should be 0x88)
		B NEQ, CONT1		# NEQ taken branch
		B UNCOND, FAIL
CONT1:	SUB R0, R2, R2		# will result in zero
		B NEQ, FAIL			# NEQ not taken branch
		B EQ, CONT2			# taken EQ branch
		B UNCOND, FAIL
CONT2:	SUB R0, R1, R2		# 55 - 33
		B EQ, FAIL			# not taken EQ branch
		B GT, CONT3			# Taken GT branch
		B UNCOND, FAIL
CONT3:	SUB R0, R1, R1		# 55 - 55
		B GT, FAIL			# not taken GT branch
		B LT, FAIL			# not taken LT branch
		SUB R0, R2, R1		# 33 - 55
		B LT, CONT4			# taken LT branch
		B UNCOND, FAIL
CONT4:	SUB R0, R3, R3		# 88 - 88
		B GTE, CONT5		# taken GTE (=)
		B UNCOND, FAIL
CONT5:	SUB R0, R1, R3		# 55 - 88
		B GTE, FAIL			# not taken GTE
		SUB R0, R3, R1		# 88 - 55
		B GTE, CONT6		# taken GTE (>)
		B UNCOND, FAIL
CONT6:	SUB R0, R1, R3		# 55 - 88
		B LTE, CONT7		# taken LTE (<)
		B UNCOND, FAIL
CONT7:	SUB R0, R1, R1		# 55 - 55
		B LTE, CONT8		# taken LTE (=)
		B UNCOND, FAIL
CONT8:	SUB R0, R3, R1		# 88 - 55
		B LTE, FAIL			# not taken LTE
		LHB R1, 0x7F		# R1 now contains 0x7F55
		LHB R3, 0x70		# R3 now contains 0x7088
		ADD R0, R1, R3		# positive overflow
		B OVFL, CONT9		# taken OVFL
		B UNCOND, FAIL
CONT9:	SUB R0, R3, R1		# no overflow
		B OVFL, FAIL		# not taken OVFL

PASS:	LLB R1, 0xAA		# R1 will contain 0xFFAA
		LHB R1, 0xAA		# R1 will contain 0xAAAA (indicated pass)
		HLT
		ADD R0, R0, R0		# Nop in case their halt instruction does not stop in time
	
FAIL:	LLB R1, 0xFF		# R1 will contain 0xFFFF (indicates failure)
		HLT			

