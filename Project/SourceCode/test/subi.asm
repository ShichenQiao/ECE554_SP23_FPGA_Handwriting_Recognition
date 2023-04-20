############################
##Test SUBi basic function ##
############################
## subtracting two positive numbers
## with correct output
LLB		R1, 0x6666		# R1 contains 0x00006666
ADDI	R1, R1, 0x11	# R1 should be 0x00006655
LLB		R4, 0x6655		# R4 contains 0x00006655 
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test SUBi basic function ##
############################
## subtracting a positive by a negative
## with overflow
LLB		R1, 0xfffe		# R1 contains 0xfffffffe
LHB		R1, 0x7fff		# R1 contains 0x7ffffffe
SUBI	R1, R1, 0xfe	# R1 should be 0x7fffffff
LLB		R4, 0xffff		# R4 contains 0xffffffff
LHB		R4, 0x7fff		# R4 contains 0x7fffffff
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test SUBi basic function ##
############################
## subtracting a negative by a positive
## with overflow
LLB		R1, 0x0055		# R1 contains 0x00000055
LHB		R1, 0x8000		# R1 contains 0x80000055
SUBI	R1, R1, 0x7f	# R1 should be 0x80000000
LLB		R4, 0x0000		# R4 contains 0x00000000
LHB		R4, 0x8000		# R4 contains 0x80000000
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

############################
##Test SUBi basic function ##
############################
## subtracting two negative numbers
## with correct output
LLB		R1, 0xff80		# R1 contains 0xffffff80
SUBI	R1, R1, 0x80	# R1 should be 0x00000000
LLB		R4, 0x0000		# R4 contains 0x00000000
SUB		R4, R1, R4		# compare R3 to known right answer
B		NEQ, L_FAIL		# branch to fail routine

##############################################
##Test that SUBi does not set negative flag ##
##############################################
## should not set negative flag
LLB		R1, 0x6655		# R1 contains 0x00006655
SUBI	R1, R1, 0x11	# R1 should be 0x00006644
B		LT, L_FAIL		# branch to fail routine if negative flag is set

######################################
##Test that SUBi sets negative flag ##
######################################
## should set negative
LLB		R1, 0xffd5		# R1 contains 0xffffffd5
SUBI	R1, R1, 0x01	# R3 should be 0xffffffd4
B		GTE, L_FAIL		# branch to fail if negative flag is not set

###########################################
##Test that SUBi does not set carry flag ##
###########################################
## should not set overflow
LLB		R1, 0x6655		# R1 contains 0x00006655
SUBI	R1, R1, 0x11	# R3 should be 0x00006644
B		OVFL, L_FAIL	# branch to fail routine if overflow

##################################
##Test that SUBi sets carry flag ##
##################################
## should set overflow
LLB		R1, 0x0000		# R1 contains 0x00000000
LHB		R1, 0x8000		# R1 contains 0x80000000
SUBI	R1, R1, 0x01	# R1 should be 0x80000000
B		OVFL, L_PASS	# branch to pass routine if overflow
B		UNCOND, L_FAIL	# branch to fail routine

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