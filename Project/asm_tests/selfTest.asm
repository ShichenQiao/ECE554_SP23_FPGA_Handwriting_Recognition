############################
##Test ADD basic function ##
############################
## adding two positive numbers
## with correct output
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
ADD R3, R1, R2		# R3 should be 0x00006666
LLB R4, 0x6666		# R4 contains 0x00006666 
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test ADD basic function ##
############################
## adding two positive numbers
## with overflow
LLB R1, 0x5555		# R1 contains 0x00005555
LHB R1, 0x5555		# R1 contains 0x55555555
LLB R2, 0xfffe		# R2 contains 0xfffffffe
LHB R2, 0x7fff		# R2 contains 0x7ffffffe
ADD R3, R1, R2		# R3 should be 0x7fffffff
LLB R4, 0xffff		# R4 contains 0xffffffff
LHB R4, 0x7fff		# R4 contains 0x7fffffff
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test ADD basic function ##
############################
## adding one positive number
## with one negative number
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x8000		# R2 contains 0xffff8000
LHB R2, 0x0000		# R2 contains 0x00008000
ADD R3, R1, R2		# R3 should be 0x0000d555
LLB R4, 0xd555		# R4 contains 0xffffd555
LHB R4, 0x0000		# R4 contains 0x0000d555
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test ADD basic function ##
############################
## adding two negative numbers
## with overflow
LLB R1, 0x5555		# R1 contains 0x00005555
LHB R1, 0x8000		# R1 contains 0x80005555
LLB R2, 0x8000		# R2 contains 0xffff8000
ADD R3, R1, R2		# R3 should be 0x80000000
LLB R4, 0x0000		# R4 contains 0x00000000
LHB R4, 0x8000		# R4 contains 0x80000000
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

############################
##Test ADD basic function ##
############################
## adding two negative numbers
## with correct output
LLB R1, 0xd555		# R1 contains 0xffffd555
LLB R2, 0x8000		# R2 contains 0xffff8000
ADD R3, R1, R2		# R3 should be 0xffff5555
LLB R4, 0x5555		# R4 contains 0x00005555
LHB R4, 0xffff		# R4 contains 0xffff5555
SUB	R4, R3, R4		# compare R3 to known right answer
B NEQ, L_FAIL		# branch to fail routine

#####################################
##Test that ADD sets negative flag ##
#####################################
## adding two positive numbers
## should not set negative flag
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
ADD R3, R1, R2		# R3 should be 0x00006666
B LT, L_FAIL		# branch to fail routine if negative flag is set
B LTE, L_FAIL		# branch to fail routine if negative flag is set and zero flag is set

#####################################
##Test that ADD sets negative flag ##
#####################################
## adding two positive numbers
## should set overflow
LLB R1, 0xd555		# R1 contains 0xffffd555
LLB R2, 0x8000		# R2 contains 0xffff8000
ADD R3, R1, R2		# R3 should be 0xffff5555
B GTE, L_FAIL		# branch to fail if negative flag is not set
B GT, L_FAIL		# branch to fail if negative flag is not set and zero flag is set

##################################
##Test that ADD sets carry flag ##
##################################
## adding two positive numbers
## should not set overflow
LLB R1, 0x5555		# R1 contains 0x00005555
LLB R2, 0x1111		# R2 contains 0x00001111
ADD R3, R1, R2		# R3 should be 0x00006666
B OVFL, L_FAIL		# branch to fail routine if overflow

##################################
##Test that ADD sets carry flag ##
##################################
## adding two positive numbers
## should set overflow
LLB R1, 0x5555		# R1 contains 0x00005555
LHB R1, 0x5555		# R1 contains 0x55555555
LLB R2, 0xfffe		# R2 contains 0xfffffffe
LHB R2, 0x7fff		# R2 contains 0x7ffffffe
ADD R3, R1, R2		# R3 should be 0x7fffffff
B OVFL, L_PASS		# branch to pass routine if overflow
B UNCOND, L_FAIL	# branch to fail routine


L_PASS:HLT

#########################
##Fail routine at 0xFFF##
#########################
L_FAIL: B UNCOND, L_FAIL