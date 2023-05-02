############################
##Test BNEQ basic function ##
############################
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
ADD R3, R1, R2		# R3 should be 0x00006666
LLB R4, 0x6666		# R4 contains 0x00006666 
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test BEQ basic function ##
############################
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
ADD R3, R1, R2		# R3 should be 0x00006666
LLB R4, 0xA5A5		# R4 contains 0xFFFFA5A5 
SUB	R4, R3, R4		# compare R3 to known right answer
B EQ, L_FAIL		# branch to fail routine

############################
##Test BGT basic function ##
############################
LLB R1, 0x5555		# R1 contains 0x00005555
LHB R1, 0x8000		# R1 contains 0x80005555
LLB R2, 0x8000		# R2 contains 0xffff8000
ADD R3, R1, R2		# R3 should be 0x80000000
B GT, L_FAIL		# branch to fail routine
B GTE, L_FAIL		# branch to fail routine

############################
##Test BLT/E basic function ##
############################
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
ADD R3, R1, R2		# R3 should be 0x00006666
ADD R3, R1, R2		# R3 should be 0x80000000
B LT, L_FAIL		# branch to fail routine
B LTE, L_FAIL		# branch to fail routine


############################
##Test BOVFL basic function ##
############################
LLB R1, 0x5555		# R1 contains 0x00005555
LHB R1, 0x5555		# R1 contains 0x55555555
LLB R2, 0xfffe		# R2 contains 0xfffffffe
LHB R2, 0x7fff		# R2 contains 0x7ffffffe
ADD R3, R1, R2		# R3 should be 0x7fffffff
B OVFL, L_PASS		# branch to pass routine if overflow


#########################
##Pass routine at 0xAD ##
#########################
## Test BUNCOND basic function
MEM 0x00AD
L_PASS:
B		UNCOND, L_PASS

#########################
##Fail routine at 0xDD ##
#########################
## Test BUNCOND basic function
MEM 0x00DD
L_FAIL:
B		UNCOND, L_FAIL