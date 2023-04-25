############################
##Test ITF basic function ##
############################
LLB		R1, 0x04D2		# 1234d
ITF		R2, R1			# should be 0x449a4000
LLB		R3, 0x4000
LHB		R3, 0x449a
SUBF	R3, R2, R3
B		NEQ, L_FAIL

############################
##Test ITF basic function ##
############################
LLB		R1, 0xEF1F		# -4321d
ITF		R2, R1			# should be 0xc5870800
LLB		R3, 0x0800
LHB		R3, 0xC587
SUBF	R3, R2, R3
B		NEQ, L_FAIL

###########################
##Test ITF sets neg flag ##
###########################
LLB		R1, 0xEF1F		# -5858d
ITF		R2, R1			# should be 0xc5b71000
B		GTE, L_FAIL		# branch to fail if negative flag is not set

##########################
##Test MUL sets zr flag ##
##########################
LLB		R1, 0x0000
ITF		R2, R1
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