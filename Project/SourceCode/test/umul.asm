#############################
##Test UMUL basic function ##
#############################
LLB		R1, 0x0002
LLB		R2, 0x000F
MUL		R3, R1, R2		# 2 * 15 = 30
LLB		R4, 0x001E
SUB		R4, R4, R3
B		NEQ, L_FAIL

#############################
##Test UMUL basic function ##
#############################
LLB		R1, 0xFFFE
LLB		R2, 0x0008
MUL		R3, R2, R1		# 65534 * 8 = 524272
LLB		R4, 0xFFF0
LHB		R4, 0x0007
SUB		R4, R3, R4
B		NEQ, L_FAIL

##################################
##Test UMUL never sets neg flag ##
##################################
LLB		R1, 0xFFFF
MUL		R2, R1, R1		# 65535 * 65535 = 4294836225
						# R2 contains FFFE0001
B		LT, L_FAIL		# branch to fail routine if negative flag is set

###########################
##Test UMUL sets zr flag ##
###########################
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