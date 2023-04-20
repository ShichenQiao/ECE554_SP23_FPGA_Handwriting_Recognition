###################################
##Test MULF does not set ov flag ##
###################################
LLB		R1, 0x0000
LHB		R1, 0x7F80		# positive infinite
MULF	R2, R1, R1		# results in pos_inf
B		OVFL, L_FAIL	# branch to fail routine if overflow

############################
##Test SUBF sets neg flag ##
############################
LLB		R1, 0x0000
LHB		R1, 0xC000
LLB		R2, 0x0000
LHB		R2, 0x3F00
MULF	R2, R1, R2		# -2 * 0.5 = -1
B		GTE, L_FAIL		# branch to fail if negative flag is not set

##########################
##Test MUL sets zr flag ##
##########################
LLB		R1, 0x0000
LLB		R2, 0x1234
LHB		R2, 0x5678
MULF	R2, R1, R2		# 0 * 68189266378752 = 0
B		NEQ, L_FAIL
B		UNCOND, L_PASS

##############################################################
# A specific test to mimic average pooling from 4 fp numbers #
##############################################################
LLB		R2, 0x0000
LHB		R2, 0x3E80		# R2 <- 0.25F
LLB		R7, 0x0000
LHB		R7, 0x4120		# R7 <- 10.0F
LLB		R8, 0x0000
LHB		R8, 0x41A0		# R8 <- 20.0F
LLB		R9, 0x0000
LHB		R9, 0x4348		# R9 <- 200.0F
LLB		R10, 0x8000
LHB		R10, 0x4477		# R10 <- 990.0F

ADDF	R13, R0, R7
ADDF	R13, R13, R8
ADDF	R13, R13, R9
ADDF	R13, R13, R10
MULF	R13, R13, R2	# 1220 * 0.25 = 305
LLB		R20, 0x8000
LHB		R20, 0x4398		# R20 <- 305
SUBF	R20, R20, R13
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