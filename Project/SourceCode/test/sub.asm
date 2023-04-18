############################
##Test SUB basic function ##
############################
## subtracting two positive numbers
## with correct output
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
SUB R3, R1, R2		# R3 should be 0x00004444
LLB R4, 0x4444		# R4 contains 0x00004444 
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test SUB basic function ##
############################
## subtracting two negative numbers
## with overflow
LLB R1, 0x6666		# R1 contains 0x00006666
LHB R1, 0xffff		# R1 contains 0xffff6666
LLB R2, 0x5555		# R2 contains 0x00005555
LHB R2, 0xffff		# R2 contains 0xffff5555
SUB R3, R1, R2		# R3 should be 0x00001111
LLB R4, 0x1111		# R4 contains 0x00001111
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test SUB basic function ##
############################
## subtracting one positive number
## with one negative number
## no overflow
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x8000		# R2 contains 0xffff8000
SUB R3, R1, R2		# R3 should be 0x0000d555
LLB R4, 0xd555		# R4 contains 0xffffd555
LHB R4, 0x0000		# R4 contains 0x0000d555
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test SUB basic function ##
############################
## subtracting one positive number
## with one negative number
## no overflow
LLB R1, 0xffff		# R1 contains 0xffffffff
LHB R1, 0x7fff		# R1 contains 0x7fffffff
LLB R2, 0x0000		# R2 contains 0x00000000
LHB R2, 0x8000		# R2 contains 0x80000000
SUB R3, R1, R2		# R3 should be 0x7fffffff
LLB R4, 0xffff		# R4 contains 0xffffffff
LHB R4, 0x7fff		# R4 contains 0x7fffffff
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test SUB basic function ##
############################
## subtracting one negative number
## with one positive number
## with overflow
LLB R1, 0x0000		# R1 contains 0x00000000
LHB R1, 0x8000		# R1 contains 0x80000000
LLB R2, 0xffff		# R2 contains 0xffffffff
LHB R2, 0x7fff		# R2 contains 0x7fffffff
SUB R3, R1, R2		# R3 should be 0x80000000
LLB R4, 0x0000		# R4 contains 0x00000000
LHB R4, 0x8000		# R4 contains 0x80000000
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

#####################################
##Test that SUB sets negative flag ##
#####################################
## subtracting two positive numbers
## should not set negative flag
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
SUB R3, R1, R2		# R3 should be 0x00004444
B LT, L_FAIL		# branch to fail routine if negative flag is set
B LTE, L_FAIL		# branch to fail routine if negative flag is set and zero flag is set

#####################################
##Test that SUB sets negative flag ##
#####################################
## subtracting two positive numbers
## should set negative
LLB R1, 0x1111		# R1 contains 0x00001111
LLB R2, 0x5555		# R2 contains 0x00005555
SUB R3, R1, R2		# R3 should be 0xffffbbbc
B GTE, L_FAIL		# branch to fail if negative flag is not set
B GT, L_FAIL		# branch to fail if negative flag is not set and zero flag is set

##################################
##Test that SUB sets carry flag ##
##################################
## adding two positive numbers
## should not set overflow
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
SUB R3, R1, R2		# R3 should be 0x00004444
B OVFL, L_FAIL		# branch to fail routine if overflow

##################################
##Test that SUB sets carry flag ##
##################################
## adding two positive numbers
## should set overflow
LLB R1, 0x0000		# R1 contains 0x00000000
LHB R1, 0x8000		# R1 contains 0x80000000
LLB R2, 0xffff		# R2 contains 0xffffffff
LHB R2, 0x7fff		# R2 contains 0x7fffffff
SUB R3, R1, R2		# R3 should be 0x80000000
B OVFL, L_PASS		# branch to pass routine if overflow
B UNCOND, L_FAIL	# branch to fail routine


#########################
##Fail routine at 0xAD ##
#########################
MEM 0x00AD
L_PASS:B UNCOND, L_PASS

#########################
##Fail routine at 0xDD ##
#########################
MEM 0x00DD
L_FAIL: B UNCOND, L_FAIL