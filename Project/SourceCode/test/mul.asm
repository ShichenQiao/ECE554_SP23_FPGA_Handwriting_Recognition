############################
##Test MUL basic function ##
############################
LLB		R1, 0x0002
LLB		R2, 0x000F
MUL		R3, R1, R2		# 2 * 15 = 30
LLB		R4, 0x001E
SUB		R4, R4, R3
B		NEQ, L_FAIL

############################
##Test MUL basic function ##
############################
LLB		R1, 0xFFFE
LHB		R1, 0x0000		# intentionally put here
						# should only use lower 16-bit
LLB		R2, 0xFFF8
LHB		R2, 0x0000		# intentionally put here
						# should only use lower 16-bit
MUL		R3, R2, R1		# -2 * -8 = 16
LLB		R4, 0x0010
SUB		R4, R3, R4
B		NEQ, L_FAIL

############################
##Test MUL basic function ##
############################
LLB		R1, 0xFFFE
LHB		R1, 0x0000		# intentionally put here
						# should only use lower 16-bit
LLB		R2, 0x0008
MUL		R3, R2, R1		# -2 * 8 = -16
LLB		R4, 0xFFF0
SUB		R4, R3, R4
B		NEQ, L_FAIL

###########################
##Test MUL sets neg flag ##
###########################
LLB		R1, 0xFFFF
LHB		R1, 0x0000		# intentionally put here
						# should only use lower 16-bit
LLB		R2, 0x0008
MUL		R3, R2, R1		# -1 * 8 = -8
B		GTE, L_FAIL		# branch to fail if negative flag is not set

###################
##Test edge case ##
###################
LLB		R1, 0x8000
MUL		R2, R1, R1		# -32768 * -32768 = 1073741824
LLB		R3, 0x4000
SUB		R2, R2, R3
B		NEQ, L_FAIL

##########################
##Test MUL sets zr flag ##
##########################
LLB		R1, 0x0000
LLB		R2, 0xABCD
MUL		R2, R1, R2
B		NEQ, L_FAIL
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