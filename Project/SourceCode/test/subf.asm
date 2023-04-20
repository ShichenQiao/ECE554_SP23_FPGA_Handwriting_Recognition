###################################
##Test SUBF does not set ov flag ##
###################################
LLB		R1, 0x0000
LHB		R1, 0x7F80		# positive infinite
LLB		R3, 0x0000
SUBF	R2, R3, R1		# results in neg_inf
B		OVFL, L_FAIL	# branch to fail routine if overflow

############################
##Test SUBF sets neg flag ##
############################
LLB		R1, 0x0000
LHB		R1, 0xC000
LLB		R2, 0x0000
LHB		R2, 0x3FA0
SUBF	R2, R1, R2		# -2 - 1.25 = -3.25
B		GTE, L_FAIL		# branch to fail if negative flag is not set

##########################
##Test MUL sets zr flag ##
##########################
LLB		R1, 0x0000
LLB		R2, 0x0000
LHB		R2, 0x8000
SUBF	R2, R1, R2		# 0 - (-0) = -0
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