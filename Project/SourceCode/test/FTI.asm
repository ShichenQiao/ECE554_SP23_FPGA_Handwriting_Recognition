############################
##Test FTI basic function ##
############################
LLB		R1, 0x0000
LHB		R1, 0xBF80		# -1f
FTI		R2, R1			# should be 0xFFFFFFFF
LLB		R3, 0xFFFF
SUB		R3, R2, R3
B		NEQ, L_FAIL

############################
##Test FTI basic function ##
############################
LLB		R1, 0x1000
LHB		R1, 0x4480		# 1024.5f
FTI		R2, R1			# should be 0x00000400
LLB		R3, 0x0400		# 1024d
SUB		R3, R2, R3
B		NEQ, L_FAIL

###########################
##Test FTI sets neg flag ##
###########################
LLB		R1, 0x8eb8
LHB		R1, 0xc3d9		# -435.114990234375f
FTI		R2, R1			# should be 0xFFFFFE4D
B		GTE, L_FAIL		# branch to fail if negative flag is not set

##########################
##Test MUL sets zr flag ##
##########################
LLB		R1, 0x0000
FTI		R2, R1
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